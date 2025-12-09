import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Use case to watch product changes (stream)
class WatchProduct implements StreamUseCase<Product?, String> {
  final ProductRepository repository;

  WatchProduct(this.repository);

  @override
  Stream<Product?> call(String productId) {
    return repository.watchProduct(productId);
  }
}
