import '../../../../core/usecase/usecase.dart';
import '../repositories/cart_repository.dart';

/// Parameters for RemoveItemFromCart use case
class RemoveItemFromCartParams {
  final String userId;
  final String productId;

  RemoveItemFromCartParams({required this.userId, required this.productId});
}

/// Use case to remove item from cart
class RemoveItemFromCart implements UseCase<bool, RemoveItemFromCartParams> {
  final CartRepository repository;

  RemoveItemFromCart(this.repository);

  @override
  Future<bool> call(RemoveItemFromCartParams params) async {
    return await repository.removeItemFromCart(
      userId: params.userId,
      productId: params.productId,
    );
  }
}
