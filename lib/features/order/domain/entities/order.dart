import 'order_status.dart';
import 'order_item.dart';

/// Order domain entity
class Order {
  final String id;
  final String userId;
  final String orderNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double discountAmount;
  final double shippingFee;
  final double totalAmount;
  final OrderStatus status;
  final String? statusNote;
  final String? deliveryAddressId;
  final Map<String, dynamic>? deliveryAddress;
  final String? paymentMethodId;
  final String? paymentMethodName;
  final String? paymentStatus;
  final String? paymentTransactionId;
  final String? discountCode;
  final String? discountName;
  final String? note;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryDate;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.shippingFee,
    required this.totalAmount,
    required this.status,
    this.statusNote,
    this.deliveryAddressId,
    this.deliveryAddress,
    this.paymentMethodId,
    this.paymentMethodName,
    this.paymentStatus,
    this.paymentTransactionId,
    this.discountCode,
    this.discountName,
    this.note,
    this.trackingNumber,
    this.estimatedDeliveryDate,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Business logic methods
  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get canTrack =>
      status == OrderStatus.shipping || status == OrderStatus.delivered;
  bool get canReview =>
      status == OrderStatus.delivered || status == OrderStatus.completed;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    List<OrderItem>? items,
    double? subtotal,
    double? discountAmount,
    double? shippingFee,
    double? totalAmount,
    OrderStatus? status,
    String? statusNote,
    String? deliveryAddressId,
    Map<String, dynamic>? deliveryAddress,
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
    String? discountCode,
    String? discountName,
    String? note,
    String? trackingNumber,
    DateTime? estimatedDeliveryDate,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      statusNote: statusNote ?? this.statusNote,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      discountCode: discountCode ?? this.discountCode,
      discountName: discountName ?? this.discountName,
      note: note ?? this.note,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderNumber == other.orderNumber;

  @override
  int get hashCode => id.hashCode ^ orderNumber.hashCode;
}
