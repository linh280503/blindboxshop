import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/order_model.dart';
import '../../data/mappers/order_mapper.dart';
import '../../data/di/order_providers.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/get_user_orders.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/get_order_by_id.dart';
import '../../domain/usecases/update_order_status.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/entities/order_status.dart';

// Orders state provider
final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderModel>>((
  ref,
) {
  final repo = ref.watch(orderRepositoryProvider);
  final getUserOrders = ref.watch(getUserOrdersProvider);
  final createOrderUC = ref.watch(createOrderProvider);
  final updateOrderStatusUC = ref.watch(updateOrderStatusProvider);
  final cancelOrderUC = ref.watch(cancelOrderProvider);
  return OrdersNotifier(
    repository: repo,
    getUserOrdersUC: getUserOrders,
    createOrderUC: createOrderUC,
    updateOrderStatusUC: updateOrderStatusUC,
    cancelOrderUC: cancelOrderUC,
  );
});

// Order history provider
final orderHistoryProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((order) => order.status != OrderStatus.pending).toList();
});

// Pending orders provider
final pendingOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((order) => order.status == OrderStatus.pending).toList();
});

// Orders by status provider
final ordersByStatusProvider = Provider.family<List<OrderModel>, String>((
  ref,
  status,
) {
  final orders = ref.watch(ordersProvider);
  if (status == 'Tất cả') {
    return orders;
  }
  return orders
      .where(
        (order) =>
            order.status.toString().split('.').last == status.toLowerCase(),
      )
      .toList();
});

// Current order provider
final currentOrderProvider =
    StateNotifierProvider<CurrentOrderNotifier, OrderModel?>((ref) {
      final repo = ref.watch(orderRepositoryProvider);
      final getOrderById = ref.watch(getOrderByIdProvider);
      return CurrentOrderNotifier(
        repository: repo,
        getOrderByIdUC: getOrderById,
      );
    });

// Order statistics provider (local)
final localOrderStatsProvider = Provider<OrderStats>((ref) {
  final orders = ref.watch(ordersProvider);
  return OrderStats.fromOrders(orders);
});

class OrderStats {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double averageOrderValue;

  OrderStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
  });

  factory OrderStats.fromOrders(List<OrderModel> orders) {
    final totalOrders = orders.length;
    final pendingOrders = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final confirmedOrders = orders
        .where((o) => o.status == OrderStatus.confirmed)
        .length;
    final shippedOrders = orders
        .where((o) => o.status == OrderStatus.shipping)
        .length;
    final deliveredOrders = orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;
    final cancelledOrders = orders
        .where((o) => o.status == OrderStatus.cancelled)
        .length;

    final totalRevenue = orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (total, order) => total + order.totalAmount);

    final averageOrderValue = totalOrders > 0
        ? totalRevenue / totalOrders
        : 0.0;

    return OrderStats(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      confirmedOrders: confirmedOrders,
      shippedOrders: shippedOrders,
      deliveredOrders: deliveredOrders,
      cancelledOrders: cancelledOrders,
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
    );
  }
}

class OrdersNotifier extends StateNotifier<List<OrderModel>> {
  final OrderRepository repository;
  final GetUserOrders getUserOrdersUC;
  final CreateOrder createOrderUC;
  final UpdateOrderStatus updateOrderStatusUC;
  final CancelOrder cancelOrderUC;

  OrdersNotifier({
    required this.repository,
    required this.getUserOrdersUC,
    required this.createOrderUC,
    required this.updateOrderStatusUC,
    required this.cancelOrderUC,
  }) : super([]);

  /// Lấy danh sách đơn hàng của user
  Future<void> loadUserOrders(String userId) async {
    try {
      final orderEntities = await getUserOrdersUC(userId);
      state = OrderMapper.toModelList(orderEntities);
    } catch (e) {
      NotificationService.showError(
        'Lỗi tải danh sách đơn hàng: ${e.toString()}',
      );
    }
  }

  /// Lấy đơn hàng theo trạng thái
  Future<void> loadOrdersByStatus(String userId, OrderStatus status) async {
    try {
      final orderEntities = await repository.getOrdersByStatus(userId, status);
      state = OrderMapper.toModelList(orderEntities);
    } catch (e) {
      NotificationService.showError(
        'Lỗi tải đơn hàng theo trạng thái: ${e.toString()}',
      );
    }
  }

