import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/product_remote_datasource.dart';
import '../repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_product_by_id.dart';
import '../../domain/usecases/get_featured_products.dart';
import '../../domain/usecases/get_new_products.dart';
import '../../domain/usecases/get_hot_products.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/watch_product.dart';

// Datasource provider
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  return ProductRemoteDataSourceImpl();
});

// Repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: dataSource);
});

// Use cases providers
final getProductsProvider = Provider<GetProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProducts(repository);
});

final getProductByIdProvider = Provider<GetProductById>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductById(repository);
});

final getFeaturedProductsProvider = Provider<GetFeaturedProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetFeaturedProducts(repository);
});

final getNewProductsProvider = Provider<GetNewProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetNewProducts(repository);
});

final getHotProductsProvider = Provider<GetHotProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetHotProducts(repository);
});

final searchProductsProvider = Provider<SearchProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SearchProducts(repository);
});

final createProductProvider = Provider<CreateProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return CreateProduct(repository);
});

final updateProductProvider = Provider<UpdateProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return UpdateProduct(repository);
});

final watchProductProvider = Provider<WatchProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return WatchProduct(repository);
});
