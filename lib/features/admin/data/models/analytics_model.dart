import 'package:cloud_firestore/cloud_firestore.dart';

class RevenueAnalytics {
  final double totalRevenue;
  final double monthlyRevenue;
  final double weeklyRevenue;
  final double dailyRevenue;
  final int totalOrders;
  final int monthlyOrders;
  final int weeklyOrders;
  final int dailyOrders;
  final double averageOrderValue;
  final double conversionRate;
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final DateTime periodStart;
  final DateTime periodEnd;

  RevenueAnalytics({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.dailyRevenue,
    required this.totalOrders,
    required this.monthlyOrders,
    required this.weeklyOrders,
    required this.dailyOrders,
    required this.averageOrderValue,
    required this.conversionRate,
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.periodStart,
    required this.periodEnd,
  });

  factory RevenueAnalytics.fromFirestore(Map<String, dynamic> data) {
    return RevenueAnalytics(
      totalRevenue: (data['totalRevenue'] ?? 0.0).toDouble(),
      monthlyRevenue: (data['monthlyRevenue'] ?? 0.0).toDouble(),
      weeklyRevenue: (data['weeklyRevenue'] ?? 0.0).toDouble(),
      dailyRevenue: (data['dailyRevenue'] ?? 0.0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
      monthlyOrders: data['monthlyOrders'] ?? 0,
      weeklyOrders: data['weeklyOrders'] ?? 0,
      dailyOrders: data['dailyOrders'] ?? 0,
      averageOrderValue: (data['averageOrderValue'] ?? 0.0).toDouble(),
      conversionRate: (data['conversionRate'] ?? 0.0).toDouble(),
      totalCustomers: data['totalCustomers'] ?? 0,
      newCustomers: data['newCustomers'] ?? 0,
      returningCustomers: data['returningCustomers'] ?? 0,
      periodStart:
          (data['periodStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      periodEnd: (data['periodEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'weeklyRevenue': weeklyRevenue,
      'dailyRevenue': dailyRevenue,
      'totalOrders': totalOrders,
      'monthlyOrders': monthlyOrders,
      'weeklyOrders': weeklyOrders,
      'dailyOrders': dailyOrders,
      'averageOrderValue': averageOrderValue,
      'conversionRate': conversionRate,
      'totalCustomers': totalCustomers,
      'newCustomers': newCustomers,
      'returningCustomers': returningCustomers,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
    };
  }
}

class DailyRevenue {
  final DateTime date;
  final double revenue;
  final int orders;
  final int customers;
  final double averageOrderValue;

  DailyRevenue({
    required this.date,
    required this.revenue,
    required this.orders,
    required this.customers,
    required this.averageOrderValue,
  });

  factory DailyRevenue.fromFirestore(Map<String, dynamic> data) {
    return DailyRevenue(
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      revenue: (data['revenue'] ?? 0.0).toDouble(),
      orders: data['orders'] ?? 0,
      customers: data['customers'] ?? 0,
      averageOrderValue: (data['averageOrderValue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'revenue': revenue,
      'orders': orders,
      'customers': customers,
      'averageOrderValue': averageOrderValue,
    };
  }
}

class MonthlyRevenue {
  final String month;
  final int year;
  final double revenue;
  final int orders;
  final double growth;
  final int customers;

  MonthlyRevenue({
    required this.month,
    required this.year,
    required this.revenue,
    required this.orders,
    required this.growth,
    required this.customers,
  });

  factory MonthlyRevenue.fromFirestore(Map<String, dynamic> data) {
    return MonthlyRevenue(
      month: data['month'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      revenue: (data['revenue'] ?? 0.0).toDouble(),
      orders: data['orders'] ?? 0,
      growth: (data['growth'] ?? 0.0).toDouble(),
      customers: data['customers'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'month': month,
      'year': year,
      'revenue': revenue,
      'orders': orders,
      'growth': growth,
      'customers': customers,
    };
  }
}

class ProductPerformance {
  final String productId;
  final String productName;
  final String category;
  final double revenue;
  final int quantitySold;
  final double averageRating;
  final int reviewCount;
  final double profitMargin;

  ProductPerformance({
    required this.productId,
    required this.productName,
    required this.category,
    required this.revenue,
    required this.quantitySold,
    required this.averageRating,
    required this.reviewCount,
    required this.profitMargin,
  });

  factory ProductPerformance.fromFirestore(Map<String, dynamic> data) {
    return ProductPerformance(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      category: data['category'] ?? '',
      revenue: (data['revenue'] ?? 0.0).toDouble(),
      quantitySold: data['quantitySold'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      profitMargin: (data['profitMargin'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category,
      'revenue': revenue,
      'quantitySold': quantitySold,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'profitMargin': profitMargin,
    };
  }
}

class CustomerAnalytics {
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final int activeCustomers;
  final int inactiveCustomers;
  final double averageCustomerValue;
  final double customerRetentionRate;
  final List<CustomerSegment> segments;

  CustomerAnalytics({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.activeCustomers,
    required this.inactiveCustomers,
    required this.averageCustomerValue,
    required this.customerRetentionRate,
    required this.segments,
  });

  factory CustomerAnalytics.fromFirestore(Map<String, dynamic> data) {
    return CustomerAnalytics(
      totalCustomers: data['totalCustomers'] ?? 0,
      newCustomers: data['newCustomers'] ?? 0,
      returningCustomers: data['returningCustomers'] ?? 0,
      activeCustomers: data['activeCustomers'] ?? 0,
      inactiveCustomers: data['inactiveCustomers'] ?? 0,
      averageCustomerValue: (data['averageCustomerValue'] ?? 0.0).toDouble(),
      customerRetentionRate: (data['customerRetentionRate'] ?? 0.0).toDouble(),
      segments:
          (data['segments'] as List<dynamic>?)
              ?.map((e) => CustomerSegment.fromFirestore(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalCustomers': totalCustomers,
      'newCustomers': newCustomers,
      'returningCustomers': returningCustomers,
      'activeCustomers': activeCustomers,
      'inactiveCustomers': inactiveCustomers,
      'averageCustomerValue': averageCustomerValue,
      'customerRetentionRate': customerRetentionRate,
      'segments': segments.map((e) => e.toFirestore()).toList(),
    };
  }
}

class CustomerSegment {
  final String name;
  final int count;
  final double percentage;
  final double averageValue;

  CustomerSegment({
    required this.name,
    required this.count,
    required this.percentage,
    required this.averageValue,
  });

  factory CustomerSegment.fromFirestore(Map<String, dynamic> data) {
    return CustomerSegment(
      name: data['name'] ?? '',
      count: data['count'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      averageValue: (data['averageValue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'count': count,
      'percentage': percentage,
      'averageValue': averageValue,
    };
  }
}

class SalesChannel {
  final String channel;
  final double revenue;
  final int orders;
  final double percentage;

  SalesChannel({
    required this.channel,
    required this.revenue,
    required this.orders,
    required this.percentage,
  });

  factory SalesChannel.fromFirestore(Map<String, dynamic> data) {
    return SalesChannel(
      channel: data['channel'] ?? '',
      revenue: (data['revenue'] ?? 0.0).toDouble(),
      orders: data['orders'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'channel': channel,
      'revenue': revenue,
      'orders': orders,
      'percentage': percentage,
    };
  }
}