  /// Tìm kiếm đơn hàng
  Future<void> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orderEntities = await repository.searchOrders(
        userId,
        query: query,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      state = OrderMapper.toModelList(orderEntities);
    } catch (e) {
      NotificationService.showError('Lỗi tìm kiếm đơn hàng: ${e.toString()}');
    }
  }

  /// Tạo đơn hàng mới
  Future<void> createOrder(OrderModel order) async {
    try {
      final orderEntity = OrderMapper.toEntity(order);
      final createdOrderEntity = await createOrderUC(orderEntity);
      final createdOrderModel = OrderMapper.toModel(createdOrderEntity);
      state = [createdOrderModel, ...state];
      NotificationService.showSuccess('Tạo đơn hàng thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi tạo đơn hàng: ${e.toString()}');
    }
  }

  /// Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  }) async {
    try {
      await updateOrderStatusUC(
        UpdateOrderStatusParams(
          orderId: orderId,
          status: status,
          statusNote: statusNote,
          trackingNumber: trackingNumber,
        ),
      );

      // Cập nhật local state
      final index = state.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrders = List<OrderModel>.from(state);
        updatedOrders[index] = updatedOrders[index].copyWith(
          status: status,
          statusNote: statusNote,
          trackingNumber: trackingNumber,
          updatedAt: DateTime.now(),
        );
        state = updatedOrders;
      }

      NotificationService.showSuccess(
        'Cập nhật trạng thái đơn hàng thành công!',
      );
    } catch (e) {
      NotificationService.showError(
        'Lỗi cập nhật trạng thái đơn hàng: ${e.toString()}',
      );
    }
  }

  /// Hủy đơn hàng
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      await cancelOrderUC(CancelOrderParams(orderId: orderId, reason: reason));
      await updateOrderStatus(
        orderId,
        OrderStatus.cancelled,
        statusNote: reason,
      );
      NotificationService.showSuccess('Hủy đơn hàng thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi hủy đơn hàng: ${e.toString()}');
    }
  }

  /// Xác nhận đơn hàng
  Future<void> confirmOrder(String orderId) async {
    try {
      await repository.confirmOrder(orderId);
      await updateOrderStatus(orderId, OrderStatus.confirmed);
      NotificationService.showSuccess('Xác nhận đơn hàng thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi xác nhận đơn hàng: ${e.toString()}');
    }
  }

  /// Bắt đầu chuẩn bị đơn hàng
  Future<void> startPreparingOrder(String orderId) async {
    try {
      await repository.startPreparingOrder(orderId);
      await updateOrderStatus(orderId, OrderStatus.preparing);
      NotificationService.showSuccess('Bắt đầu chuẩn bị đơn hàng!');
    } catch (e) {
      NotificationService.showError(
        'Lỗi bắt đầu chuẩn bị đơn hàng: ${e.toString()}',
      );
    }
  }

  /// Bắt đầu giao hàng
  Future<void> shipOrder(String orderId, {String? trackingNumber}) async {
    try {
      await repository.startShippingOrder(
        orderId,
        trackingNumber: trackingNumber,
      );
      await updateOrderStatus(
        orderId,
        OrderStatus.shipping,
        trackingNumber: trackingNumber,
      );
      NotificationService.showSuccess('Bắt đầu giao hàng!');
    } catch (e) {
      NotificationService.showError('Lỗi bắt đầu giao hàng: ${e.toString()}');
    }
  }

  /// Hoàn thành giao hàng
  Future<void> deliverOrder(String orderId) async {
    try {
      await repository.completeDelivery(orderId);
      await updateOrderStatus(orderId, OrderStatus.delivered);
      NotificationService.showSuccess('Giao hàng thành công!');
    } catch (e) {
      NotificationService.showError(
        'Lỗi hoàn thành giao hàng: ${e.toString()}',
      );
    }
  }

  /// Hoàn thành đơn hàng
  Future<void> completeOrder(String orderId) async {
    try {
      await repository.completeOrder(orderId);
      await updateOrderStatus(orderId, OrderStatus.completed);
      NotificationService.showSuccess('Hoàn thành đơn hàng!');
    } catch (e) {
      NotificationService.showError('Lỗi hoàn thành đơn hàng: ${e.toString()}');
    }
  }

  /// Lấy đơn hàng theo ID
  OrderModel? getOrderById(String orderId) {
    try {
      return state.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Lấy đơn hàng theo trạng thái (local)
  List<OrderModel> getOrdersByStatus(String status) {
    if (status == 'Tất cả') {
      return state;
    }
    return state
        .where(
          (order) =>
              order.status.toString().split('.').last == status.toLowerCase(),
        )
        .toList();
  }

  /// Lấy đơn hàng theo user (local)
  List<OrderModel> getOrdersByUser(String userId) {
    return state.where((order) => order.userId == userId).toList();
  }

  /// Cập nhật thông tin thanh toán
  Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  }) async {
    try {
      await repository.updatePaymentInfo(
        orderId,
        paymentMethodId: paymentMethodId,
        paymentMethodName: paymentMethodName,
        paymentStatus: paymentStatus,
        paymentTransactionId: paymentTransactionId,
      );

      // Cập nhật local state
      final index = state.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrders = List<OrderModel>.from(state);
        updatedOrders[index] = updatedOrders[index].copyWith(
          paymentMethodId: paymentMethodId,
          paymentMethodName: paymentMethodName,
          paymentStatus: paymentStatus,
          paymentTransactionId: paymentTransactionId,
          updatedAt: DateTime.now(),
        );
        state = updatedOrders;
      }

      NotificationService.showSuccess(
        'Cập nhật thông tin thanh toán thành công!',
      );
    } catch (e) {
      NotificationService.showError(
        'Lỗi cập nhật thông tin thanh toán: ${e.toString()}',
      );
    }
  }
}

