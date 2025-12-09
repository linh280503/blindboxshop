// ignore_for_file: unused_element, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/admin_customer_detail_dialog.dart';

class AdminCustomerManagementPage extends ConsumerStatefulWidget {
  const AdminCustomerManagementPage({super.key});

  @override
  ConsumerState<AdminCustomerManagementPage> createState() =>
      _AdminCustomerManagementPageState();
}

// Admin customers provider - stream from Firestore
final adminCustomersProvider = StreamProvider.autoDispose<List<UserModel>>((
  ref,
) {
  final query = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'customer')
      .orderBy('createdAt', descending: true);
  return query.snapshots().map(
    (snap) => snap.docs.map((d) => UserModel.fromFirestore(d)).toList(),
  );
});

class _AdminCustomerManagementPageState
    extends ConsumerState<AdminCustomerManagementPage> {
  String _selectedTab = 'Tất cả';
  String _searchQuery = '';
  String _sortBy = 'Mới nhất';

  final List<String> _tabs = ['Tất cả', 'Hoạt động', 'Bị khóa', 'VIP'];
  final List<String> _sortOptions = [
    'Mới nhất',
    'Cũ nhất',
    'Mua nhiều nhất',
    'Chi tiêu cao nhất',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Quản lý khách hàng',
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
                    hintText: 'Tìm kiếm khách hàng...',
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
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [_buildFilterChip('Sắp xếp', _sortBy)],
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
          // Customers list (Firestore)
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final customersAsync = ref.watch(adminCustomersProvider);
                return customersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Lỗi tải khách hàng: $e')),
                  data: (customers) {
                    final filtered = customers.where((customer) {
                      // Tab filter
                      if (_selectedTab == 'Hoạt động' && !customer.isActive) {
                        return false;
                      }
                      if (_selectedTab == 'Bị khóa' && customer.isActive) {
                        return false;
                      }
                      if (_selectedTab == 'VIP' &&
                          customer.totalSpent < 1000000) {
                        return false; // VIP threshold
                      }

                      // Search filter
                      if (_searchQuery.isNotEmpty) {
                        final name = customer.name.toLowerCase();
                        final email = customer.email.toLowerCase();
                        final phone = customer.phone.toLowerCase();
                        if (!name.contains(_searchQuery.toLowerCase()) &&
                            !email.contains(_searchQuery.toLowerCase()) &&
                            !phone.contains(_searchQuery.toLowerCase())) {
                          return false;
                        }
                      }

                      // Status handled by tabs
                      if (_selectedTab == 'Hoạt động' && !customer.isActive) {
                        return false;
                      }
                      if (_selectedTab == 'Bị khóa' && customer.isActive) {
                        return false;
                      }
                      if (_selectedTab == 'VIP' &&
                          customer.totalSpent < 1000000) {
                        return false;
                      }

                      return true;
                    }).toList();

                    // Apply sort option
                    switch (_sortBy) {
                      case 'Mới nhất':
                        filtered.sort(
                          (a, b) => b.createdAt.compareTo(a.createdAt),
                        );
                        break;
                      case 'Cũ nhất':
                        filtered.sort(
                          (a, b) => a.createdAt.compareTo(b.createdAt),
                        );
                        break;
                      case 'Mua nhiều nhất':
                        filtered.sort(
                          (a, b) => (b.totalOrders).compareTo(a.totalOrders),
                        );
                        break;
                      case 'Chi tiêu cao nhất':
                        filtered.sort(
                          (a, b) => (b.totalSpent).compareTo(a.totalSpent),
                        );
                        break;
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 60.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Không có khách hàng',
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
                      padding: EdgeInsets.all(16.w),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final customer = filtered[index];
                        return _buildCustomerItem(customer);
                      },
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

  Widget _buildCustomerItem(UserModel customer) {
    final status = customer.isActive ? 'active' : 'locked';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusDisplayName(status);
    final isVip = customer.totalSpent >= 1000000;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.grey[100],
                backgroundImage: customer.avatar.isNotEmpty
                    ? NetworkImage(customer.avatar)
                    : null,
                child: customer.avatar.isEmpty
                    ? Icon(Icons.person, size: 35.sp, color: Colors.grey[400])
                    : null,
              ),
              if (isVip)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.star, size: 12.sp, color: Colors.white),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Email
                Text(
                  customer.email,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                // Phone
                Text(
                  customer.phone.isNotEmpty ? customer.phone : 'Chưa cập nhật',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 12.h),
                // Stats Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        Icons.shopping_bag_outlined,
                        '${customer.totalOrders} đơn hàng',
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildStatItem(
                        Icons.attach_money,
                        '${customer.totalSpent.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        Icons.star_outline,
                        '${customer.points} điểm',
                        iconColor: Colors.amber,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildStatItem(
                        Icons.calendar_today_outlined,
                        'Tham gia ${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onSelected: (value) => _handleCustomerAction(value, customer),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      size: 20.sp,
                      color: Colors.grey[700],
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'orders',
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      size: 20.sp,
                      color: Colors.grey[700],
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Đơn hàng',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: customer.isActive ? 'lock' : 'unlock',
                child: Row(
                  children: [
                    Icon(
                      customer.isActive ? Icons.lock : Icons.lock_open,
                      size: 20.sp,
                      color: Colors.grey[700],
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      customer.isActive ? 'Khóa tài khoản' : 'Mở khóa',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Xóa',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: iconColor ?? Colors.grey[600]),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'locked':
        return Colors.red;
      case 'vip':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'locked':
        return 'Bị khóa';
      case 'vip':
        return 'VIP';
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
                          _sortBy = 'Mới nhất';
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
                      // Only sort section remains; status controlled by tab
                      _buildFilterSection('Sắp xếp', _sortOptions, _sortBy, (
                        value,
                      ) {
                        setModalState(() {
                          _sortBy = value;
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
                          setState(() {});
                          Navigator.pop(context);
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
              onTap: () => onChanged(option),
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

  void _handleCustomerAction(String action, UserModel customer) {
    switch (action) {
      case 'view':
        _viewCustomerDetails(customer);
        break;
      case 'orders':
        _viewCustomerOrders(customer);
        break;
      case 'lock':
      case 'unlock':
        _toggleCustomerLock(customer);
        break;
      case 'delete':
        _showDeleteDialog(customer);
        break;
    }
  }

  void _viewCustomerDetails(UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => AdminCustomerDetailDialog(customer: customer),
    );
  }

  void _viewCustomerOrders(UserModel customer) {
    GoRouter.of(context).push('/admin/orders?userId=${customer.uid}');
  }

  void _toggleCustomerLock(UserModel customer) {
    final isLocked = !customer.isActive;
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
                  color: isLocked
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked ? Icons.lock_open : Icons.lock,
                  size: 32.sp,
                  color: isLocked ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Text(
                isLocked
                    ? 'Bạn có chắc chắn muốn mở khóa tài khoản của ${customer.name}?'
                    : 'Bạn có chắc chắn muốn khóa tài khoản của ${customer.name}?\nKhách hàng sẽ không thể đăng nhập được nữa.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
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
                          fontSize: 16.sp,
                          color: Colors.grey[600],
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
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(customer.uid)
                              .update({'isActive': !customer.isActive});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isLocked
                                    ? 'Đã mở khóa tài khoản'
                                    : 'Đã khóa tài khoản',
                              ),
                              backgroundColor: isLocked
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLocked ? Colors.green : Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        isLocked ? 'Mở khóa' : 'Khóa',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  void _showDeleteDialog(UserModel customer) {
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
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever,
                  size: 32.sp,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Xóa khách hàng',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Text(
                'Bạn có chắc chắn muốn xóa khách hàng ${customer.name}?\nHành động này không thể hoàn tác.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
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
                          fontSize: 16.sp,
                          color: Colors.grey[600],
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
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(customer.uid)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa khách hàng'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  // all actions implemented
}
