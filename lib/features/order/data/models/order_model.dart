import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final OrderType orderType;
  final int? boxSize;
  final int? setSize;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.orderType,
    this.boxSize,
    this.setSize,
    required this.totalPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      orderType: OrderType.values.firstWhere(
        (e) => e.name == data['orderType'],
        orElse: () => OrderType.single,
      ),
      boxSize: data['boxSize'],
      setSize: data['setSize'],
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'orderType': orderType.name,
      'boxSize': boxSize,
      'setSize': setSize,
      'totalPrice': totalPrice,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    OrderType? orderType,
    int? boxSize,
    int? setSize,
    double? totalPrice,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      orderType: orderType ?? this.orderType,
      boxSize: boxSize ?? this.boxSize,
      setSize: setSize ?? this.setSize,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class OrderModel {
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

  OrderModel({
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

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0.0).toDouble(),
      shippingFee: (data['shippingFee'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      statusNote: data['statusNote'],
      deliveryAddressId: data['deliveryAddressId'],
      deliveryAddress: data['deliveryAddress'] != null
          ? Map<String, dynamic>.from(data['deliveryAddress'])
          : null,
      paymentMethodId: data['paymentMethodId'],
      paymentMethodName: data['paymentMethodName'],
      paymentStatus: data['paymentStatus'],
      paymentTransactionId: data['paymentTransactionId'],
      discountCode: data['discountCode'],
      discountName: data['discountName'],
      note: data['note'],
      trackingNumber: data['trackingNumber'],
      estimatedDeliveryDate: data['estimatedDeliveryDate'] != null
          ? (data['estimatedDeliveryDate'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'status': status.name,
      'statusNote': statusNote,
      'deliveryAddressId': deliveryAddressId,
      'deliveryAddress': deliveryAddress,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'paymentStatus': paymentStatus,
      'paymentTransactionId': paymentTransactionId,
      'discountCode': discountCode,
      'discountName': discountName,
      'note': note,
      'trackingNumber': trackingNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate != null
          ? Timestamp.fromDate(estimatedDeliveryDate!)
          : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({
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
    return OrderModel(
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

  // Helper methods
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.shipping:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.returned:
        return 'Đã trả hàng';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.shipping:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.returned:
        return AppColors.textSecondary;
    }
  }

  bool get canCancel {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  bool get canTrack {
    return status == OrderStatus.shipping || status == OrderStatus.delivered;
  }

  bool get canReview {
    return status == OrderStatus.delivered || status == OrderStatus.completed;
  }

  String get formattedTotalAmount {
    return '${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String get formattedSubtotal {
    return '${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String get formattedDiscountAmount {
    return '${discountAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String get formattedShippingFee {
    return '${shippingFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
