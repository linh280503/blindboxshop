import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/admin_stats_card.dart';
import '../widgets/admin_bottom_navigation.dart';
import '../../../order/presentation/widgets/admin_recent_orders.dart';
import '../widgets/admin_quick_actions.dart';
import '../../../order/data/di/order_providers.dart';
import '../../../order/domain/entities/order_status.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

// Live stats provider
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final firestore = FirebaseFirestore.instance;
  final repo = ref.read(orderRepositoryProvider);

  // Orders
  final delivered = await repo.getAllOrders(status: OrderStatus.delivered);
  final completed = await repo.getAllOrders(status: OrderStatus.completed);
  final pending = await repo.getAllOrders(status: OrderStatus.pending);
  final totalOrders = await repo.getAllOrders();

  final totalRevenue = ([
    ...delivered,
    ...completed,
  ]).fold<double>(0.0, (sum, o) => sum + o.totalAmount);

  // Products
  final productsSnap = await firestore.collection('products').get();
  final totalProducts = productsSnap.docs.length;
  final lowStockSnap = await firestore
      .collection('products')
      .where('stock', isLessThanOrEqualTo: 10)
      .get();
  final lowStockProducts = lowStockSnap.docs.length;

  // Customers
  final customersSnap = await firestore
      .collection('users')
      .where('role', isEqualTo: 'customer')
      .get();
  final totalCustomers = customersSnap.docs.length;

  return {
    'totalOrders': totalOrders.length,
    'totalRevenue': totalRevenue,
    'totalProducts': totalProducts,
    'totalCustomers': totalCustomers,
    'pendingOrders': pending.length,
    'lowStockProducts': lowStockProducts,
  };
});

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Warm up critical data to reduce flicker on first paint
    Future.microtask(() {
      ref.read(dashboardStatsProvider.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (!mounted) return;
                  context.go('/login');
                },
                tooltip: 'Đăng xuất',
                icon: const Icon(Icons.logout),
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final statsAsync = ref.watch(dashboardStatsProvider);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: statsAsync.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              orElse: () => SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  children: [
                    // Stats Overview
                    Builder(
                      builder: (context) {
                        final stats = statsAsync.value!;
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng quan',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16.h),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 1.8,
                                children: [
                                  AdminStatsCard(
                                    title: 'Tổng đơn hàng',
                                    value: stats['totalOrders'].toString(),
                                    icon: Icons.shopping_cart_outlined,
                                    color: AppColors.primary,
                                    trend: '+12%',
                                    trendUp: true,
                                  ),
                                  AdminStatsCard(
                                    title: 'Doanh thu',
                                    value:
                                        '${((stats['totalRevenue'] as num) / 1000000).toStringAsFixed(1)}M',
                                    icon: Icons.attach_money,
                                    color: AppColors.success,
                                    trend: '+8%',
                                    trendUp: true,
                                  ),
                                  AdminStatsCard(
                                    title: 'Sản phẩm',
                                    value: stats['totalProducts'].toString(),
                                    icon: Icons.inventory_2_outlined,
                                    color: AppColors.info,
                                    trend: '+5',
                                    trendUp: true,
                                  ),
                                  AdminStatsCard(
                                    title: 'Khách hàng',
                                    value: stats['totalCustomers'].toString(),
                                    icon: Icons.people_outline,
                                    color: AppColors.warning,
                                    trend: '+15%',
                                    trendUp: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Quick Actions
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AdminQuickActions(),
                    ),

                    SizedBox(height: 16.h),

                    // Recent Orders
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AdminRecentOrders(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNavigation(
        currentTab: AdminTab.dashboard,
      ),
    );
  }
}
