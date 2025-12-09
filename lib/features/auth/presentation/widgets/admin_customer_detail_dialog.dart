import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../../order/presentation/providers/order_provider.dart';

class AdminCustomerDetailDialog extends ConsumerStatefulWidget {
  final UserModel customer;

  const AdminCustomerDetailDialog({super.key, required this.customer});

  @override
  ConsumerState<AdminCustomerDetailDialog> createState() =>
      _AdminCustomerDetailDialogState();
}

class _AdminCustomerDetailDialogState
    extends ConsumerState<AdminCustomerDetailDialog> {
  late UserModel _customer;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _fetchLatestStats();
  }

  Future<void> _fetchLatestStats() async {
    try {
      // Fetch latest stats from OrderRepository
      final stats = await ref.read(orderStatsProvider(_customer.uid).future);

      final totalOrders = stats['totalOrders'] as int;
      final totalSpent = stats['totalRevenue'] as double;
      // Calculate points: 1 point per 1000 VND
      final points = (totalSpent / 1000).floor();

      // Update local state if different
      if (totalOrders != _customer.totalOrders ||
          totalSpent != _customer.totalSpent ||
          points != _customer.points) {
        if (mounted) {
          setState(() {
            _customer = _customer.copyWith(
              totalOrders: totalOrders,
              totalSpent: totalSpent,
              points: points,
            );
            _isLoadingStats = false;
          });
        }

        // Update Firestore to sync data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_customer.uid)
            .update({
              'totalOrders': totalOrders,
              'totalSpent': totalSpent,
              'points': points,
            });
      } else {
        if (mounted) {
          setState(() {
            _isLoadingStats = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      child: Container(
        width: 500.w,
        constraints: BoxConstraints(maxWidth: 500.w, maxHeight: 0.8.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    _buildProfileSection(),
                    SizedBox(height: 24.h),
                    _buildStatsGrid(),
                    SizedBox(height: 24.h),
                    _buildContactInfo(),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chi tiết khách hàng',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 3,
            ),
            image: _customer.avatar.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(_customer.avatar),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _customer.avatar.isEmpty
              ? Icon(Icons.person, size: 50.sp, color: Colors.grey[400])
              : null,
        ),
        SizedBox(height: 16.h),
        Text(
          _customer.name,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          _customer.email,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _customer.isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            _customer.isActive ? 'Hoạt động' : 'Bị khóa',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _customer.isActive ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    if (_isLoadingStats) {
      return Container(
        padding: EdgeInsets.all(20.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Đơn hàng',
            _customer.totalOrders.toString(),
            Icons.shopping_bag_outlined,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Chi tiêu',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'đ',
            ).format(_customer.totalSpent),
            Icons.attach_money,
            Colors.orange,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Điểm',
            _customer.points.toString(),
            Icons.star_outline,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
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
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', _customer.phone),
          Divider(height: 24.h, color: Colors.grey[200]),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Ngày tham gia',
            DateFormat('dd/MM/yyyy').format(_customer.createdAt),
          ),
          Divider(height: 24.h, color: Colors.grey[200]),
          _buildInfoRow(
            Icons.access_time,
            'Cập nhật lần cuối',
            DateFormat('dd/MM/yyyy HH:mm').format(_customer.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey[500]),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),
              SizedBox(height: 2.h),
              Text(
                value.isNotEmpty ? value : 'Chưa cập nhật',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'Đóng',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
