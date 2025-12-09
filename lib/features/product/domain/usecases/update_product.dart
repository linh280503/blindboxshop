import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Use case to update a product
class UpdateProduct implements UseCase<void, Product> {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  @override
  Future<void> call(Product product) async {
    await repository.updateProduct(product);
  }
}
