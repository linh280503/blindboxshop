import '../../../../core/usecase/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case to watch user cart changes (stream)
class WatchUserCart implements StreamUseCase<Cart?, String> {
  final CartRepository repository;

  WatchUserCart(this.repository);

  @override
  Stream<Cart?> call(String userId) {
    return repository.watchUserCart(userId);
  }
}
