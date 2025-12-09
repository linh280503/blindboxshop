import '../entities/order.dart';
import '../entities/order_status.dart';

abstract class OrderRepository {
  Future<Order> createOrder(Order order);
  Future<Order?> getOrderById(String orderId);
  Future<Order?> getOrderByNumber(String orderNumber);
  Future<List<Order>> getUserOrders(String userId);
  Future<List<Order>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  });
  Future<List<Order>> getOrdersByStatus(String userId, OrderStatus status);
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
  Future<List<Order>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getUserOrderStats(String userId);
  Future<void> deleteOrder(String orderId);

  // Analytics methods
  Future<List<Map<String, dynamic>>> getBestSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Map<String, dynamic>>> getSlowSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Streams
  Stream<Order?> watchOrder(String orderId);
  Stream<List<Order>> watchUserOrders(String userId);
  Stream<List<Order>> watchOrdersByStatus(String userId, OrderStatus status);
  Stream<List<Order>> watchAllOrders();
}
