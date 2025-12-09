import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Parameters for GetNewProducts
class GetNewProductsParams {
  final int limit;

  GetNewProductsParams({this.limit = 10});
}

/// Use case to get new products
class GetNewProducts implements UseCase<List<Product>, GetNewProductsParams> {
  final ProductRepository repository;

  GetNewProducts(this.repository);

  @override
  Future<List<Product>> call(GetNewProductsParams params) async {
    return await repository.getNewProducts(limit: params.limit);
  }
}
