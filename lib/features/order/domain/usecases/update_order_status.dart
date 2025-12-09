import '../../../../core/usecase/usecase.dart';
import '../entities/order_status.dart';
import '../repositories/order_repository.dart';

/// Parameters for UpdateOrderStatus use case
class UpdateOrderStatusParams {
  final String orderId;
  final OrderStatus status;
  final String? statusNote;
  final String? trackingNumber;

  UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
    this.statusNote,
    this.trackingNumber,
  });
}

/// Use case to update order status
class UpdateOrderStatus implements UseCase<void, UpdateOrderStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatus(this.repository);

  @override
  Future<void> call(UpdateOrderStatusParams params) async {
    await repository.updateOrderStatus(
      params.orderId,
      params.status,
      statusNote: params.statusNote,
      trackingNumber: params.trackingNumber,
    );
  }
}