class CurrentOrderNotifier extends StateNotifier<OrderModel?> {
  final OrderRepository repository;
  final GetOrderById getOrderByIdUC;

  CurrentOrderNotifier({required this.repository, required this.getOrderByIdUC})
    : super(null);

  /// Đặt đơn hàng hiện tại
  void setCurrentOrder(OrderModel order) {
    state = order;
  }

  /// Xóa đơn hàng hiện tại
  void clearCurrentOrder() {
    state = null;
  }

  /// Cập nhật đơn hàng hiện tại
  void updateOrder(OrderModel order) {
    state = order;
  }

  /// Tải đơn hàng theo ID
  Future<void> loadOrderById(String orderId) async {
    try {
      final orderEntity = await getOrderByIdUC(orderId);
      if (orderEntity != null) {
        state = OrderMapper.toModel(orderEntity);
      } else {
        NotificationService.showWarning('Không tìm thấy đơn hàng');
      }
    } catch (e) {
      NotificationService.showError('Lỗi tải đơn hàng: ${e.toString()}');
    }
  }

  /// Tải đơn hàng theo số đơn hàng
  Future<void> loadOrderByNumber(String orderNumber) async {
    try {
      final orderEntity = await repository.getOrderByNumber(orderNumber);
      if (orderEntity != null) {
        state = OrderMapper.toModel(orderEntity);
      } else {
        NotificationService.showWarning('Không tìm thấy đơn hàng');
      }
    } catch (e) {
      NotificationService.showError('Lỗi tải đơn hàng: ${e.toString()}');
    }
  }
}

// Stream providers cho real-time updates
final orderStreamProvider = StreamProvider.family<OrderModel?, String>((
  ref,
  orderId,
) {
  final watchOrder = ref.watch(watchOrderProvider);
  return watchOrder(orderId).map((orderEntity) {
    return orderEntity != null ? OrderMapper.toModel(orderEntity) : null;
  });
});

final userOrdersStreamProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, userId) {
      final watchUserOrders = ref.watch(watchUserOrdersProvider);
      return watchUserOrders(userId).map(OrderMapper.toModelList);
    });

final ordersByStatusStreamProvider =
    StreamProvider.family<List<OrderModel>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final repo = ref.watch(orderRepositoryProvider);
      final userId = params['userId'] as String;
      final status = params['status'] as OrderStatus;
      return repo
          .watchOrdersByStatus(userId, status)
          .map(OrderMapper.toModelList);
    });

final allOrdersStreamProvider = StreamProvider.autoDispose<List<OrderModel>>((
  ref,
) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchAllOrders().map(OrderMapper.toModelList);
});

// Order stats provider
final orderStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(orderRepositoryProvider);
  return await repo.getUserOrderStats(userId);
});
