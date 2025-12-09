// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../order/data/di/order_providers.dart';
import '../../../order/domain/entities/order_status.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../auth/data/di/auth_providers.dart';

class AdminAnalyticsPage extends ConsumerStatefulWidget {
  final String initialSection;
  const AdminAnalyticsPage({super.key, this.initialSection = 'Doanh thu'});

  @override
  ConsumerState<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _RangeKey {
  final int startMs;
  final int endMs;
  const _RangeKey(this.startMs, this.endMs);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RangeKey && startMs == other.startMs && endMs == other.endMs;

  @override
  int get hashCode => Object.hash(startMs, endMs);
}

// Analytics providers
final analyticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
  final endOfLastMonth = DateTime(now.year, now.month, 0);

  final repo = ref.read(orderRepositoryProvider);

  // Get current month data
  final currentOrders = await repo.getAllOrders(
    startDate: startOfMonth,
    endDate: now,
  );

  // Get last month data for comparison
  final lastMonthOrders = await repo.getAllOrders(
    startDate: startOfLastMonth,
    endDate: endOfLastMonth,
  );

  // Calculate revenue
  final currentRevenue = currentOrders
      .where(
        (order) =>
            order.status == OrderStatus.shipping ||
            order.status == OrderStatus.delivered ||
            order.status == OrderStatus.completed,
      )
      .fold(0.0, (total, order) => total + order.totalAmount);

  final lastMonthRevenue = lastMonthOrders
      .where(
        (order) =>
            order.status == OrderStatus.shipping ||
            order.status == OrderStatus.delivered ||
            order.status == OrderStatus.completed,
      )
      .fold(0.0, (total, order) => total + order.totalAmount);

  final revenueGrowth = lastMonthRevenue > 0
      ? ((currentRevenue - lastMonthRevenue) / lastMonthRevenue * 100)
      : 0.0;

  // Get products count
  final productsSnapshot = await FirebaseFirestore.instance
      .collection('products')
      .get();
  final totalProducts = productsSnapshot.docs.isNotEmpty
      ? productsSnapshot.docs.length
      : 0;

  // Get customers count
  final customersSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'customer')
      .get();
  final totalCustomers = customersSnapshot.docs.isNotEmpty
      ? customersSnapshot.docs.length
      : 0;

  return {
    'revenue': {'total': currentRevenue, 'growth': revenueGrowth},
    'orders': {
      'total': currentOrders.length,
      'growth': lastMonthOrders.isNotEmpty
          ? ((currentOrders.length - lastMonthOrders.length) /
                lastMonthOrders.length *
                100)
          : 0.0,
    },
    'products': {
      'total': totalProducts,
      'growth': 0.0, // Products don't have growth calculation
    },
    'customers': {
      'total': totalCustomers,
      'growth': 0.0, // Customers growth would need historical data
    },
  };
});

final topProductsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        return await repo.getBestSellingProducts(limit: 5);
      } catch (e) {
        return [];
      }
    });

final slowProductsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        return await repo.getSlowSellingProducts(limit: 5);
      } catch (e) {
        return [];
      }
    });

final topCustomersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        return await repo.getTopCustomers(limit: 5);
      } catch (e) {
        return [];
      }
    });

// Range-based providers
final analyticsByRangeProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        final start = DateTime.fromMillisecondsSinceEpoch(key.startMs);
        final end = DateTime.fromMillisecondsSinceEpoch(key.endMs);
        final orders = await repo.getAllOrders(startDate: start, endDate: end);
        final revenue = orders
            .where(
              (o) =>
                  o.status == OrderStatus.shipping ||
                  o.status == OrderStatus.delivered ||
                  o.status == OrderStatus.completed,
            )
            .fold(0.0, (sum, o) => sum + o.totalAmount);
        final productsSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .get()
            .timeout(const Duration(seconds: 12));
        final customersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'customer')
            .get()
            .timeout(const Duration(seconds: 12));
        return {
          'revenue': {'total': revenue, 'growth': 0.0},
          'orders': {'total': orders.length, 'growth': 0.0},
          'products': {'total': productsSnapshot.docs.length, 'growth': 0.0},
          'customers': {'total': customersSnapshot.docs.length, 'growth': 0.0},
        };
      } catch (e) {
        return {
          'revenue': {'total': 0.0, 'growth': 0.0},
          'orders': {'total': 0, 'growth': 0.0},
          'products': {'total': 0, 'growth': 0.0},
          'customers': {'total': 0, 'growth': 0.0},
        };
      }
    });

final revenueSeriesByRangeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        final start = DateTime.fromMillisecondsSinceEpoch(key.startMs);
        final end = DateTime.fromMillisecondsSinceEpoch(key.endMs);
        final orders = await repo.getAllOrders(startDate: start, endDate: end);

        // Count revenue for SHIPPING/DELIVERED/COMPLETED; timeline date fallback: deliveredAt -> updatedAt
        final Map<DateTime, double> revenueByDay = {};
        for (final o in orders) {
          if (!(o.status == OrderStatus.shipping ||
              o.status == OrderStatus.delivered ||
              o.status == OrderStatus.completed))
            continue;
          final usedDate = o.deliveredAt ?? o.updatedAt;
          final dayKey = DateTime(usedDate.year, usedDate.month, usedDate.day);
          if (dayKey.isBefore(DateTime(start.year, start.month, start.day)) ||
              dayKey.isAfter(DateTime(end.year, end.month, end.day))) {
            continue;
          }
          revenueByDay.update(
            dayKey,
            (v) => v + o.totalAmount,
            ifAbsent: () => o.totalAmount,
          );
        }

        // Ensure continuity for every day in range
        DateTime cursor = DateTime(start.year, start.month, start.day);
        final DateTime lastDay = DateTime(end.year, end.month, end.day);
        final List<Map<String, dynamic>> series = [];
        while (!cursor.isAfter(lastDay)) {
          series.add({'x': cursor, 'y': revenueByDay[cursor] ?? 0.0});
          cursor = cursor.add(const Duration(days: 1));
        }

        return series;
      } catch (_) {
        return [];
      }
    });

/// Orders time-series for the selected range, grouped by day
final ordersSeriesByRangeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        final start = DateTime.fromMillisecondsSinceEpoch(key.startMs);
        final end = DateTime.fromMillisecondsSinceEpoch(key.endMs);
        final orders = await repo.getAllOrders(startDate: start, endDate: end);

        final Map<DateTime, int> countByDay = {};
        for (final o in orders) {
          final usedDate = o.createdAt;
          final dayKey = DateTime(usedDate.year, usedDate.month, usedDate.day);
          countByDay.update(dayKey, (v) => v + 1, ifAbsent: () => 1);
        }

        DateTime cursor = DateTime(start.year, start.month, start.day);
        final DateTime lastDay = DateTime(end.year, end.month, end.day);
        final List<Map<String, dynamic>> series = [];
        while (!cursor.isAfter(lastDay)) {
          series.add({'x': cursor, 'y': (countByDay[cursor] ?? 0).toDouble()});
          cursor = cursor.add(const Duration(days: 1));
        }
        return series;
      } catch (_) {
        return [];
      }
    });

/// Top-N products series (quantity) for current range
final productsTopSeriesByRangeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        final start = DateTime.fromMillisecondsSinceEpoch(key.startMs);
        final end = DateTime.fromMillisecondsSinceEpoch(key.endMs);
        final orders = await repo.getAllOrders(startDate: start, endDate: end);
        final filteredOrders = orders
            .where(
              (o) =>
                  o.status == OrderStatus.shipping ||
                  o.status == OrderStatus.delivered ||
                  o.status == OrderStatus.completed,
            )
            .toList();
        final Map<String, Map<String, dynamic>> stats = {};
        for (final order in filteredOrders) {
          for (final item in order.items) {
            stats.update(
              item.productId,
              (ex) => {
                'label': item.productName,
                'image': item.productImage,
                'y': (ex['y'] as num) + item.quantity,
              },
              ifAbsent: () => {
                'label': item.productName,
                'image': item.productImage,
                'y': item.quantity,
              },
            );
          }
        }
        final list = stats.values.toList()
          ..sort((a, b) => (b['y'] as num).compareTo(a['y'] as num));
        return list.take(5).toList();
      } catch (_) {
        return [];
      }
    });

