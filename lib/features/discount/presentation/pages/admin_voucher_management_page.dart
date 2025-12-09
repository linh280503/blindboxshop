import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/di/discount_providers.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/discount_status.dart';
import '../../domain/entities/discount_type.dart';

class AdminVoucherManagementPage extends ConsumerStatefulWidget {
  const AdminVoucherManagementPage({super.key});

  @override
  ConsumerState<AdminVoucherManagementPage> createState() =>
      _AdminVoucherManagementPageState();
}

class _AdminVoucherManagementPageState
    extends ConsumerState<AdminVoucherManagementPage> {
  List<Discount> _discounts = [];
  List<Discount> _filteredDiscounts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  Map<String, dynamic> _overview = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(discountRepositoryProvider);
      final discounts = await repo.getAllDiscounts();
      final overview = await repo.getDiscountOverview();

      setState(() {
        _discounts = discounts;
        _filteredDiscounts = discounts;
        _overview = overview;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      NotificationService.showError('Lỗi tải dữ liệu: ${e.toString()}');
    }
  }

  void _filterDiscounts() {
    setState(() {
      _filteredDiscounts = _discounts.where((discount) {
        // Filter by status
        bool statusMatch =
            _selectedStatus == 'all' || discount.status.name == _selectedStatus;

        // Filter by search query
        bool searchMatch =
            _searchQuery.isEmpty ||
            discount.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            discount.name.toLowerCase().contains(_searchQuery.toLowerCase());

        return statusMatch && searchMatch;
      }).toList();
    });
  }

  Future<void> _toggleDiscountStatus(Discount discount) async {
    try {
      final repo = ref.read(discountRepositoryProvider);
      await repo.toggleDiscountStatus(
        discount.id,
        discount.status != DiscountStatus.active,
      );

      NotificationService.showSuccess(
        'Đã ${discount.status == DiscountStatus.active ? 'vô hiệu hóa' : 'kích hoạt'} mã giảm giá',
      );

      _loadData();
    } catch (e) {
      NotificationService.showError('Lỗi cập nhật trạng thái: ${e.toString()}');
    }
  }

  Future<void> _deleteDiscount(Discount discount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa mã giảm giá "${discount.code}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(discountRepositoryProvider);
        await repo.deleteDiscount(discount.id);
        NotificationService.showSuccess('Đã xóa mã giảm giá');
        _loadData();
      } catch (e) {
        NotificationService.showError('Lỗi xóa mã giảm giá: ${e.toString()}');
      }
    }
  }

  Future<void> _duplicateDiscount(Discount discount) async {
    try {
      final repo = ref.read(discountRepositoryProvider);
      await repo.duplicateDiscount(discount.id);
      NotificationService.showSuccess('Đã sao chép mã giảm giá');
      _loadData();
    } catch (e) {
      NotificationService.showError(
        'Lỗi sao chép mã giảm giá: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Voucher'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await context.push('/admin/voucher/create');
              if (result == true) {
                _loadData(); // Auto refresh after creating voucher
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Overview Cards
                _buildOverviewCards(),

                // Search and Filter
                _buildSearchAndFilter(),

                // Discounts List
                Expanded(
                  child: _filteredDiscounts.isEmpty
                      ? _buildEmptyState()
                      : _buildDiscountsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildOverviewCards() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildOverviewCard(
              'Tổng số',
              _overview['totalDiscounts']?.toString() ?? '0',
              AppColors.primary,
              Icons.local_offer,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildOverviewCard(
              'Đang hoạt động',
              _overview['activeDiscounts']?.toString() ?? '0',
              AppColors.success,
              Icons.check_circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildOverviewCard(
              'Đã hết hạn',
              _overview['expiredDiscounts']?.toString() ?? '0',
              AppColors.error,
              Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm mã giảm giá...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterDiscounts();
            },
          ),

          SizedBox(height: 12.h),

          // Status Filter
          Row(
            children: [
              Text(
                'Trạng thái: ',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('all', 'Tất cả'),
                      SizedBox(width: 8.w),
                      _buildStatusChip('active', 'Hoạt động'),
                      SizedBox(width: 8.w),
                      _buildStatusChip('inactive', 'Không hoạt động'),
                      SizedBox(width: 8.w),
                      _buildStatusChip('expired', 'Hết hạn'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        _filterDiscounts();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _filteredDiscounts.length,
      itemBuilder: (context, index) {
        final discount = _filteredDiscounts[index];
        return _buildDiscountCard(discount);
      },
    );
  }

  Widget _buildDiscountCard(Discount discount) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discount.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      discount.code,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(discount.status),
            ],
          ),

          SizedBox(height: 8.h),

          // Description
          Text(
            discount.description,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 12.h),

          // Details
          Row(
            children: [
              _buildDetailChip(
                _formatDiscountValue(discount),
                discount.type == DiscountType.percentage
                    ? AppColors.primary
                    : AppColors.secondary,
              ),
              SizedBox(width: 8.w),
              if (discount.minOrderAmount != null)
                _buildDetailChip(
                  'Min: ${_formatCurrency(discount.minOrderAmount!)}',
                  AppColors.warning,
                ),
              SizedBox(width: 8.w),
              _buildDetailChip(
                'Đã dùng: ${discount.usedCount}',
                AppColors.info,
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleDiscountStatus(discount),
                  icon: Icon(
                    discount.status == DiscountStatus.active
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 16.sp,
                  ),
                  label: Text(
                    discount.status == DiscountStatus.active
                        ? 'Tạm dừng'
                        : 'Kích hoạt',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _duplicateDiscount(discount),
                  icon: Icon(Icons.copy, size: 16.sp),
                  label: Text('Sao chép', style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await context.push(
                      '/admin/voucher/edit/${discount.id}',
                    );
                    if (result == true) {
                      _loadData(); // Auto refresh after editing voucher
                    }
                  },
                  icon: Icon(Icons.edit, size: 16.sp),
                  label: Text('Sửa', style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteDiscount(discount),
                  icon: Icon(Icons.delete, size: 16.sp),
                  label: Text('Xóa', style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDiscountValue(Discount discount) {
    if (discount.type == DiscountType.percentage) {
      return '${discount.value.toStringAsFixed(0)}%';
    }
    return _formatCurrency(discount.value);
  }

  String _formatCurrency(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '$formattedđ';
  }

  Widget _buildStatusBadge(DiscountStatus status) {
    Color color;
    String text;

    switch (status) {
      case DiscountStatus.active:
        color = AppColors.success;
        text = 'Hoạt động';
        break;
      case DiscountStatus.inactive:
        color = AppColors.warning;
        text = 'Tạm dừng';
        break;
      case DiscountStatus.expired:
        color = AppColors.error;
        text = 'Hết hạn';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Không có mã giảm giá nào',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tạo mã giảm giá đầu tiên của bạn',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context.push('/admin/voucher/create'),
            icon: const Icon(Icons.add),
            label: const Text('Tạo mã giảm giá'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
