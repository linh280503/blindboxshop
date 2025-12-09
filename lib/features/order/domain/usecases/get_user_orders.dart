import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case to get user orders
class GetUserOrders implements UseCase<List<Order>, String> {
  final OrderRepository repository;

  GetUserOrders(this.repository);

  @override
  Future<List<Order>> call(String userId) async {
    return await repository.getUserOrders(userId);
  }
}
