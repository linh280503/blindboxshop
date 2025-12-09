import '../../../../core/usecase/usecase.dart';
import '../repositories/cart_repository.dart';

/// Use case to clear cart
class ClearCart implements UseCase<bool, String> {
  final CartRepository repository;

  ClearCart(this.repository);

  @override
  Future<bool> call(String userId) async {
    return await repository.clearCart(userId);
  }
}
