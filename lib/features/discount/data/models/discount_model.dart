import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/discount_type.dart';
import '../../domain/entities/discount_status.dart';

class DiscountModel {
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
    required this.applicableProducts,
    required this.applicableCategories,
    required this.isFirstOrderOnly,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiscountModel(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: DiscountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DiscountType.percentage,
      ),
      value: (data['value'] ?? 0.0).toDouble(),
      minOrderAmount: data['minOrderAmount']?.toDouble(),
      maxDiscountAmount: data['maxDiscountAmount']?.toDouble(),
      usageLimit: data['usageLimit'],
      usedCount: data['usedCount'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: DiscountStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => DiscountStatus.active,
      ),
      applicableProducts: List<String>.from(data['applicableProducts'] ?? []),
      applicableCategories: List<String>.from(
        data['applicableCategories'] ?? [],
      ),
      isFirstOrderOnly: data['isFirstOrderOnly'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'type': type.name,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'applicableProducts': applicableProducts,
      'applicableCategories': applicableCategories,
      'isFirstOrderOnly': isFirstOrderOnly,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DiscountModel copyWith({
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
    return DiscountModel(
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

  // Helper methods
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

  String get formattedMinOrderAmount {
    if (minOrderAmount == null) return '';
    return '${minOrderAmount!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

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
}