/// Top-N customers series (totalSpent) for current range
final customersTopSeriesByRangeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        final getUserProfile = ref.read(getUserProfileProvider);
        final start = DateTime.fromMillisecondsSinceEpoch(key.startMs);
        final end = DateTime.fromMillisecondsSinceEpoch(key.endMs);
        final orders = await repo.getAllOrders(startDate: start, endDate: end);
        final filteredOrders = orders
            .where(
              (o) =>
                  o.status == OrderStatus.shipping ||
                  o.status == OrderStatus.delivered ||
                  o.status == OrderStatus.completed,
            )
            .toList();
        final Map<String, Map<String, dynamic>> stats = {};
        for (final order in filteredOrders) {
          stats.update(
            order.userId,
            (ex) => {
              'userId': order.userId,
              'y': (ex['y'] as num) + order.totalAmount,
            },
            ifAbsent: () => {'userId': order.userId, 'y': order.totalAmount},
          );
        }
        final list = stats.values.toList()
          ..sort((a, b) => (b['y'] as num).compareTo(a['y'] as num));

        final top5 = list.take(5).toList();
        final result = <Map<String, dynamic>>[];

        for (final item in top5) {
          final userId = item['userId'] as String;
          final user = await getUserProfile(userId);
          result.add({
            'label': user?.name != null && user!.name.isNotEmpty
                ? user.name
                : 'User ${userId.substring(0, 4)}...',
            'y': (item['y'] as num).toDouble(),
            'image': user?.avatar,
          });
        }
        return result;
      } catch (_) {
        return [];
      }
    });

final topProductsByRangeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        return await repo.getBestSellingProducts(
          limit: 5,
          startDate: DateTime.fromMillisecondsSinceEpoch(key.startMs),
          endDate: DateTime.fromMillisecondsSinceEpoch(key.endMs),
        );
      } catch (e) {
        return [];
      }
    });

final topCustomersByRangeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        return await repo.getTopCustomers(
          limit: 5,
          startDate: DateTime.fromMillisecondsSinceEpoch(key.startMs),
          endDate: DateTime.fromMillisecondsSinceEpoch(key.endMs),
        );
      } catch (e) {
        return [];
      }
    });

final slowProductsByRangeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        final start = DateTime.fromMillisecondsSinceEpoch(key.startMs);
        final end = DateTime.fromMillisecondsSinceEpoch(key.endMs);
        final orders = await repo.getAllOrders(startDate: start, endDate: end);
        final filteredOrders = orders
            .where(
              (o) =>
                  o.status == OrderStatus.shipping ||
                  o.status == OrderStatus.delivered ||
                  o.status == OrderStatus.completed,
            )
            .toList();

        // Lấy tất cả sản phẩm có trong kho
        final productsSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .get();
        final allProducts = productsSnapshot.docs
            .map((doc) => doc.data())
            .toList();

        final Map<String, Map<String, dynamic>> stats = {};
        for (final order in filteredOrders) {
          for (final item in order.items) {
            stats.update(
              item.productId,
              (ex) => {
                'productId': item.productId,
                'productName': item.productName,
                'productImage': item.productImage,
                'quantity': (ex['quantity'] as num) + item.quantity,
                'revenue': (ex['revenue'] as num) + item.price * item.quantity,
              },
              ifAbsent: () => {
                'productId': item.productId,
                'productName': item.productName,
                'productImage': item.productImage,
                'quantity': item.quantity,
                'revenue': item.price * item.quantity,
              },
            );
          }
        }

        // Thêm sản phẩm chưa bán được (quantity = 0)
        for (final product in allProducts) {
          final productId = product['id'] ?? '';
          if (!stats.containsKey(productId)) {
            stats[productId] = {
              'productId': productId,
              'productName': product['name'] ?? 'Unknown',
              'productImage': product['image'] ?? '',
              'quantity': 0,
              'revenue': 0.0,
            };
          }
        }

        final list = stats.values.toList()
          ..sort(
            (a, b) => (a['quantity'] as num).compareTo(b['quantity'] as num),
          );
        return list.take(5).toList();
      } catch (e) {
        return [];
      }
    });

final lowCustomersByRangeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, _RangeKey>((ref, key) async {
      try {
        final repo = ref.read(orderRepositoryProvider);
        final getUserProfile = ref.read(getUserProfileProvider);
        final start = DateTime.fromMillisecondsSinceEpoch(key.startMs);
        final end = DateTime.fromMillisecondsSinceEpoch(key.endMs);
        final orders = await repo.getAllOrders(startDate: start, endDate: end);
        final filteredOrders = orders
            .where(
              (o) =>
                  o.status == OrderStatus.shipping ||
                  o.status == OrderStatus.delivered ||
                  o.status == OrderStatus.completed,
            )
            .toList();
        final Map<String, Map<String, dynamic>> stats = {};
        for (final order in filteredOrders) {
          stats.update(
            order.userId,
            (ex) => {
              'userId': order.userId,
              'orderCount': (ex['orderCount'] as int) + 1,
              'totalSpent': (ex['totalSpent'] as num) + order.totalAmount,
            },
            ifAbsent: () => {
              'userId': order.userId,
              'orderCount': 1,
              'totalSpent': order.totalAmount,
            },
          );
        }
        final list = stats.values.toList()
          ..sort(
            (a, b) =>
                (a['totalSpent'] as num).compareTo(b['totalSpent'] as num),
          );
        // Chỉ lấy những khách thực sự mua ít
        final totalSpentList = list
            .map((e) => (e['totalSpent'] as num).toDouble())
            .toList();
        final averageSpent = totalSpentList.isNotEmpty
            ? totalSpentList.reduce((a, b) => a + b) / totalSpentList.length
            : 0.0;
        final lowSpenders = list
            .where(
              (customer) =>
                  (customer['totalSpent'] as num).toDouble() < averageSpent,
            )
            .toList();

        final top5Low = lowSpenders.take(5).toList();
        final result = <Map<String, dynamic>>[];

        for (final item in top5Low) {
          final userId = item['userId'] as String;
          final user = await getUserProfile(userId);
          result.add({
            'label': user?.name != null && user!.name.isNotEmpty
                ? user.name
                : 'User ${userId.substring(0, 4)}...',
            'y': (item['totalSpent'] as num).toDouble(),
            'image': user?.avatar,
          });
        }
        return result;
      } catch (e) {
        return [];
      }
    });

class _AdminAnalyticsPageState extends ConsumerState<AdminAnalyticsPage> {
  String _selectedPeriod = 'Tháng này';
  String _selectedChart = 'Doanh thu';

  final List<String> _periods = [
    'Hôm nay',
    'Tuần này',
    'Tháng này',
    'Quý này',
    'Năm này',
  ];

