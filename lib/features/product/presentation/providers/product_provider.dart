import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/product_model.dart';
import '../../data/mappers/product_mapper.dart';
import '../../data/di/product_providers.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_product_by_id.dart';
import '../../domain/usecases/get_featured_products.dart';
import '../../domain/usecases/get_new_products.dart';
import '../../domain/usecases/get_hot_products.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<ProductModel>>((ref) {
      final repo = ref.watch(productRepositoryProvider);
      final getProducts = ref.watch(getProductsProvider);
      final searchProducts = ref.watch(searchProductsProvider);
      final createProduct = ref.watch(createProductProvider);
      final updateProduct = ref.watch(updateProductProvider);
      return ProductsNotifier(
        ref: ref,
        repository: repo,
        getProductsUC: getProducts,
        searchUC: searchProducts,
        createUC: createProduct,
        updateUC: updateProduct,
      );
    });

// Featured products provider
final featuredProductsProvider = FutureProvider<List<ProductModel>>((
  ref,
) async {
  try {
    final uc = ref.watch(getFeaturedProductsProvider);
    final entities = await uc(GetFeaturedProductsParams());
    return ProductMapper.toModelList(entities);
  } catch (e) {
    NotificationService.showError('Lỗi tải sản phẩm nổi bật: ${e.toString()}');
    return [];
  }
});

// New products provider
final newProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  try {
    final uc = ref.watch(getNewProductsProvider);
    final entities = await uc(GetNewProductsParams());
    return ProductMapper.toModelList(entities);
  } catch (e) {
    NotificationService.showError('Lỗi tải sản phẩm mới: ${e.toString()}');
    return [];
  }
});

// Hot products provider
final hotProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  try {
    final uc = ref.watch(getHotProductsProvider);
    final entities = await uc(GetHotProductsParams());
    return ProductMapper.toModelList(entities);
  } catch (e) {
    NotificationService.showError('Lỗi tải sản phẩm bán chạy: ${e.toString()}');
    return [];
  }
});

// Product by id provider
final productByIdProvider = FutureProvider.family<ProductModel?, String>((
  ref,
  productId,
) async {
  try {
    final uc = ref.watch(getProductByIdProvider);
    final entity = await uc(productId);
    return entity != null ? ProductMapper.toModel(entity) : null;
  } catch (e) {
    NotificationService.showError('Lỗi tải sản phẩm: ${e.toString()}');
    return null;
  }
});

// Related products by category (repository)
final relatedProductsByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, category) async {
      try {
        final repo = ref.watch(productRepositoryProvider);
        final entities = await repo.getProductsByCategory(category, limit: 8);
        return ProductMapper.toModelList(entities);
      } catch (e) {
        NotificationService.showError(
          'Lỗi tải sản phẩm liên quan: ${e.toString()}',
        );
        return [];
      }
    });

// Products by category (local filter of current state)
final productsByCategoryProvider = Provider.family<List<ProductModel>, String>((
  ref,
  category,
) {
  final products = ref.watch(productsProvider);
  if (category == 'Tất cả') {
    return products;
  }
  return products.where((product) => product.category == category).toList();
});

// Products by brand (local)
final productsByBrandProvider = Provider.family<List<ProductModel>, String>((
  ref,
  brand,
) {
  final products = ref.watch(productsProvider);
  if (brand == 'Tất cả') {
    return products;
  }
  return products.where((product) => product.brand == brand).toList();
});

// Search results provider
final searchResultsProvider =
    StateNotifierProvider<SearchNotifier, List<ProductModel>>((ref) {
      final uc = ref.watch(searchProductsProvider);
      return SearchNotifier(uc);
    });

// Product detail provider
final productDetailProvider =
    StateNotifierProvider<ProductDetailNotifier, ProductModel?>((ref) {
      final uc = ref.watch(getProductByIdProvider);
      return ProductDetailNotifier(uc);
    });

// Brands provider (repository)
final brandsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final repo = ref.watch(productRepositoryProvider);
    return await repo.getBrands();
  } catch (e) {
    NotificationService.showError(
      'Lỗi tải danh sách thương hiệu: ${e.toString()}',
    );
    return [];
  }
});

// Categories provider (repository)
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    final repo = ref.watch(productRepositoryProvider);
    return await repo.getCategories();
  } catch (e) {
    NotificationService.showError(
      'Lỗi tải danh sách danh mục: ${e.toString()}',
    );
    return [];
  }
});

class ProductsNotifier extends StateNotifier<List<ProductModel>> {
  final Ref ref;
  final ProductRepository repository;
  final GetProducts getProductsUC;
  final SearchProducts searchUC;
  final CreateProduct createUC;
  final UpdateProduct updateUC;

  ProductsNotifier({
    required this.ref,
    required this.repository,
    required this.getProductsUC,
    required this.searchUC,
    required this.createUC,
    required this.updateUC,
  }) : super([]);

