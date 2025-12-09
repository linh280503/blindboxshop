import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
    String? orderBy,
    bool descending = true,
  }) async {
    final models = await remoteDataSource.getProducts(
      category: category,
      brand: brand,
      isActive: isActive,
      isFeatured: isFeatured,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    );
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<Product?> getProductById(String productId) async {
    final model = await remoteDataSource.getProductById(productId);
    return model != null ? ProductMapper.toEntity(model) : null;
  }

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    final models = await remoteDataSource.getFeaturedProducts(limit: limit);
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<List<Product>> getNewProducts({int limit = 10}) async {
    final models = await remoteDataSource.getNewProducts(limit: limit);
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<List<Product>> getHotProducts({int limit = 10}) async {
    final models = await remoteDataSource.getHotProducts(limit: limit);
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<List<Product>> getProductsByCategory(
    String category, {
    int? limit,
  }) async {
    final models = await remoteDataSource.getProductsByCategory(
      category,
      limit: limit,
    );
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<List<Product>> getProductsByBrand(String brand, {int? limit}) async {
    final models = await remoteDataSource.getProductsByBrand(
      brand,
      limit: limit,
    );
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<List<Product>> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  }) async {
    final models = await remoteDataSource.searchProducts(
      query,
      category: category,
      brand: brand,
      limit: limit,
    );
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<List<Product>> getRelatedProducts(
    String productId, {
    int limit = 8,
  }) async {
    final models = await remoteDataSource.getRelatedProducts(
      productId,
      limit: limit,
    );
    return ProductMapper.toEntityList(models);
  }

  @override
  Future<Product> createProduct(Product product) async {
    final model = ProductMapper.toModel(product);
    final createdModel = await remoteDataSource.createProduct(model);
    return ProductMapper.toEntity(createdModel);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final model = ProductMapper.toModel(product);
    await remoteDataSource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await remoteDataSource.deleteProduct(productId);
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    await remoteDataSource.updateStock(productId, newStock);
  }

  @override
  Future<void> decreaseStock(String productId, int quantity) async {
    await remoteDataSource.decreaseStock(productId, quantity);
  }

  @override
  Future<void> increaseStock(String productId, int quantity) async {
    await remoteDataSource.increaseStock(productId, quantity);
  }

  @override
  Future<bool> checkStock(String productId, int quantity) async {
    return await remoteDataSource.checkStock(productId, quantity);
  }

  @override
  Future<Map<String, dynamic>> getStockInfo(String productId) async {
    return await remoteDataSource.getStockInfo(productId);
  }

  @override
  Future<void> updateRating(
    String productId,
    double rating,
    int reviewCount,
  ) async {
    await remoteDataSource.updateRating(productId, rating, reviewCount);
  }

  @override
  Future<void> updateSoldCount(String productId, int soldCount) async {
    await remoteDataSource.updateSoldCount(productId, soldCount);
  }

  @override
  Future<List<String>> getBrands() async {
    return await remoteDataSource.getBrands();
  }

  @override
  Future<List<String>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<Map<String, dynamic>> getProductStats() async {
    return await remoteDataSource.getProductStats();
  }

  @override
  Stream<Product?> watchProduct(String productId) {
    return remoteDataSource
        .watchProduct(productId)
        .map((model) => model != null ? ProductMapper.toEntity(model) : null);
  }

  @override
  Stream<List<Product>> watchProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) {
    return remoteDataSource
        .watchProducts(
          category: category,
          brand: brand,
          isActive: isActive,
          isFeatured: isFeatured,
          limit: limit,
        )
        .map(ProductMapper.toEntityList);
  }

  @override
  Stream<List<Product>> watchFeaturedProducts({int limit = 10}) {
    return remoteDataSource
        .watchFeaturedProducts(limit: limit)
        .map(ProductMapper.toEntityList);
  }

  @override
  Stream<List<Product>> watchNewProducts({int limit = 10}) {
    return remoteDataSource
        .watchNewProducts(limit: limit)
        .map(ProductMapper.toEntityList);
  }

  @override
  Stream<List<Product>> watchHotProducts({int limit = 10}) {
    return remoteDataSource
        .watchHotProducts(limit: limit)
        .map(ProductMapper.toEntityList);
  }
}
