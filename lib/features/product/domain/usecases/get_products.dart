import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Parameters for GetProducts use case
class GetProductsParams {
  final String? category;
  final String? brand;
  final bool? isActive;
  final bool? isFeatured;
  final int? limit;
  final String? orderBy;
  final bool descending;

  GetProductsParams({
    this.category,
    this.brand,
    this.isActive,
    this.isFeatured,
    this.limit,
    this.orderBy,
    this.descending = true,
  });
}

/// Use case to get products list
class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<List<Product>> call(GetProductsParams params) async {
    return await repository.getProducts(
      category: params.category,
      brand: params.brand,
      isActive: params.isActive,
      isFeatured: params.isFeatured,
      limit: params.limit,
      orderBy: params.orderBy,
      descending: params.descending,
    );
  }
}
