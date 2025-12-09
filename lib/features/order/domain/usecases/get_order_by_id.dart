import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case to get order by ID
class GetOrderById implements UseCase<Order?, String> {
  final OrderRepository repository;

  GetOrderById(this.repository);

  @override
  Future<Order?> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}
