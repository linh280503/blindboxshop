// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/order_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/order_provider.dart';
import '../../data/di/order_providers.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/usecases/update_order_status.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/admin_order_detail_dialog.dart';

final filteredOrdersProvider = Provider.autoDispose
    .family<List<OrderModel>, Map<String, String>>((ref, filters) {
      final ordersAsync = ref.watch(allOrdersStreamProvider);
      return ordersAsync.when(
        data: (orders) {
          final selectedTab = filters['selectedTab'] ?? 'Tất cả';
          final selectedStatus = filters['selectedStatus'] ?? 'Tất cả';
          final searchQuery = filters['searchQuery'] ?? '';
          final filterUserId = filters['userId'];

          return orders.where((order) {
            // Filter by specific user if provided
            if (filterUserId != null && filterUserId.isNotEmpty) {
              if (order.userId != filterUserId) return false;
            }

            // Tab filter
            if (selectedTab == 'Chờ xác nhận' &&
                order.status != OrderStatus.pending) {
              return false;
            }
            if (selectedTab == 'Đang xử lý' &&
                order.status != OrderStatus.confirmed) {
              return false;
            }
            if (selectedTab == 'Đang giao' &&
                order.status != OrderStatus.shipping) {
              return false;
            }
            if (selectedTab == 'Hoàn thành' &&
                order.status != OrderStatus.delivered &&
                order.status != OrderStatus.completed) {
              return false;
            }
            if (selectedTab == 'Đã hủy' &&
                order.status != OrderStatus.cancelled) {
              return false;
            }

            // Status chip filter
            if (selectedStatus != 'Tất cả' &&
                order.status.name != selectedStatus) {
              return false;
            }

            // Search filter (order number)
            if (searchQuery.isNotEmpty) {
              final id =
                  (order.orderNumber.isNotEmpty ? order.orderNumber : order.id)
                      .toLowerCase();
              if (!id.contains(searchQuery.toLowerCase())) {
                return false;
              }
            }

            return true;
          }).toList();
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });

class AdminOrderManagementPage extends ConsumerStatefulWidget {
  const AdminOrderManagementPage({super.key});

  @override
  ConsumerState<AdminOrderManagementPage> createState() =>
      _AdminOrderManagementPageState();
}

class _AdminOrderManagementPageState
    extends ConsumerState<AdminOrderManagementPage> {
  String _selectedTab = 'Tất cả';
  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';
  String _sortBy = 'Mới nhất';
  String? _filterUserId;

  // Add a key to force rebuild when filters change
  int _filterKey = 0;

  final List<String> _tabs = [
    'Tất cả',
    'Chờ xác nhận',
    'Đang xử lý',
    'Đang giao',
    'Hoàn thành',
    'Đã hủy',
  ];
  final List<String> _statuses = [
    'Tất cả',
    'pending',
    'confirmed',
    'processing',
    'shipping',
    'delivered',
    'cancelled',
  ];

  final List<String> _sortOptions = [
    'Mới nhất',
    'Cũ nhất',
    'Giá cao-thấp',
    'Giá thấp-cao',
  ];

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final qpUserId = state.uri.queryParameters['userId'];
    if (_filterUserId == null && qpUserId != null && qpUserId.isNotEmpty) {
      _filterUserId = qpUserId;
    } else {
      final extra = state.extra;
      if (_filterUserId == null && extra is Map && extra['userId'] is String) {
        _filterUserId = extra['userId'] as String;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          _filterUserId == null || _filterUserId!.isEmpty
              ? 'Quản lý đơn hàng'
              : 'Đơn hàng của khách',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đơn hàng...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 12.h),
                // Filter chips
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'Trạng thái',
                              _getStatusDisplayName(_selectedStatus),
                            ),
                            SizedBox(width: 8.w),
                            _buildFilterChip('Sắp xếp', _sortBy),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tab bar
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = tab == _selectedTab;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 16.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[600],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Orders list (Firestore)
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final ordersAsync = ref.watch(allOrdersStreamProvider);
                final filteredOrders = ref.watch(
                  filteredOrdersProvider({
                    'selectedTab': _selectedTab,
                    'selectedStatus': _selectedStatus,
                    'searchQuery': _searchQuery,
                    'userId': _filterUserId ?? '',
                  }),
                );

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ordersAsync.when(
                    loading: () => const Center(
                      key: ValueKey('loading'),
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(
                      key: const ValueKey('error'),
                      child: Text('Lỗi tải đơn hàng: $e'),
                    ),
                    data: (orders) {
                      if (filteredOrders.isEmpty) {
                        return Center(
                          key: const ValueKey('empty'),
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 60.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Không có đơn hàng',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        key: ValueKey('orders_${filteredOrders.length}'),
                        padding: EdgeInsets.all(16.w),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderItem(order);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderModel order) {
    final status = order.status.name;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusDisplayName(status);

    return Container(
      key: ValueKey('order_${order.id}'),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng ${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Consumer(
                    builder: (context, ref, child) {
                      final userAsync = ref.watch(
                        userProfileProvider(order.userId),
                      );
                      return userAsync.when(
                        data: (user) {
                          final displayName =
                              user?.name != null && user!.name.isNotEmpty
                              ? user.name
                              : (user?.email ?? order.userId);
                          return Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                        loading: () => Text(
                          'Đang tải...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                        error: (_, __) => Text(
                          order.userId,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  order.formattedTotalAmount,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Text(
            order.createdAt.toString(),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order items
                Text(
                  'Sản phẩm:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                ...order.items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} x${item.quantity}',
                            style: TextStyle(fontSize: 14.sp),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${item.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Shipping address
                Text(
                  'Địa chỉ giao hàng:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatAddress(order.deliveryAddress),
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 8.h),
                // Payment method
                Text(
                  'Phương thức thanh toán: ${order.paymentMethodName ?? '—'}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 16.h),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _viewOrderDetails(order),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text(
                          'Xem chi tiết',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (status == 'pending')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _confirmOrder(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            'Xác nhận',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    if (status == 'confirmed')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _prepareOrder(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            'Chuẩn bị',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    if (status == 'preparing')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _shipOrder(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: Text(
                            'Giao hàng',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'preparing':
        return Colors.purple;
      case 'shipping':
        return Colors.cyan;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return '—';
    final parts = [
      address['address'],
      address['ward'],
      address['district'],
      address['city'],
    ].where((part) => part != null && part.toString().isNotEmpty).join(', ');
    return parts.isEmpty ? '—' : parts;
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          key: ValueKey(_filterKey),
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bộ lọc',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedStatus = 'Tất cả';
                          _sortBy = 'Mới nhất';
                        });
                        setState(() {
                          _filterKey++; // Force rebuild
                        });
                      },
                      child: Text(
                        'Đặt lại',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection(
                        'Trạng thái',
                        _statuses
                            .map(
                              (s) =>
                                  s == 'Tất cả' ? s : _getStatusDisplayName(s),
                            )
                            .toList(),
                        _selectedStatus == 'Tất cả'
                            ? 'Tất cả'
                            : _getStatusDisplayName(_selectedStatus),
                        (value) {
                          setModalState(() {
                            _selectedStatus = value == 'Tất cả'
                                ? 'Tất cả'
                                : _statuses.firstWhere(
                                    (s) => _getStatusDisplayName(s) == value,
                                  );
                          });
                          setState(() {
                            _filterKey++; // Force rebuild
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      _buildFilterSection('Sắp xếp', _sortOptions, _sortBy, (
                        value,
                      ) {
                        setModalState(() {
                          _sortBy = value;
                        });
                        setState(() {
                          _filterKey++; // Force rebuild
                        });
                      }),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Apply filters
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'Áp dụng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () {
                onChanged(option);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _viewOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AdminOrderDetailDialog(order: order),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateOrderStatus(
    String orderId,
    OrderStatus status,
    String successMessage,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final updateOrderStatusUC = ref.read(updateOrderStatusProvider);
      await updateOrderStatusUC(
        UpdateOrderStatusParams(orderId: orderId, status: status),
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        NotificationService.showSuccess(successMessage);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        NotificationService.showError(
          'Lỗi cập nhật trạng thái: ${e.toString()}',
        );
      }
    }
  }

  void _confirmOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đơn hàng'),
        content: Text(
          'Bạn có chắc chắn muốn xác nhận đơn hàng ${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _updateOrderStatus(
                order.id,
                OrderStatus.confirmed,
                'Đã xác nhận đơn hàng',
              );
            },
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _prepareOrder(OrderModel order) async {
    _updateOrderStatus(
      order.id,
      OrderStatus.preparing,
      'Đơn chuyển trạng thái chuẩn bị',
    );
  }

  void _shipOrder(OrderModel order) async {
    _updateOrderStatus(
      order.id,
      OrderStatus.shipping,
      'Đơn chuyển trạng thái giao hàng',
    );
  }
}
