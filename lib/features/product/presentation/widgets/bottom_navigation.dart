import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../../core/constants/app_colors.dart';

class BottomNavigation extends ConsumerStatefulWidget {
  const BottomNavigation({super.key});

  @override
  ConsumerState<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends ConsumerState<BottomNavigation> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'Trang chủ',
      'route': '/home',
    },
    {
      'icon': Icons.grid_view_outlined,
      'activeIcon': Icons.grid_view,
      'label': 'Sản phẩm',
      'route': '/products',
    },
    {
      'icon': Icons.shopping_cart_outlined,
      'activeIcon': Icons.shopping_cart,
      'label': 'Giỏ hàng',
      'route': '/cart',
    },
    {
      'icon': Icons.receipt_long_outlined,
      'activeIcon': Icons.receipt_long,
      'label': 'Đơn hàng',
      'route': '/orders',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Tài khoản',
      'route': '/profile',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    final route = _navItems[index]['route'];
    if (route != null) {
      // If tapping Cart and not logged in -> go to login
      if (route == '/cart') {
        final authState = ref.read(authProvider);
        if (authState.user == null) {
          context.go('/login');
          return;
        }
      }
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    // You might prefer totalItems instead of unique items count
    final cartCount = ref.watch(cartItemsCountProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              isSelected ? item['activeIcon'] : item['icon'],
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 24.sp,
                            ),
                            // Badge for cart icon (only when logged in and count > 0)
                            if (item['route'] == '/cart' &&
                                authState.user != null &&
                                cartCount > 0)
                              Positioned(
                                right: -12,
                                top: -12,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16.w,
                                    minHeight: 16.h,
                                  ),
                                  child: Text(
                                    '$cartCount',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item['label'],
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 10.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
