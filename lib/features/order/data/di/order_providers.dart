import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/order_remote_datasource.dart';
import '../repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/get_user_orders.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/get_order_by_id.dart';
import '../../domain/usecases/update_order_status.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/watch_order.dart';
import '../../domain/usecases/watch_user_orders.dart';

// Datasource provider
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl();
});

// Repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: dataSource);
});

// Use cases providers
final getUserOrdersProvider = Provider<GetUserOrders>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetUserOrders(repository);
});

final createOrderProvider = Provider<CreateOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CreateOrder(repository);
});

final getOrderByIdProvider = Provider<GetOrderById>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderById(repository);
});

final updateOrderStatusProvider = Provider<UpdateOrderStatus>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return UpdateOrderStatus(repository);
});

final cancelOrderProvider = Provider<CancelOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CancelOrder(repository);
});

final watchOrderProvider = Provider<WatchOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return WatchOrder(repository);
});

final watchUserOrdersProvider = Provider<WatchUserOrders>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return WatchUserOrders(repository);
});
