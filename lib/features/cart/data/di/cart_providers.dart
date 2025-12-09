import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/cart_remote_datasource.dart';
import '../repositories/cart_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/get_user_cart.dart';
import '../../domain/usecases/add_item_to_cart.dart';
import '../../domain/usecases/update_item_quantity.dart';
import '../../domain/usecases/remove_item_from_cart.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/usecases/watch_user_cart.dart';

// Datasource provider
final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSourceImpl();
});

// Repository provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final dataSource = ref.watch(cartRemoteDataSourceProvider);
  return CartRepositoryImpl(remoteDataSource: dataSource);
});

// Use cases providers
final getUserCartProvider = Provider<GetUserCart>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return GetUserCart(repository);
});

final addItemToCartProvider = Provider<AddItemToCart>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return AddItemToCart(repository);
});

final updateItemQuantityProvider = Provider<UpdateItemQuantity>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return UpdateItemQuantity(repository);
});

final removeItemFromCartProvider = Provider<RemoveItemFromCart>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return RemoveItemFromCart(repository);
});

final clearCartProvider = Provider<ClearCart>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return ClearCart(repository);
});

final watchUserCartProvider = Provider<WatchUserCart>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return WatchUserCart(repository);
});
