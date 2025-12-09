import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Parameters for GetFeaturedProducts
class GetFeaturedProductsParams {
  final int limit;

  GetFeaturedProductsParams({this.limit = 10});
}

/// Use case to get featured products
class GetFeaturedProducts
    implements UseCase<List<Product>, GetFeaturedProductsParams> {
  final ProductRepository repository;

  GetFeaturedProducts(this.repository);

  @override
  Future<List<Product>> call(GetFeaturedProductsParams params) async {
    return await repository.getFeaturedProducts(limit: params.limit);
  }
}
