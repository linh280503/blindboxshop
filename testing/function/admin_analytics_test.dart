import 'package:flutter_test/flutter_test.dart';

/// =============================================================================
/// TEST FILE 5: ADMIN ANALYTICS TEST
/// =============================================================================
/// 
/// MỤC ĐÍCH: Kiểm tra các chức năng phân tích doanh thu cho Admin
/// - Tính toán doanh thu theo ngày/tuần/tháng
/// - Tính giá trị đơn hàng trung bình
/// - Tính tỷ lệ chuyển đổi
/// - Tính tăng trưởng doanh thu
/// - Phân tích hiệu suất sản phẩm
/// 
/// CÁCH CHẠY: flutter test testing/function/admin_analytics_test.dart

// ============== MOCK CLASSES ==============

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
}

// ============== HELPER FUNCTIONS ==============

/// Tính giá trị đơn hàng trung bình
double calculateAverageOrderValue(double totalRevenue, int totalOrders) {
  if (totalOrders == 0) return 0;
  return totalRevenue / totalOrders;
}

/// Tính tỷ lệ chuyển đổi (conversion rate)
double calculateConversionRate(int orders, int visitors) {
  if (visitors == 0) return 0;
  return (orders / visitors) * 100;
}

/// Tính tỷ lệ tăng trưởng doanh thu
double calculateRevenueGrowth(double currentRevenue, double previousRevenue) {
  if (previousRevenue == 0) return currentRevenue > 0 ? 100.0 : 0.0;
  return ((currentRevenue - previousRevenue) / previousRevenue) * 100;
}

/// Tính tỷ lệ khách hàng quay lại
double calculateRetentionRate(int returningCustomers, int totalCustomers) {
  if (totalCustomers == 0) return 0;
  return (returningCustomers / totalCustomers) * 100;
}

/// Tính lợi nhuận ròng
double calculateNetProfit(double revenue, double cost, double operatingExpenses) {
  return revenue - cost - operatingExpenses;
}

/// Tính biên lợi nhuận (profit margin)
double calculateProfitMargin(double profit, double revenue) {
  if (revenue == 0) return 0;
  return (profit / revenue) * 100;
}

/// Tính doanh thu trung bình mỗi khách hàng (ARPU)
double calculateARPU(double totalRevenue, int totalCustomers) {
  if (totalCustomers == 0) return 0;
  return totalRevenue / totalCustomers;
}

/// Phân loại hiệu suất sản phẩm
String classifyProductPerformance(int quantitySold, double rating) {
  if (quantitySold >= 100 && rating >= 4.5) return 'Bestseller';
  if (quantitySold >= 50 && rating >= 4.0) return 'Popular';
  if (quantitySold >= 20 && rating >= 3.5) return 'Normal';
  if (quantitySold < 10) return 'Slow-moving';
  return 'Average';
}

/// Validate dữ liệu analytics
class AnalyticsValidationResult {
  final bool valid;
  final String? error;
  
  AnalyticsValidationResult({required this.valid, this.error});
}

AnalyticsValidationResult validateAnalyticsData({
  required double revenue,
  required int orders,
  required DateTime startDate,
  required DateTime endDate,
}) {
  if (revenue < 0) {
    return AnalyticsValidationResult(valid: false, error: 'Revenue cannot be negative');
  }
  if (orders < 0) {
    return AnalyticsValidationResult(valid: false, error: 'Orders cannot be negative');
  }
  if (endDate.isBefore(startDate)) {
    return AnalyticsValidationResult(valid: false, error: 'End date must be after start date');
  }
  return AnalyticsValidationResult(valid: true);
}

// ============== TEST CASES ==============

