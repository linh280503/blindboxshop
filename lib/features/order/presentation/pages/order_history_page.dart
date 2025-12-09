// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/order_item_card.dart';
import '../../data/models/order_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../../domain/entities/order_status.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  String _selectedStatus = 'all';

  final List<Map<String, dynamic>> statusFilters = [
    {'key': 'all', 'label': 'Tất cả'},
    {'key': AppConstants.orderPending, 'label': 'Chờ xác nhận'},
    {'key': AppConstants.orderConfirmed, 'label': 'Đã xác nhận'},
    {'key': AppConstants.orderShipping, 'label': 'Đang giao'},
    {'key': AppConstants.orderDelivered, 'label': 'Đã giao'},
    {'key': AppConstants.orderCancelled, 'label': 'Đã hủy'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final uid = auth.user?.uid;
    final ordersAsync = uid != null
        ? ref.watch(userOrdersStreamProvider(uid))
        : const AsyncValue<List<OrderModel>>.loading();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Đơn hàng của tôi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statusFilters.length,
              itemBuilder: (context, index) {
                final filter = statusFilters[index];
                final isSelected = filter['key'] == _selectedStatus;

                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(filter['label']),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = filter['key'];
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi tải đơn hàng: $e')),
              data: (orders) {
                final filtered = _selectedStatus == 'all'
                    ? orders
                    : orders
                          .where((o) => o.status.name == _selectedStatus)
                          .toList();
                if (filtered.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return OrderItemCard(
                      order: order,
                      onTap: () {
                        final uri = Uri(
                          path: '/order-history',
                          queryParameters: {'orderId': order.id},
                        );
                        context.push(uri.toString());
                      },
                      onCancel: order.canCancel
                          ? () => _cancelOrder(order.id)
                          : null,
                      onReview: order.canReview
                          ? () => _reviewOrder(order)
                          : null,
                      onReorder:
                          (order.status == OrderStatus.delivered ||
                              order.status == OrderStatus.completed ||
                              order.status == OrderStatus.cancelled)
                          ? () => _reorder(order)
                          : null,
                      onConfirmReceived:
                          (order.status == OrderStatus.confirmed ||
                              order.status == OrderStatus.shipping)
                          ? () => _markAsReceived(order.id)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _markAsReceived(String orderId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 32.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Xác nhận đã nhận hàng',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Bạn đã nhận được đơn hàng này và hài lòng với sản phẩm?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await ref
                              .read(ordersProvider.notifier)
                              .updateOrderStatus(
                                orderId,
                                OrderStatus.delivered,
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xác nhận nhận hàng'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60.sp,
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              'Chưa có đơn hàng',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              'Bạn chưa có đơn hàng nào.\nHãy khám phá và mua sắm ngay!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Mua sắm ngay',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hủy đơn hàng'),
        content: Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(ordersProvider.notifier)
                    .cancelOrder(orderId, reason: 'Khách hàng hủy đơn');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã hủy đơn hàng'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi hủy đơn: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text('Có', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _reviewOrder(OrderModel order) {
    if (order.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đơn hàng không có sản phẩm để đánh giá'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Nếu chỉ có 1 sản phẩm, chuyển thẳng đến trang đánh giá
    if (order.items.length == 1) {
      final item = order.items.first;
      final params = {
        'productId': item.productId,
        'productName': item.productName,
        'productImage': item.productImage,
        'orderId': order.id,
      };
      final uri = Uri(path: '/review', queryParameters: params);
      context.push(uri.toString());
      return;
    }

    // Nếu có nhiều sản phẩm, hiển thị dialog chọn sản phẩm
    _showProductSelectionDialog(order);
  }

  void _showProductSelectionDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 10,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.rate_review,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn sản phẩm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Đơn hàng #${order.orderNumber}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.r),
                            onTap: () {
                              Navigator.pop(context);
                              final params = {
                                'productId': item.productId,
                                'productName': item.productName,
                                'productImage': item.productImage,
                                'orderId': order.id,
                              };
                              final uri = Uri(
                                path: '/review',
                                queryParameters: params,
                              );
                              context.push(uri.toString());
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image
                                  Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: item.productImage.isNotEmpty
                                          ? Image.network(
                                              item.productImage,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey[400],
                                                        size: 30.sp,
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[400],
                                                size: 30.sp,
                                              ),
                                            ),
                                    ),
                                  ),

                                  SizedBox(width: 16.w),

                                  // Product info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                            height: 1.3,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Text(
                                            'Số lượng: ${item.quantity}',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 8.w),

                                  // Arrow icon
                                  Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[400],
                                      size: 18.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    // Review all button
                    Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            Navigator.pop(context);
                            _reviewAllProducts(order);
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rate_review,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Đánh giá tất cả sản phẩm',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Cancel button
                    Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () => Navigator.pop(context),
                          child: Center(
                            child: Text(
                              'Để sau',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
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

  void _reviewAllProducts(OrderModel order) {
    // Chuyển đến trang đánh giá tất cả sản phẩm
    // Có thể tạo một trang riêng hoặc sử dụng trang hiện tại với logic khác
    final params = {'orderId': order.id, 'allProducts': 'true'};
    final uri = Uri(path: '/review-all', queryParameters: params);
    context.push(uri.toString());
  }

  Future<void> _reorder(OrderModel order) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    int addedCount = 0;
    final cartNotifier = ref.read(cartProvider.notifier);

    for (final item in order.items) {
      final success = await cartNotifier.addItem(
        item.productId,
        item.productName,
        item.price,
        item.productImage,
        quantity: item.quantity,
        productType: item.orderType.name,
        boxSize: item.boxSize,
        setSize: item.setSize,
      );
      if (success) addedCount++;
    }

    // Hide loading
    if (mounted) Navigator.pop(context);

    if (addedCount > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm $addedCount sản phẩm vào giỏ hàng'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Xem giỏ hàng',
              textColor: Colors.white,
              onPressed: () => context.push('/cart'),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể thêm sản phẩm vào giỏ hàng (Hết hàng)'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
