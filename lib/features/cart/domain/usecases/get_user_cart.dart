import '../../../../core/usecase/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case to get user cart
class GetUserCart implements UseCase<Cart?, String> {
  final CartRepository repository;

  GetUserCart(this.repository);

  @override
  Future<Cart?> call(String userId) async {
    return await repository.getUserCart(userId);
  }
}