void main() {
  group('Admin Analytics - Phân tích doanh thu', () {
    /// TEST 1: Tính giá trị đơn hàng trung bình
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính AOV (Average Order Value)
    /// AOV = Tổng doanh thu / Số đơn hàng
    test('Test 1: Tính giá trị đơn hàng trung bình (AOV)', () {
      // 10,000,000 VND / 25 orders = 400,000 VND/order
      expect(calculateAverageOrderValue(10000000, 25), 400000);
      
      // 5,500,000 VND / 11 orders = 500,000 VND/order
      expect(calculateAverageOrderValue(5500000, 11), 500000);
      
      // Edge case: 0 orders
      expect(calculateAverageOrderValue(0, 0), 0);
    });

    /// TEST 2: Tính tỷ lệ chuyển đổi
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính conversion rate
    /// CR = (Số đơn hàng / Số visitors) * 100%
    test('Test 2: Tính tỷ lệ chuyển đổi (Conversion Rate)', () {
      // 50 orders / 1000 visitors = 5%
      expect(calculateConversionRate(50, 1000), 5.0);
      
      // 30 orders / 500 visitors = 6%
      expect(calculateConversionRate(30, 500), 6.0);
      
      // Edge case: 0 visitors
      expect(calculateConversionRate(0, 0), 0);
    });

    /// TEST 3: Tính tỷ lệ tăng trưởng doanh thu
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính revenue growth
    /// Growth = ((Current - Previous) / Previous) * 100%
    test('Test 3: Tính tỷ lệ tăng trưởng doanh thu', () {
      // Tăng từ 10M lên 12M = 20% growth
      expect(calculateRevenueGrowth(12000000, 10000000), 20.0);
      
      // Giảm từ 10M xuống 8M = -20% growth
      expect(calculateRevenueGrowth(8000000, 10000000), -20.0);
      
      // Không đổi = 0% growth
      expect(calculateRevenueGrowth(10000000, 10000000), 0.0);
      
      // Từ 0 lên có doanh thu = 100% growth
      expect(calculateRevenueGrowth(5000000, 0), 100.0);
    });

    /// TEST 4: Tính tỷ lệ khách hàng quay lại
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính customer retention rate
    test('Test 4: Tính tỷ lệ khách hàng quay lại (Retention Rate)', () {
      // 30 returning / 100 total = 30%
      expect(calculateRetentionRate(30, 100), 30.0);
      
      // 75 returning / 150 total = 50%
      expect(calculateRetentionRate(75, 150), 50.0);
      
      // Edge case: 0 customers
      expect(calculateRetentionRate(0, 0), 0);
    });

    /// TEST 5: Tính lợi nhuận ròng và biên lợi nhuận
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính net profit và profit margin
    test('Test 5: Tính lợi nhuận ròng và biên lợi nhuận', () {
      // Revenue: 100M, Cost: 60M, Expenses: 20M => Profit: 20M
      final profit = calculateNetProfit(100000000, 60000000, 20000000);
      expect(profit, 20000000);
      
      // Profit margin: 20M / 100M = 20%
      expect(calculateProfitMargin(profit, 100000000), 20.0);
      
      // Edge case: 0 revenue
      expect(calculateProfitMargin(0, 0), 0);
    });
  });

  group('Admin Analytics - Phân tích khách hàng', () {
    /// TEST 6: Tính doanh thu trung bình mỗi khách hàng (ARPU)
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính Average Revenue Per User
    test('Test 6: Tính ARPU (Average Revenue Per User)', () {
      // 50,000,000 VND / 100 customers = 500,000 VND/customer
      expect(calculateARPU(50000000, 100), 500000);
      
      // 25,000,000 VND / 50 customers = 500,000 VND/customer
      expect(calculateARPU(25000000, 50), 500000);
      
      // Edge case: 0 customers
      expect(calculateARPU(0, 0), 0);
    });

    /// TEST 7: Tạo đối tượng CustomerSegment
    /// 
    /// MỤC ĐÍCH: Kiểm tra việc tạo và tính toán phân khúc khách hàng
    test('Test 7: Tạo phân khúc khách hàng (Customer Segment)', () {
      final vipSegment = CustomerSegment(
        name: 'VIP',
        count: 50,
        percentage: 10.0,
        averageValue: 2000000,
      );

      final regularSegment = CustomerSegment(
        name: 'Regular',
        count: 300,
        percentage: 60.0,
        averageValue: 500000,
      );

      expect(vipSegment.name, 'VIP');
      expect(vipSegment.count, 50);
      expect(vipSegment.percentage, 10.0);
      expect(regularSegment.averageValue, 500000);
    });
  });

  group('Admin Analytics - Phân tích sản phẩm', () {
    /// TEST 8: Phân loại hiệu suất sản phẩm
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic phân loại sản phẩm theo số lượng bán và rating
    test('Test 8: Phân loại hiệu suất sản phẩm', () {
      // Bestseller: sold >= 100, rating >= 4.5
      expect(classifyProductPerformance(150, 4.8), 'Bestseller');
      
      // Popular: sold >= 50, rating >= 4.0
      expect(classifyProductPerformance(80, 4.2), 'Popular');
      
      // Normal: sold >= 20, rating >= 3.5
      expect(classifyProductPerformance(25, 3.7), 'Normal');
      
      // Slow-moving: sold < 10
      expect(classifyProductPerformance(5, 4.5), 'Slow-moving');
    });

    /// TEST 9: Tạo đối tượng ProductPerformance
    /// 
    /// MỤC ĐÍCH: Kiểm tra việc tạo báo cáo hiệu suất sản phẩm
    test('Test 9: Tạo báo cáo hiệu suất sản phẩm', () {
      final product = ProductPerformance(
        productId: 'prod-001',
        productName: 'Labubu Series 5',
        category: 'labubu',
        revenue: 35000000,
        quantitySold: 100,
        averageRating: 4.8,
        reviewCount: 85,
        profitMargin: 35.0,
      );

      expect(product.productName, 'Labubu Series 5');
      expect(product.revenue, 35000000);
      expect(product.quantitySold, 100);
      expect(product.averageRating, 4.8);
      expect(product.profitMargin, 35.0);
    });

    /// TEST 10: Tính doanh thu trung bình mỗi sản phẩm
    /// 
    /// MỤC ĐÍCH: Kiểm tra tính toán revenue per product sold
    test('Test 10: Tính doanh thu trung bình mỗi sản phẩm', () {
      final product = ProductPerformance(
        productId: 'prod-002',
        productName: 'Dimoo World',
        category: 'dimoo',
        revenue: 28000000, // 28M VND
        quantitySold: 100,
        averageRating: 4.5,
        reviewCount: 60,
        profitMargin: 30.0,
      );

      final avgRevenuePerProduct = product.revenue / product.quantitySold;
      expect(avgRevenuePerProduct, 280000); // 280,000 VND/product
    });
  });

  group('Admin Analytics - Validation', () {
    /// TEST 11: Validate dữ liệu analytics hợp lệ
    /// 
    /// MỤC ĐÍCH: Kiểm tra validation dữ liệu đầu vào cho báo cáo
    test('Test 11: Validate dữ liệu analytics hợp lệ', () {
      final result = validateAnalyticsData(
        revenue: 10000000,
        orders: 50,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 31),
      );

      expect(result.valid, true);
      expect(result.error, null);
    });

    /// TEST 12: Từ chối dữ liệu analytics không hợp lệ
    /// 
    /// MỤC ĐÍCH: Kiểm tra validation reject dữ liệu sai
    test('Test 12: Từ chối dữ liệu analytics không hợp lệ', () {
      // Revenue âm
      final negativeRevenue = validateAnalyticsData(
        revenue: -1000000,
        orders: 10,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 31),
      );
      expect(negativeRevenue.valid, false);
      expect(negativeRevenue.error, 'Revenue cannot be negative');

      // Orders âm
      final negativeOrders = validateAnalyticsData(
        revenue: 1000000,
        orders: -5,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 31),
      );
      expect(negativeOrders.valid, false);
      expect(negativeOrders.error, 'Orders cannot be negative');

      // End date trước start date
      final invalidDate = validateAnalyticsData(
        revenue: 1000000,
        orders: 10,
        startDate: DateTime(2025, 1, 31),
        endDate: DateTime(2025, 1, 1),
      );
      expect(invalidDate.valid, false);
      expect(invalidDate.error, 'End date must be after start date');
    });
  });
}
