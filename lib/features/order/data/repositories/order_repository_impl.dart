import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../mappers/order_mapper.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Order> createOrder(Order order) async {
    final model = OrderMapper.toModel(order);
    final createdModel = await remoteDataSource.createOrder(model);
    return OrderMapper.toEntity(createdModel);
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    final model = await remoteDataSource.getOrderById(orderId);
    return model != null ? OrderMapper.toEntity(model) : null;
  }

  @override
  Future<Order?> getOrderByNumber(String orderNumber) async {
    final model = await remoteDataSource.getOrderByNumber(orderNumber);
    return model != null ? OrderMapper.toEntity(model) : null;
  }

  @override
  Future<List<Order>> getUserOrders(String userId) async {
    final models = await remoteDataSource.getUserOrders(userId);
    return OrderMapper.toEntityList(models);
  }

  @override
  Future<List<Order>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  }) async {
    final models = await remoteDataSource.getAllOrders(
      startDate: startDate,
      endDate: endDate,
      status: status,
      limit: limit,
    );
    return OrderMapper.toEntityList(models);
  }

  @override
  Future<List<Order>> getOrdersByStatus(
    String userId,
    OrderStatus status,
  ) async {
    final models = await remoteDataSource.getOrdersByStatus(userId, status);
    return OrderMapper.toEntityList(models);
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  }) async {
    await remoteDataSource.updateOrderStatus(
      orderId,
      status,
      statusNote: statusNote,
      trackingNumber: trackingNumber,
    );
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await remoteDataSource.cancelOrder(orderId, reason: reason);
  }

  @override
  Future<void> confirmOrder(String orderId) async {
    await remoteDataSource.confirmOrder(orderId);
  }

  @override
  Future<void> startPreparingOrder(String orderId) async {
    await remoteDataSource.startPreparingOrder(orderId);
  }

  @override
  Future<void> startShippingOrder(
    String orderId, {
    String? trackingNumber,
  }) async {
    await remoteDataSource.startShippingOrder(
      orderId,
      trackingNumber: trackingNumber,
    );
  }

  @override
  Future<void> completeDelivery(String orderId) async {
    await remoteDataSource.completeDelivery(orderId);
  }

  @override
  Future<void> completeOrder(String orderId) async {
    await remoteDataSource.completeOrder(orderId);
  }

  @override
  Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  }) async {
    await remoteDataSource.updatePaymentInfo(
      orderId,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName,
      paymentStatus: paymentStatus,
      paymentTransactionId: paymentTransactionId,
    );
  }

  @override
  Future<List<Order>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final models = await remoteDataSource.searchOrders(
      userId,
      query: query,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
    return OrderMapper.toEntityList(models);
  }

  @override
  Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    return await remoteDataSource.getUserOrderStats(userId);
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await remoteDataSource.deleteOrder(orderId);
  }

  @override
  Stream<Order?> watchOrder(String orderId) {
    return remoteDataSource
        .watchOrder(orderId)
        .map((model) => model != null ? OrderMapper.toEntity(model) : null);
  }

  @override
  Stream<List<Order>> watchUserOrders(String userId) {
    return remoteDataSource
        .watchUserOrders(userId)
        .map((models) => OrderMapper.toEntityList(models));
  }

  @override
  Stream<List<Order>> watchOrdersByStatus(String userId, OrderStatus status) {
    return remoteDataSource
        .watchOrdersByStatus(userId, status)
        .map((models) => OrderMapper.toEntityList(models));
  }

  @override
  Stream<List<Order>> watchAllOrders() {
    return remoteDataSource.watchAllOrders().map(
      (models) => OrderMapper.toEntityList(models),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getBestSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orders = await getAllOrders(
        startDate: startDate,
        endDate: endDate,
        status: OrderStatus.delivered,
      );

      final Map<String, Map<String, dynamic>> productStats = {};

      for (final order in orders) {
        for (final item in order.items) {
          if (productStats.containsKey(item.productId)) {
            productStats[item.productId]!['quantity'] += item.quantity;
            productStats[item.productId]!['revenue'] +=
                item.price * item.quantity;
          } else {
            productStats[item.productId] = {
              'productId': item.productId,
              'productName': item.productName,
              'productImage': item.productImage,
              'quantity': item.quantity,
              'revenue': item.price * item.quantity,
            };
          }
        }
      }

      final sortedProducts = productStats.values.toList()
        ..sort(
          (a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int),
        );

      return sortedProducts.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSlowSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orders = await getAllOrders(
        startDate: startDate,
        endDate: endDate,
        status: OrderStatus.delivered,
      );

      final Map<String, Map<String, dynamic>> productStats = {};

      for (final order in orders) {
        for (final item in order.items) {
          if (productStats.containsKey(item.productId)) {
            productStats[item.productId]!['quantity'] += item.quantity;
          } else {
            productStats[item.productId] = {
              'productId': item.productId,
              'productName': item.productName,
              'productImage': item.productImage,
              'quantity': item.quantity,
            };
          }
        }
      }

      final List<Map<String, dynamic>> products = productStats.values.toList();
      // Sort ascending by quantity (slow sellers first)
      products.sort(
        (a, b) => (a['quantity'] as int).compareTo(b['quantity'] as int),
      );
      return products.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orders = await getAllOrders(
        startDate: startDate,
        endDate: endDate,
        status: OrderStatus.delivered,
      );

      final Map<String, Map<String, dynamic>> customerStats = {};

      for (final order in orders) {
        if (customerStats.containsKey(order.userId)) {
          customerStats[order.userId]!['orderCount'] += 1;
          customerStats[order.userId]!['totalSpent'] += order.totalAmount;
        } else {
          customerStats[order.userId] = {
            'userId': order.userId,
            'orderCount': 1,
            'totalSpent': order.totalAmount,
          };
        }
      }

      final sortedCustomers = customerStats.values.toList()
        ..sort(
          (a, b) =>
              (b['totalSpent'] as double).compareTo(a['totalSpent'] as double),
        );

      return sortedCustomers.take(limit).toList();
    } catch (e) {
      return [];
    }
  }
}
