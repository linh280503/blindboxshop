import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Use case to get a single product by ID
class GetProductById implements UseCase<Product?, String> {
  final ProductRepository repository;

  GetProductById(this.repository);

  @override
  Future<Product?> call(String productId) async {
    return await repository.getProductById(productId);
  }
}