  String _normalizeSection(String raw) {
    switch (raw) {
      case 'Đơn hàng':
      case 'Sản phẩm':
      case 'Khách hàng':
        return raw;
      default:
        return 'Doanh thu';
    }
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.map((period) {
                  final isSelected = period == _selectedPeriod;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        period,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final range = _rangeForPeriod(_selectedPeriod);
    final currentSection = _normalizeSection(widget.initialSection);
    _selectedChart = currentSection;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin'),
        ),
        title: Text(
          'Thống kê & Phân tích',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _AnalyticsTab(
                    label: 'Doanh thu',
                    selected: currentSection == 'Doanh thu',
                    onTap: () {
                      if (currentSection != 'Doanh thu') {
                        context.go('/admin/analytics/revenue');
                      }
                    },
                  ),
                  SizedBox(width: 8.w),
                  _AnalyticsTab(
                    label: 'Đơn hàng',
                    selected: currentSection == 'Đơn hàng',
                    onTap: () {
                      if (currentSection != 'Đơn hàng') {
                        context.go('/admin/analytics/orders');
                      }
                    },
                  ),
                  SizedBox(width: 8.w),
                  _AnalyticsTab(
                    label: 'Sản phẩm',
                    selected: currentSection == 'Sản phẩm',
                    onTap: () {
                      if (currentSection != 'Sản phẩm') {
                        context.go('/admin/analytics/products');
                      }
                    },
                  ),
                  SizedBox(width: 8.w),
                  _AnalyticsTab(
                    label: 'Khách hàng',
                    selected: currentSection == 'Khách hàng',
                    onTap: () {
                      if (currentSection != 'Khách hàng') {
                        context.go('/admin/analytics/customers');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          _periodSelectorOrEmpty(
            currentSection == 'Doanh thu' || currentSection == 'Đơn hàng',
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final analyticsAsync = ref.watch(
                  analyticsByRangeProvider(
                    _RangeKey(
                      range.start.millisecondsSinceEpoch,
                      range.end.millisecondsSinceEpoch,
                    ),
                  ),
                );

                return analyticsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Lỗi tải dữ liệu: $e')),
                  data: (analyticsData) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          _buildOverviewCards(analyticsData),
                          SizedBox(height: 20.h),
                          if (currentSection == 'Doanh thu' ||
                              currentSection == 'Đơn hàng')
                            _buildChartSection(analyticsData),
                          SizedBox(height: 20.h),
                          ..._buildSectionBlocks(currentSection),
                        ],
                      ),
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

  Widget _periodSelectorOrEmpty(bool show) {
    if (show) return _buildPeriodSelector();
    return const SizedBox.shrink();
  }

  List<Widget> _buildSectionBlocks(String section) {
    switch (section) {
      case 'Sản phẩm':
        final range = _rangeForPeriod(_selectedPeriod);
        return [
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 5 sản phẩm bán chạy',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Consumer(
                  builder: (context, ref, _) {
                    final async = ref.watch(
                      productsTopSeriesByRangeProvider(
                        _RangeKey(
                          range.start.millisecondsSinceEpoch,
                          range.end.millisecondsSinceEpoch,
                        ),
                      ),
                    );
                    return async.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, __) => Center(child: Text('Lỗi: $e')),
                      data: (series) {
                        if (series.isEmpty) {
                          return Text(
                            'Chưa có dữ liệu',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return _RankingList(
                          series: series,
                          color: _getColor(),
                          formatValue: (num v) => v.toInt().toString(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 5 sản phẩm bán chậm',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Consumer(
                  builder: (context, ref, _) {
                    final async = ref.watch(
                      slowProductsByRangeProvider(
                        _RangeKey(
                          range.start.millisecondsSinceEpoch,
                          range.end.millisecondsSinceEpoch,
                        ),
                      ),
                    );
                    return async.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, __) => Center(child: Text('Lỗi: $e')),
                      data: (list) {
                        final series = list
                            .map(
                              (e) => {
                                'label': (e['productName'] ?? '') as String,
                                'y': (e['quantity'] as num),
                              },
                            )
                            .toList();
                        if (series.isEmpty) {
                          return Text(
                            'Chưa có dữ liệu',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return _RankingList(
                          series: series,
                          color: _getColor(),
                          formatValue: (num v) => v.toInt().toString(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ];
      case 'Khách hàng':
        final range = _rangeForPeriod(_selectedPeriod);
        return [
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 5 khách chi tiêu cao',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Consumer(
                  builder: (context, ref, _) {
                    final async = ref.watch(
                      customersTopSeriesByRangeProvider(
                        _RangeKey(
                          range.start.millisecondsSinceEpoch,
                          range.end.millisecondsSinceEpoch,
                        ),
                      ),
                    );
                    return async.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, __) => Center(child: Text('Lỗi: $e')),
                      data: (series) {
                        if (series.isEmpty) {
                          return Text(
                            'Chưa có dữ liệu',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return _RankingList(
                          series: series,
                          color: _getColor(),
                          formatValue: (num v) => _formatCurrency(v.toDouble()),
                          isCurrency: true,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 5 khách mua ít',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Consumer(
                  builder: (context, ref, _) {
                    final async = ref.watch(
                      lowCustomersByRangeProvider(
                        _RangeKey(
                          range.start.millisecondsSinceEpoch,
                          range.end.millisecondsSinceEpoch,
                        ),
                      ),
                    );
                    return async.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, __) => Center(child: Text('Lỗi: $e')),
                      data: (list) {
                        final series = list
                            .map(
                              (e) => {
                                'label': (e['userId'] ?? '') as String,
                                'y': (e['totalSpent'] as num).toDouble(),
                              },
                            )
                            .toList();
                        if (series.isEmpty) {
                          return Text(
                            'Chưa có dữ liệu',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return _RankingList(
                          series: series,
                          color: _getColor(),
                          formatValue: (num v) => _formatCurrency(v.toDouble()),
                          isCurrency: true,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ];
      case 'Đơn hàng':
        return [];
      case 'Doanh thu':
      default:
        return [];
    }
  }

  Widget _buildOverviewCards(Map<String, dynamic> analyticsData) {
    final currentData = analyticsData[_getDataKey()];

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Tổng ${_selectedChart.toLowerCase()}',
            _formatValue(currentData['total']),
            _getIcon(),
            _getColor(),
            null,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double? growth,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              const Spacer(),
              if (growth != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '+$growth%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Map<String, dynamic> analyticsData) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biểu đồ $_selectedChart',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          SizedBox(height: 200.h, child: _buildChart(analyticsData)),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, dynamic> analyticsData) {
    final nowRange = _rangeForPeriod(_selectedPeriod);
    return Consumer(
      builder: (context, ref, _) {
        final provider = _selectedChart == 'Doanh thu'
            ? revenueSeriesByRangeProvider
            : _selectedChart == 'Đơn hàng'
            ? ordersSeriesByRangeProvider
            : _selectedChart == 'Sản phẩm'
            ? productsTopSeriesByRangeProvider
            : _selectedChart == 'Khách hàng'
            ? customersTopSeriesByRangeProvider
            : null;

        if (provider == null) {
          final currentData = analyticsData[_getDataKey()];
          final value = (currentData['total'] as num).toDouble();
          return Center(
            child: Text(
              _formatValue(value),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: _getColor(),
              ),
            ),
          );
        }

        final seriesAsync = ref.watch(
          provider(
            _RangeKey(
              nowRange.start.millisecondsSinceEpoch,
              nowRange.end.millisecondsSinceEpoch,
            ),
          ),
        );
        return seriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Lỗi tải biểu đồ: $e')),
          data: (series) {
            if (series.isEmpty) {
              return Center(
                child: Text(
                  'Chưa có dữ liệu',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              );
            }
            // For products/customers, use horizontal bars with labels
            if (_selectedChart == 'Sản phẩm' ||
                _selectedChart == 'Khách hàng') {
              final bool isCurrency = _selectedChart == 'Khách hàng';
              return _RankingList(
                series: series,
                color: _getColor(),
                formatValue: (num v) =>
                    isCurrency ? _formatValue(v.toDouble()) : v.toString(),
                isCurrency: isCurrency,
              );
            }
            // For revenue/orders, prefer line chart for long ranges
            return _SimpleLineChart(
              series: series,
              color: _getColor(),
              formatValue: (num v) => _selectedChart == 'Doanh thu'
                  ? _formatValue(v.toDouble())
                  : v.toString(),
            );
          },
        );
      },
    );
  }

  // removed unused sections for products/customers lists

  String _getDataKey() {
    switch (_selectedChart) {
      case 'Doanh thu':
        return 'revenue';
      case 'Đơn hàng':
        return 'orders';
      case 'Sản phẩm':
        return 'products';
      case 'Khách hàng':
        return 'customers';
      default:
        return 'revenue';
    }
  }

  IconData _getIcon() {
    switch (_selectedChart) {
      case 'Doanh thu':
        return Icons.attach_money;
      case 'Đơn hàng':
        return Icons.shopping_bag;
      case 'Sản phẩm':
        return Icons.inventory;
      case 'Khách hàng':
        return Icons.people;
      default:
        return Icons.attach_money;
    }
  }

  Color _getColor() {
    switch (_selectedChart) {
      case 'Doanh thu':
        return Colors.green;
      case 'Đơn hàng':
        return Colors.blue;
      case 'Sản phẩm':
        return Colors.orange;
      case 'Khách hàng':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  String _formatValue(dynamic value) {
    if (value is int) {
      if (_selectedChart == 'Doanh thu') {
        return '${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
      } else {
        return value.toString();
      }
    }
    return value.toString();
  }

  String _formatCurrency(double value) {
    final asInt = value.round();
    return '${asInt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  DateTimeRange _rangeForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Hôm nay':
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      case 'Tuần này':
        final weekday = now.weekday;
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: weekday - 1));
        final end = start.add(
          const Duration(
            days: 6,
            hours: 23,
            minutes: 59,
            seconds: 59,
            milliseconds: 999,
          ),
        );
        return DateTimeRange(start: start, end: end);
      case 'Tháng này':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      case 'Quý này':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final startMonth = (quarter - 1) * 3 + 1;
        final start = DateTime(now.year, startMonth, 1);
        final end = DateTime(now.year, startMonth + 3, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      case 'Năm này':
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
      default:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);
    }
  }
}

class _AnalyticsTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AnalyticsTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  final List<Map<String, dynamic>> series; // {label, y, image?}
  final Color color;
  final String Function(num) formatValue;
  final bool isCurrency;

  const _RankingList({
    required this.series,
    required this.color,
    required this.formatValue,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return Center(
        child: Text(
          'Chưa có dữ liệu',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      );
    }

    final maxY = series.fold<double>(
      0,
      (m, e) => (e['y'] as num).toDouble() > m ? (e['y'] as num).toDouble() : m,
    );

    return Column(
      children: series.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final rank = index + 1;
        final value = (item['y'] as num).toDouble();
        final percent = maxY > 0 ? (value / maxY) : 0.0;
        final image = item['image'] as String?;

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank Badge
              Container(
                width: 24.w,
                height: 24.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rank <= 3 ? color.withOpacity(0.2) : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? color : Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Image (if available)
              if (image != null && image.isNotEmpty) ...[
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['label'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          formatValue(value),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Progress Bar
                    Stack(
                      children: [
                        Container(
                          height: 6.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percent,
                          child: Container(
                            height: 6.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withOpacity(0.7), color],
                              ),
                              borderRadius: BorderRadius.circular(3.r),
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
      }).toList(),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> series; // {x: DateTime, y: double}
  final Color color;
  final String Function(num) formatValue;
  const _SimpleLineChart({
    required this.series,
    required this.color,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return Center(
        child: Text(
          'Chưa có dữ liệu',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final spots = series.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['y'] as num).toDouble());
    }).toList();

    final maxY = series
        .map((e) => (e['y'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = maxY * 1.2;
    final effectiveMaxY = adjustedMaxY == 0 ? 100.0 : adjustedMaxY;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: effectiveMaxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[200], strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (series.length / 5).ceil().toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < series.length) {
                  final date = series[index]['x'] as DateTime;
                  return Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10.sp,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  _compactNumber(value),
                  style: TextStyle(color: Colors.grey[600], fontSize: 10.sp),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (series.length - 1).toDouble(),
        minY: 0,
        maxY: effectiveMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                final date = series[index]['x'] as DateTime;
                final value = touchedSpot.y;
                return LineTooltipItem(
                  '${date.day}/${date.month}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: formatValue(value),
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _compactNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
