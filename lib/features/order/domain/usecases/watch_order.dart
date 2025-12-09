import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case to watch order changes (stream)
class WatchOrder implements StreamUseCase<Order?, String> {
  final OrderRepository repository;

  WatchOrder(this.repository);

  @override
  Stream<Order?> call(String orderId) {
    return repository.watchOrder(orderId);
  }
}
