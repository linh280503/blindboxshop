import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Use case to create a new product
class CreateProduct implements UseCase<Product, Product> {
  final ProductRepository repository;

  CreateProduct(this.repository);

  @override
  Future<Product> call(Product product) async {
    return await repository.createProduct(product);
  }
}