  /// Load products
  Future<void> loadProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) async {
    try {
      final entities = await getProductsUC(
        GetProductsParams(
          category: category,
          brand: brand,
          isActive: isActive,
          isFeatured: isFeatured,
          limit: limit,
        ),
      );
      state = ProductMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError(
        'Lỗi tải danh sách sản phẩm: ${e.toString()}',
      );
    }
  }

  /// Search products
  Future<void> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  }) async {
    try {
      final entities = await searchUC(
        SearchProductsParams(
          query: query,
          category: category,
          brand: brand,
          limit: limit,
        ),
      );
      state = ProductMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError('Lỗi tìm kiếm sản phẩm: ${e.toString()}');
    }
  }

  /// Create product
  Future<void> addProduct(ProductModel product) async {
    try {
      final createdEntity = await createUC(ProductMapper.toEntity(product));
      state = [ProductMapper.toModel(createdEntity), ...state];
      NotificationService.showSuccess('Thêm sản phẩm thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi thêm sản phẩm: ${e.toString()}');
    }
  }

  /// Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await updateUC(ProductMapper.toEntity(product));

      final index = state.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        final updatedProducts = List<ProductModel>.from(state);
        updatedProducts[index] = product;
        state = updatedProducts;
      }

      NotificationService.showSuccess('Cập nhật sản phẩm thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi cập nhật sản phẩm: ${e.toString()}');
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await repository.deleteProduct(productId);
      state = state.where((p) => p.id != productId).toList();
      NotificationService.showSuccess('Xóa sản phẩm thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi xóa sản phẩm: ${e.toString()}');
    }
  }

  /// Update stock
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await repository.updateStock(productId, newStock);

      final index = state.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProducts = List<ProductModel>.from(state);
        updatedProducts[index] = updatedProducts[index].copyWith(
          stock: newStock,
        );
        state = updatedProducts;
      }

      NotificationService.showSuccess('Cập nhật tồn kho thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi cập nhật tồn kho: ${e.toString()}');
    }
  }

  /// Decrease stock
  Future<void> decreaseStock(String productId, int quantity) async {
    try {
      await repository.decreaseStock(productId, quantity);

      final index = state.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProducts = List<ProductModel>.from(state);
        final currentStock = updatedProducts[index].stock;
        updatedProducts[index] = updatedProducts[index].copyWith(
          stock: currentStock - quantity,
        );
        state = updatedProducts;
      }

      NotificationService.showSuccess('Cập nhật tồn kho thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi giảm tồn kho: ${e.toString()}');
    }
  }

  /// Increase stock
  Future<void> increaseStock(String productId, int quantity) async {
    try {
      await repository.increaseStock(productId, quantity);

      final index = state.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProducts = List<ProductModel>.from(state);
        final currentStock = updatedProducts[index].stock;
        updatedProducts[index] = updatedProducts[index].copyWith(
          stock: currentStock + quantity,
        );
        state = updatedProducts;
      }

      NotificationService.showSuccess('Cập nhật tồn kho thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi tăng tồn kho: ${e.toString()}');
    }
  }

  /// Get local product by id
  ProductModel? getProductByIdLocal(String productId) {
    try {
      return state.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check stock
  Future<bool> checkStock(String productId, int quantity) async {
    try {
      return await repository.checkStock(productId, quantity);
    } catch (e) {
      NotificationService.showError('Lỗi kiểm tra tồn kho: ${e.toString()}');
      return false;
    }
  }
}

class SearchNotifier extends StateNotifier<List<ProductModel>> {
  final SearchProducts searchUC;
  SearchNotifier(this.searchUC) : super([]);

  Future<void> searchProducts(
    String query, {
    String? category,
    String? brand,
  }) async {
    try {
      final entities = await searchUC(
        SearchProductsParams(query: query, category: category, brand: brand),
      );
      state = ProductMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError('Lỗi tìm kiếm sản phẩm: ${e.toString()}');
      state = [];
    }
  }

  void clearSearch() {
    state = [];
  }
}

class ProductDetailNotifier extends StateNotifier<ProductModel?> {
  final GetProductById getProductByIdUC;
  ProductDetailNotifier(this.getProductByIdUC) : super(null);

  Future<void> loadProduct(String productId) async {
    try {
      final entity = await getProductByIdUC(productId);
      state = entity != null ? ProductMapper.toModel(entity) : null;
    } catch (e) {
      NotificationService.showError('Lỗi tải sản phẩm: ${e.toString()}');
      state = null;
    }
  }

  void clearProduct() {
    state = null;
  }
}

// Streams (usecases/repo)
final productStreamProvider = StreamProvider.family<ProductModel?, String>((
  ref,
  productId,
) {
  final uc = ref.watch(watchProductProvider);
  return uc(
    productId,
  ).map((entity) => entity != null ? ProductMapper.toModel(entity) : null);
});

final productsStreamProvider =
    StreamProvider.family<List<ProductModel>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final repo = ref.watch(productRepositoryProvider);
      return repo
          .watchProducts(
            category: params['category'] as String?,
            brand: params['brand'] as String?,
            isActive: params['isActive'] as bool?,
            isFeatured: params['isFeatured'] as bool?,
            limit: params['limit'] as int?,
          )
          .map(ProductMapper.toModelList);
    });

final featuredProductsStreamProvider = StreamProvider<List<ProductModel>>((
  ref,
) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchFeaturedProducts().map(ProductMapper.toModelList);
});

final newProductsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchNewProducts().map(ProductMapper.toModelList);
});

final hotProductsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchHotProducts().map(ProductMapper.toModelList);
});

// Product stats provider
final productStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getProductStats();
});
