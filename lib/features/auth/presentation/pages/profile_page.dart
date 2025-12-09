import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () => context.go('/home'),
              tooltip: 'Về trang chủ',
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      // ignore: deprecated_member_use
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      ref.watch(authProvider).user?.name ?? 'Người dùng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      ref.watch(authProvider).user?.email ?? '',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    if (ref.watch(authProvider).user != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          (() {
                            final role =
                                ref.watch(authProvider).user?.role ??
                                'customer';
                            switch (role) {
                              case 'admin':
                                return 'Quản trị viên';
                              case 'customer':
                              default:
                                return 'Khách hàng';
                            }
                          })(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Profile stats
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Đơn hàng',
                      (ref.watch(authProvider).user?.totalOrders ?? 0)
                          .toString(),
                      Icons.shopping_bag,
                    ),
                  ),
                  Container(width: 1, height: 40.h, color: Colors.grey[200]),
                  Expanded(child: _buildStatItem('Đánh giá', '-', Icons.star)),
                  Container(width: 1, height: 40.h, color: Colors.grey[200]),
                  Expanded(
                    child: _buildStatItem(
                      'Điểm tích',
                      (ref.watch(authProvider).user?.points ?? 0).toString(),
                      Icons.card_giftcard,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menu items
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMenuSection('Tài khoản', [
                  _buildMenuItem(
                    'Thông tin cá nhân',
                    Icons.person_outline,
                    () => context.push('/personal-info'),
                  ),
                  _buildMenuItem(
                    'Địa chỉ giao hàng',
                    Icons.location_on_outlined,
                    () => context.push('/delivery-address'),
                  ),
                  _buildMenuItem(
                    'Đổi mật khẩu',
                    Icons.lock_outline,
                    () => context.push('/change-password'),
                  ),
                ]),
                _buildMenuSection('Đơn hàng', [
                  _buildMenuItem(
                    'Lịch sử đơn hàng',
                    Icons.history,
                    () => context.push('/order-history'),
                  ),
                ]),
                _buildMenuSection('Khác', [
                  _buildMenuItem(
                    'Đăng xuất',
                    Icons.logout,
                    () => _showLogoutDialog(),
                    isDestructive: true,
                  ),
                ]),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primary,
        size: 24.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (!mounted) return;
              context.go('/login');
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
