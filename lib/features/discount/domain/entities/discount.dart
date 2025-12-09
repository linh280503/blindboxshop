import 'discount_type.dart';
import 'discount_status.dart';

class Discount {
  final String id;
  final String code;
  final String name;
  final String description;
  final DiscountType type;
  final double value; // Phần trăm hoặc số tiền
  final double? minOrderAmount; // Đơn hàng tối thiểu
  final double? maxDiscountAmount; // Giảm giá tối đa
  final int? usageLimit; // Giới hạn số lần sử dụng
  final int usedCount; // Số lần đã sử dụng
  final DateTime startDate;
  final DateTime endDate;
  final DiscountStatus status;
  final List<String>
  applicableProducts; // Danh sách sản phẩm áp dụng (rỗng = tất cả)
  final List<String> applicableCategories; // Danh sách danh mục áp dụng
  final bool isFirstOrderOnly; // Chỉ áp dụng cho đơn hàng đầu tiên
  final DateTime createdAt;
  final DateTime updatedAt;

  const Discount({
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
    required this.applicableProducts,
    required this.applicableCategories,
    required this.isFirstOrderOnly,
    required this.createdAt,
    required this.updatedAt,
  });

  // Business logic
  bool get isActive =>
      status == DiscountStatus.active &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isUsageLimitReached =>
      usageLimit != null && usedCount >= usageLimit!;

  bool get canBeUsed => isActive && !isUsageLimitReached;

  // Tính toán số tiền giảm giá
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

  // Kiểm tra xem có áp dụng được cho sản phẩm không
  bool isApplicableToProduct(String productId, String category) {
    if (!canBeUsed) return false;

    // Kiểm tra danh sách sản phẩm cụ thể
    if (applicableProducts.isNotEmpty &&
        !applicableProducts.contains(productId)) {
      return false;
    }

    // Kiểm tra danh mục
    if (applicableCategories.isNotEmpty &&
        !applicableCategories.contains(category)) {
      return false;
    }

    return true;
  }

  Discount copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    DiscountType? type,
    double? value,
    double? minOrderAmount,
    double? maxDiscountAmount,
    int? usageLimit,
    int? usedCount,
    DateTime? startDate,
    DateTime? endDate,
    DiscountStatus? status,
    List<String>? applicableProducts,
    List<String>? applicableCategories,
    bool? isFirstOrderOnly,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Discount(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      isFirstOrderOnly: isFirstOrderOnly ?? this.isFirstOrderOnly,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Discount && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
