import '../../../../core/usecase/usecase.dart';
import '../repositories/cart_repository.dart';

/// Parameters for UpdateItemQuantity use case
class UpdateItemQuantityParams {
  final String userId;
  final String productId;
  final int quantity;

  UpdateItemQuantityParams({
    required this.userId,
    required this.productId,
    required this.quantity,
  });
}

/// Use case to update item quantity in cart
class UpdateItemQuantity implements UseCase<bool, UpdateItemQuantityParams> {
  final CartRepository repository;

  UpdateItemQuantity(this.repository);

  @override
  Future<bool> call(UpdateItemQuantityParams params) async {
    return await repository.updateItemQuantity(
      userId: params.userId,
      productId: params.productId,
      quantity: params.quantity,
    );
  }
}
