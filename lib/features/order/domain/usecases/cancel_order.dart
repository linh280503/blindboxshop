import '../../../../core/usecase/usecase.dart';
import '../repositories/order_repository.dart';

/// Parameters for CancelOrder use case
class CancelOrderParams {
  final String orderId;
  final String? reason;

  CancelOrderParams({required this.orderId, this.reason});
}

/// Use case to cancel an order
class CancelOrder implements UseCase<void, CancelOrderParams> {
  final OrderRepository repository;

  CancelOrder(this.repository);

  @override
  Future<void> call(CancelOrderParams params) async {
    await repository.cancelOrder(params.orderId, reason: params.reason);
  }
}
