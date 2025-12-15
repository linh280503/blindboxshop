import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

enum AdminTab { dashboard, products, orders, customers, analytics }

class AdminBottomNavigation extends StatelessWidget {
  final AdminTab currentTab;

  const AdminBottomNavigation({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTab.index,
      onTap: (index) {
        final targetTab = AdminTab.values[index];
        if (targetTab == currentTab) return; // Không navigate nếu đã ở tab đó

        switch (targetTab) {
          case AdminTab.dashboard:
            context.go('/admin');
            break;
          case AdminTab.products:
            context.go('/admin/products');
            break;
          case AdminTab.orders:
            context.go('/admin/orders');
            break;
          case AdminTab.customers:
            context.go('/admin/customers');
            break;
          case AdminTab.analytics:
            context.go('/admin/analytics');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Sản phẩm',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined),
          activeIcon: Icon(Icons.people),
          label: 'Khách hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Thống kê',
        ),
      ],
    );
  }
}
