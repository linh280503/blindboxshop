import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case to watch user orders changes (stream)
class WatchUserOrders implements StreamUseCase<List<Order>, String> {
  final OrderRepository repository;

  WatchUserOrders(this.repository);

  @override
  Stream<List<Order>> call(String userId) {
    return repository.watchUserOrders(userId);
  }
}
