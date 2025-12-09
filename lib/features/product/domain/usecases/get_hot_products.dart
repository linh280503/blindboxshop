import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Parameters for GetHotProducts
class GetHotProductsParams {
  final int limit;

  GetHotProductsParams({this.limit = 10});
}

/// Use case to get hot/bestselling products
class GetHotProducts implements UseCase<List<Product>, GetHotProductsParams> {
  final ProductRepository repository;

  GetHotProducts(this.repository);

  @override
  Future<List<Product>> call(GetHotProductsParams params) async {
    return await repository.getHotProducts(limit: params.limit);
  }
}
