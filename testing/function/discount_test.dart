import 'package:flutter_test/flutter_test.dart';

/// =============================================================================
/// TEST FILE 2: DISCOUNT MODEL TEST
/// =============================================================================
/// 
/// MỤC ĐÍCH: Kiểm tra các chức năng của mã giảm giá (Discount)
/// - Tính giảm giá theo phần trăm
/// - Tính giảm giá cố định
/// - Áp dụng giới hạn giảm giá tối đa
/// - Kiểm tra đơn hàng tối thiểu
/// - Kiểm tra mã hết hạn hoặc hết lượt
/// 
/// CÁCH CHẠY: flutter test testing/function/discount_test.dart

// ============== MOCK CLASSES ==============

enum DiscountType { percentage, fixed }
enum DiscountStatus { active, inactive, expired }

class DiscountModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final DiscountType type;
  final double value;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final int? usageLimit;
  final int usedCount;
  final DateTime startDate;
  final DateTime endDate;
  final DiscountStatus status;
  final List<String> applicableProducts;
  final List<String> applicableCategories;
  final bool isFirstOrderOnly;

  DiscountModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.usageLimit,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.applicableProducts = const [],
    this.applicableCategories = const [],
    this.isFirstOrderOnly = false,
  });

  bool get isActive =>
      status == DiscountStatus.active &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isUsageLimitReached =>
      usageLimit != null && usedCount >= usageLimit!;

  bool get canBeUsed => isActive && !isUsageLimitReached;

  String get formattedValue {
    if (type == DiscountType.percentage) {
      return '${value.toStringAsFixed(0)}%';
    } else {
      return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
    }
  }

  /// Tính toán số tiền giảm giá
  double calculateDiscount(double orderAmount) {
    if (!canBeUsed) return 0.0;
    if (minOrderAmount != null && orderAmount < minOrderAmount!) return 0.0;

    double discountAmount = 0.0;

    if (type == DiscountType.percentage) {
      discountAmount = orderAmount * (value / 100);
    } else {
      discountAmount = value;
    }

    // Áp dụng giới hạn giảm giá tối đa
    if (maxDiscountAmount != null && discountAmount > maxDiscountAmount!) {
      discountAmount = maxDiscountAmount!;
    }

    // Không được giảm nhiều hơn giá trị đơn hàng
    if (discountAmount > orderAmount) {
      discountAmount = orderAmount;
    }

    return discountAmount;
  }

  /// Kiểm tra xem có áp dụng được cho sản phẩm không
  bool isApplicableToProduct(String productId, String category) {
    if (!canBeUsed) return false;

    if (applicableProducts.isNotEmpty && !applicableProducts.contains(productId)) {
      return false;
    }

    if (applicableCategories.isNotEmpty && !applicableCategories.contains(category)) {
      return false;
    }

    return true;
  }
}

// ============== TEST CASES ==============

void main() {
  group('Discount - Mã giảm giá', () {
    /// TEST 6: Tính giảm giá theo phần trăm
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính giảm giá theo % cho đơn hàng.
    /// Ví dụ: Giảm 20% cho đơn 500,000đ = giảm 100,000đ.
    test('Test 6: Tính giảm giá theo phần trăm', () {
      final discount = DiscountModel(
        id: 'disc-001',
        code: 'SALE20',
        name: 'Giảm 20%',
        description: 'Giảm 20% toàn bộ đơn hàng',
        type: DiscountType.percentage,
        value: 20,
        usedCount: 0,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        status: DiscountStatus.active,
      );

      final orderAmount = 500000.0;
      final discountAmount = discount.calculateDiscount(orderAmount);

      expect(discountAmount, 100000); // 500000 * 20% = 100000
      expect(discount.formattedValue, '20%');
    });

    /// TEST 7: Tính giảm giá cố định (fixed amount)
    /// 
    /// MỤC ĐÍCH: Kiểm tra giảm giá theo số tiền cố định.
    /// Ví dụ: Giảm 50,000đ cho mọi đơn hàng.
    test('Test 7: Tính giảm giá cố định', () {
      final discount = DiscountModel(
        id: 'disc-002',
        code: 'FIXED50K',
        name: 'Giảm 50K',
        description: 'Giảm 50,000đ',
        type: DiscountType.fixed,
        value: 50000,
        usedCount: 0,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        status: DiscountStatus.active,
      );

      final discountAmount = discount.calculateDiscount(300000);
      expect(discountAmount, 50000);
    });

    /// TEST 8: Áp dụng giới hạn giảm giá tối đa
    /// 
    /// MỤC ĐÍCH: Kiểm tra khi giảm giá vượt quá maxDiscountAmount,
    /// hệ thống sẽ giới hạn số tiền giảm tối đa.
    test('Test 8: Áp dụng giới hạn giảm giá tối đa', () {
      final discount = DiscountModel(
        id: 'disc-003',
        code: 'MAX100K',
        name: 'Giảm 30% tối đa 100K',
        description: 'Giảm 30% nhưng tối đa 100,000đ',
        type: DiscountType.percentage,
        value: 30,
        maxDiscountAmount: 100000,
        usedCount: 0,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        status: DiscountStatus.active,
      );

      // 30% của 500000 = 150000, nhưng max là 100000
      final discountAmount = discount.calculateDiscount(500000);
      expect(discountAmount, 100000);
    });

    /// TEST 9: Từ chối mã giảm giá khi không đạt đơn tối thiểu
    /// 
    /// MỤC ĐÍCH: Kiểm tra khi đơn hàng không đạt giá trị tối thiểu,
    /// mã giảm giá sẽ không được áp dụng (trả về 0).
    test('Test 9: Từ chối mã giảm giá khi không đạt đơn tối thiểu', () {
      final discount = DiscountModel(
        id: 'disc-004',
        code: 'MIN300K',
        name: 'Giảm 50K cho đơn từ 300K',
        description: 'Đơn tối thiểu 300,000đ',
        type: DiscountType.fixed,
        value: 50000,
        minOrderAmount: 300000,
        usedCount: 0,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        status: DiscountStatus.active,
      );

      // Đơn 200000 < minOrderAmount 300000
      expect(discount.calculateDiscount(200000), 0);
      // Đơn 350000 >= minOrderAmount 300000
      expect(discount.calculateDiscount(350000), 50000);
    });

    /// TEST 10: Kiểm tra mã giảm giá hết hạn hoặc hết lượt
    /// 
    /// MỤC ĐÍCH: Kiểm tra các điều kiện làm mã giảm giá không thể sử dụng:
    /// - Hết hạn (endDate < now)
    /// - Đã dùng hết số lượt cho phép
    test('Test 10: Kiểm tra mã giảm giá hết hạn hoặc hết lượt', () {
      // Mã hết hạn
      final expiredDiscount = DiscountModel(
        id: 'disc-005',
        code: 'EXPIRED',
        name: 'Đã hết hạn',
        description: '',
        type: DiscountType.percentage,
        value: 10,
        usedCount: 0,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31), // Đã qua
        status: DiscountStatus.active,
      );

      expect(expiredDiscount.isExpired, true);
      expect(expiredDiscount.canBeUsed, false);

      // Mã đã dùng hết lượt
      final usedUpDiscount = DiscountModel(
        id: 'disc-006',
        code: 'USEDUP',
        name: 'Đã hết lượt',
        description: '',
        type: DiscountType.fixed,
        value: 30000,
        usageLimit: 100,
        usedCount: 100,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        status: DiscountStatus.active,
      );

      expect(usedUpDiscount.isUsageLimitReached, true);
      expect(usedUpDiscount.canBeUsed, false);
    });
  });
}
