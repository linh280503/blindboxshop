import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
    String? orderBy,
    bool descending = true,
  });

  /// Get product by ID
  Future<Product?> getProductById(String productId);

  /// Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10});

  /// Get new products
  Future<List<Product>> getNewProducts({int limit = 10});

  /// Get hot/bestselling products
  Future<List<Product>> getHotProducts({int limit = 10});

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category, {int? limit});

  /// Get products by brand
  Future<List<Product>> getProductsByBrand(String brand, {int? limit});

  /// Search products
  Future<List<Product>> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  });

  /// Get related products
  Future<List<Product>> getRelatedProducts(String productId, {int limit = 8});

  /// Create new product
  Future<Product> createProduct(Product product);

  /// Update product
  Future<void> updateProduct(Product product);

  /// Delete product
  Future<void> deleteProduct(String productId);

  /// Update stock
  Future<void> updateStock(String productId, int newStock);

  /// Decrease stock (when selling)
  Future<void> decreaseStock(String productId, int quantity);

  /// Increase stock (when restocking)
  Future<void> increaseStock(String productId, int quantity);

  /// Check stock availability
  Future<bool> checkStock(String productId, int quantity);

  /// Get stock info
  Future<Map<String, dynamic>> getStockInfo(String productId);

  /// Update rating
  Future<void> updateRating(String productId, double rating, int reviewCount);

  /// Update sold count
  Future<void> updateSoldCount(String productId, int soldCount);

  /// Get brands list
  Future<List<String>> getBrands();

  /// Get categories list
  Future<List<String>> getCategories();

  /// Get product statistics
  Future<Map<String, dynamic>> getProductStats();

  // Real-time streams
  /// Watch product changes
  Stream<Product?> watchProduct(String productId);

  /// Watch products list changes
  Stream<List<Product>> watchProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  });

  /// Watch featured products
  Stream<List<Product>> watchFeaturedProducts({int limit = 10});

  /// Watch new products
  Stream<List<Product>> watchNewProducts({int limit = 10});

  /// Watch hot products
  Stream<List<Product>> watchHotProducts({int limit = 10});
}
