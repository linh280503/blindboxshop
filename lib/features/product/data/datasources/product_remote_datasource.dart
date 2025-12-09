// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

/// Abstract datasource for remote product data
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
    String? orderBy,
    bool descending = true,
  });

  Future<ProductModel?> getProductById(String productId);
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10});
  Future<List<ProductModel>> getNewProducts({int limit = 10});
  Future<List<ProductModel>> getHotProducts({int limit = 10});
  Future<List<ProductModel>> getProductsByCategory(
    String category, {
    int? limit,
  });
  Future<List<ProductModel>> getProductsByBrand(String brand, {int? limit});
  Future<List<ProductModel>> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  });
  Future<List<ProductModel>> getRelatedProducts(
    String productId, {
    int limit = 8,
  });
  Future<ProductModel> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Future<void> updateStock(String productId, int newStock);
  Future<void> decreaseStock(String productId, int quantity);
  Future<void> increaseStock(String productId, int quantity);
  Future<bool> checkStock(String productId, int quantity);
  Future<Map<String, dynamic>> getStockInfo(String productId);
  Future<void> updateRating(String productId, double rating, int reviewCount);
  Future<void> updateSoldCount(String productId, int soldCount);
  Future<List<String>> getBrands();
  Future<List<String>> getCategories();
  Future<Map<String, dynamic>> getProductStats();

  // Streams
  Stream<ProductModel?> watchProduct(String productId);
  Stream<List<ProductModel>> watchProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  });
  Stream<List<ProductModel>> watchFeaturedProducts({int limit = 10});
  Stream<List<ProductModel>> watchNewProducts({int limit = 10});
  Stream<List<ProductModel>> watchHotProducts({int limit = 10});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _productsCollection = 'products';

  ProductRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      Query query = firestore.collection(_productsCollection);

      // Apply filters
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }
      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      if (brand != null && brand.isNotEmpty) {
        query = query.where('brand', isEqualTo: brand);
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('createdAt', descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách sản phẩm: $e');
    }
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (!doc.exists) return null;

      return ProductModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm: $e');
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    try {
      return await getProducts(
        isFeatured: true,
        isActive: true,
        limit: limit,
        orderBy: 'createdAt',
      );
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm nổi bật: $e');
    }
  }

  @override
  Future<List<ProductModel>> getNewProducts({int limit = 10}) async {
    try {
      return await getProducts(
        isActive: true,
        limit: limit,
        orderBy: 'createdAt',
      );
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm mới: $e');
    }
  }

  @override
  Future<List<ProductModel>> getHotProducts({int limit = 10}) async {
    try {
      return await getProducts(isActive: true, limit: limit, orderBy: 'sold');
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm bán chạy: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    String category, {
    int? limit,
  }) async {
    try {
      return await getProducts(
        category: category,
        isActive: true,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm theo danh mục: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByBrand(
    String brand, {
    int? limit,
  }) async {
    try {
      return await getProducts(brand: brand, isActive: true, limit: limit);
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm theo thương hiệu: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  }) async {
    try {
      // Firestore doesn't support full-text search natively
      // We'll use a simple approach with array-contains for keywords
      final snapshot = await firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .limit(limit ?? 20)
          .get();

      List<ProductModel> products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      // Additional filtering by category and brand
      if (category != null && category.isNotEmpty) {
        products = products.where((p) => p.category == category).toList();
      }
      if (brand != null && brand.isNotEmpty) {
        products = products.where((p) => p.brand == brand).toList();
      }

      return products;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm sản phẩm: $e');
    }
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(
    String productId, {
    int limit = 8,
  }) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return [];

      return await getProductsByCategory(product.category, limit: limit);
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm liên quan: $e');
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final docRef = await firestore
          .collection(_productsCollection)
          .add(product.toFirestore());

      return product.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Lỗi tạo sản phẩm: $e');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      await firestore
          .collection(_productsCollection)
          .doc(product.id)
          .update(product.toFirestore());
    } catch (e) {
      throw Exception('Lỗi cập nhật sản phẩm: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await firestore.collection(_productsCollection).doc(productId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa sản phẩm: $e');
    }
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await firestore.collection(_productsCollection).doc(productId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật tồn kho: $e');
    }
  }

  @override
  Future<void> decreaseStock(String productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Sản phẩm không tồn tại');
      }

      if (product.stock < quantity) {
        throw Exception('Không đủ tồn kho');
      }

      await updateStock(productId, product.stock - quantity);
    } catch (e) {
      throw Exception('Lỗi giảm tồn kho: $e');
    }
  }

  @override
  Future<void> increaseStock(String productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Sản phẩm không tồn tại');
      }

      await updateStock(productId, product.stock + quantity);
    } catch (e) {
      throw Exception('Lỗi tăng tồn kho: $e');
    }
  }

  @override
  Future<void> updateSoldCount(String productId, int soldCount) async {
    try {
      await firestore.collection(_productsCollection).doc(productId).update({
        'sold': soldCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật số lượng bán: $e');
    }
  }

  @override
  Future<void> updateRating(
    String productId,
    double rating,
    int reviewCount,
  ) async {
    try {
      await firestore.collection(_productsCollection).doc(productId).update({
        'rating': rating,
        'reviewCount': reviewCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật đánh giá: $e');
    }
  }

  @override
  Future<List<String>> getBrands() async {
    try {
      final snapshot = await firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final brands = snapshot.docs
          .map((doc) => doc.data()['brand'] as String?)
          .where((brand) => brand != null && brand.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      brands.sort();
      return brands;
    } catch (e) {
      throw Exception('Lỗi lấy danh sách thương hiệu: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Lỗi lấy danh sách danh mục: $e');
    }
  }

  @override
  Stream<ProductModel?> watchProduct(String productId) {
    return firestore
        .collection(_productsCollection)
        .doc(productId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return ProductModel.fromFirestore(snapshot);
        });
  }

  @override
  Stream<List<ProductModel>> watchProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) {
    Query query = firestore.collection(_productsCollection);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }
    if (isFeatured != null) {
      query = query.where('isFeatured', isEqualTo: isFeatured);
    }
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (brand != null && brand.isNotEmpty) {
      query = query.where('brand', isEqualTo: brand);
    }

    query = query.orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<ProductModel>> watchFeaturedProducts({int limit = 10}) {
    return watchProducts(isFeatured: true, isActive: true, limit: limit);
  }

  @override
  Stream<List<ProductModel>> watchNewProducts({int limit = 10}) {
    return watchProducts(isActive: true, limit: limit);
  }

  @override
  Stream<List<ProductModel>> watchHotProducts({int limit = 10}) {
    Query query = firestore
        .collection(_productsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('sold', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<bool> checkStock(String productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return false;

      return product.stock >= quantity;
    } catch (e) {
      throw Exception('Lỗi kiểm tra tồn kho: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getStockInfo(String productId) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        return {'currentStock': 0, 'isInStock': false, 'isLowStock': false};
      }

      return {
        'currentStock': product.stock,
        'isInStock': product.stock > 0,
        'isLowStock': product.stock <= 10,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thông tin tồn kho: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final snapshot = await firestore.collection(_productsCollection).get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      final totalProducts = products.length;
      final activeProducts = products.where((p) => p.isActive).length;
      final featuredProducts = products.where((p) => p.isFeatured).length;
      final outOfStockProducts = products.where((p) => p.stock == 0).length;
      final lowStockProducts = products.where((p) => p.stock <= 10).length;

      final totalSold = products.fold(0, (sum, p) => sum + p.sold);
      final totalRevenue = products.fold(
        0.0,
        (sum, p) => sum + (p.price * p.sold),
      );

      return {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'featuredProducts': featuredProducts,
        'outOfStockProducts': outOfStockProducts,
        'lowStockProducts': lowStockProducts,
        'totalSold': totalSold,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê sản phẩm: $e');
    }
  }
}
