import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 16.h),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // App Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Căn giữa theo chiều dọc
              children: [
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Blind Box Collection',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    // ignore: deprecated_member_use
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Login/Profile Button
          if (authState.user == null)
            GestureDetector(
              onTap: () {
                GoRouter.of(context).go('/login');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.login_outlined,
                      color: AppColors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                GoRouter.of(context).go('/profile');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppColors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Tài khoản',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
