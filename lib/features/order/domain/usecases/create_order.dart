import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case to create a new order
class CreateOrder implements UseCase<Order, Order> {
  final OrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Order> call(Order order) async {
    return await repository.createOrder(order);
  }
}
