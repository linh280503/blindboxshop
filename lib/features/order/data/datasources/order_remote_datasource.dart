// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../../domain/entities/order_status.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel?> getOrderById(String orderId);
  Future<OrderModel?> getOrderByNumber(String orderNumber);
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<List<OrderModel>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  });
  Future<List<OrderModel>> getOrdersByStatus(String userId, OrderStatus status);
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  });
  Future<void> cancelOrder(String orderId, {String? reason});
  Future<void> confirmOrder(String orderId);
  Future<void> startPreparingOrder(String orderId);
  Future<void> startShippingOrder(String orderId, {String? trackingNumber});
  Future<void> completeDelivery(String orderId);
  Future<void> completeOrder(String orderId);
  Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  });
  Future<List<OrderModel>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getUserOrderStats(String userId);
  Future<void> deleteOrder(String orderId);

  // Streams
  Stream<OrderModel?> watchOrder(String orderId);
  Stream<List<OrderModel>> watchUserOrders(String userId);
  Stream<List<OrderModel>> watchOrdersByStatus(
    String userId,
    OrderStatus status,
  );
  Stream<List<OrderModel>> watchAllOrders();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _ordersCollection = 'orders';

  OrderRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  /// Generate order number
  String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
  }

  /// Update user order stats
  Future<void> _updateUserOrderStats(String userId) async {
    try {
      final orders = await getUserOrders(userId);
      final totalOrders = orders.length;

      // Calculate total spent from valid orders (not cancelled or returned)
      final totalSpent = orders
          .where(
            (order) =>
                order.status != OrderStatus.cancelled &&
                order.status != OrderStatus.returned,
          )
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      // Calculate points: 1 point for every 1000 VND spent
      // You can adjust this ratio as needed
      final points = (totalSpent / 1000).floor();

      await firestore.collection('users').doc(userId).update({
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
        'points': points,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - stats update is not critical
      print('Error updating user stats: $e');
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final docRef = await firestore
          .collection(_ordersCollection)
          .add(order.toFirestore());

      final createdOrder = order.copyWith(
        id: docRef.id,
        orderNumber: _generateOrderNumber(),
      );

      await firestore.collection(_ordersCollection).doc(docRef.id).update({
        'orderNumber': createdOrder.orderNumber,
      });

      await _updateUserOrderStats(order.userId);

      return createdOrder;
    } catch (e) {
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();

      if (!doc.exists) return null;

      return OrderModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderByNumber(String orderNumber) async {
    try {
      final query = await firestore
          .collection(_ordersCollection)
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return OrderModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng: $e');
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final query = await firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đơn hàng: $e');
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  }) async {
    try {
      Query query = firestore.collection(_ordersCollection);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy tất cả đơn hàng: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(
    String userId,
    OrderStatus status,
  ) async {
    try {
      final query = await firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng theo trạng thái: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (statusNote != null) updateData['statusNote'] = statusNote;
      if (trackingNumber != null) updateData['trackingNumber'] = trackingNumber;

      if (status == OrderStatus.delivered) {
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update(updateData);

      if (status == OrderStatus.delivered || status == OrderStatus.completed) {
        final order = await getOrderById(orderId);
        if (order != null) {
          await _updateUserOrderStats(order.userId);
        }
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái đơn hàng: $e');
    }
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      final updateData = <String, dynamic>{
        'status': OrderStatus.cancelled.name,
        'statusNote': reason ?? 'Khách hàng hủy đơn hàng',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      throw Exception('Lỗi hủy đơn hàng: $e');
    }
  }

  @override
  Future<void> confirmOrder(String orderId) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.confirmed,
        statusNote: 'Đơn hàng đã được xác nhận',
      );
    } catch (e) {
      throw Exception('Lỗi xác nhận đơn hàng: $e');
    }
  }

  @override
  Future<void> startPreparingOrder(String orderId) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.preparing,
        statusNote: 'Đang chuẩn bị đơn hàng',
      );
    } catch (e) {
      throw Exception('Lỗi bắt đầu chuẩn bị đơn hàng: $e');
    }
  }

  @override
  Future<void> startShippingOrder(
    String orderId, {
    String? trackingNumber,
  }) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.shipping,
        statusNote: 'Đơn hàng đang được giao',
        trackingNumber: trackingNumber,
      );
    } catch (e) {
      throw Exception('Lỗi bắt đầu giao hàng: $e');
    }
  }

  @override
  Future<void> completeDelivery(String orderId) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.delivered,
        statusNote: 'Đơn hàng đã được giao thành công',
      );
    } catch (e) {
      throw Exception('Lỗi hoàn thành giao hàng: $e');
    }
  }

  @override
  Future<void> completeOrder(String orderId) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.completed,
        statusNote: 'Đơn hàng đã hoàn thành',
      );
    } catch (e) {
      throw Exception('Lỗi hoàn thành đơn hàng: $e');
    }
  }

  @override
  Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (paymentMethodId != null) {
        updateData['paymentMethodId'] = paymentMethodId;
      }
      if (paymentMethodName != null) {
        updateData['paymentMethodName'] = paymentMethodName;
      }
      if (paymentStatus != null) updateData['paymentStatus'] = paymentStatus;
      if (paymentTransactionId != null) {
        updateData['paymentTransactionId'] = paymentTransactionId;
      }

      await firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      throw Exception('Lỗi cập nhật thông tin thanh toán: $e');
    }
  }

  @override
  Future<List<OrderModel>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query queryRef = firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId);

      if (status != null) {
        queryRef = queryRef.where('status', isEqualTo: status.name);
      }

      if (startDate != null) {
        queryRef = queryRef.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        queryRef = queryRef.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await queryRef
          .orderBy('createdAt', descending: true)
          .get();

      List<OrderModel> orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      if (query != null && query.isNotEmpty) {
        orders = orders.where((order) {
          return order.orderNumber.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              order.items.any(
                (item) => item.productName.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              );
        }).toList();
      }

      return orders;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm đơn hàng: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    try {
      final orders = await getUserOrders(userId);

      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) => o.status == OrderStatus.pending)
          .length;
      final confirmedOrders = orders
          .where((o) => o.status == OrderStatus.confirmed)
          .length;
      final preparingOrders = orders
          .where((o) => o.status == OrderStatus.preparing)
          .length;
      final shippingOrders = orders
          .where((o) => o.status == OrderStatus.shipping)
          .length;
      final deliveredOrders = orders
          .where((o) => o.status == OrderStatus.delivered)
          .length;
      final completedOrders = orders
          .where((o) => o.status == OrderStatus.completed)
          .length;
      final cancelledOrders = orders
          .where((o) => o.status == OrderStatus.cancelled)
          .length;
      final returnedOrders = orders
          .where((o) => o.status == OrderStatus.returned)
          .length;

      final totalRevenue = orders
          .where(
            (o) =>
                o.status != OrderStatus.cancelled &&
                o.status != OrderStatus.returned,
          )
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      final averageOrderValue = totalOrders > 0
          ? totalRevenue / totalOrders
          : 0.0;

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'confirmedOrders': confirmedOrders,
        'preparingOrders': preparingOrders,
        'shippingOrders': shippingOrders,
        'deliveredOrders': deliveredOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'returnedOrders': returnedOrders,
        'totalRevenue': totalRevenue,
        'averageOrderValue': averageOrderValue,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê đơn hàng: $e');
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      await firestore.collection(_ordersCollection).doc(orderId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa đơn hàng: $e');
    }
  }

  @override
  Stream<OrderModel?> watchOrder(String orderId) {
    return firestore.collection(_ordersCollection).doc(orderId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) return null;
        return OrderModel.fromFirestore(snapshot);
      },
    );
  }

  @override
  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<OrderModel>> watchOrdersByStatus(
    String userId,
    OrderStatus status,
  ) {
    return firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<OrderModel>> watchAllOrders() {
    return firestore
        .collection(_ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }
}
