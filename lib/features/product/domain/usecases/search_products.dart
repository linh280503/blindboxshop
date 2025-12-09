import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Parameters for SearchProducts
class SearchProductsParams {
  final String query;
  final String? category;
  final String? brand;
  final int? limit;

  SearchProductsParams({
    required this.query,
    this.category,
    this.brand,
    this.limit,
  });
}

/// Use case to search products
class SearchProducts implements UseCase<List<Product>, SearchProductsParams> {
  final ProductRepository repository;

  SearchProducts(this.repository);

  @override
  Future<List<Product>> call(SearchProductsParams params) async {
    return await repository.searchProducts(
      params.query,
      category: params.category,
      brand: params.brand,
      limit: params.limit,
    );
  }
}
