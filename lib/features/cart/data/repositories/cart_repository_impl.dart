import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../mappers/cart_mapper.dart';

/// Implementation of CartRepository
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Cart?> getUserCart(String userId) async {
    final model = await remoteDataSource.getUserCart(userId);
    return model != null ? CartMapper.toEntity(model) : null;
  }

  @override
  Future<Cart> saveCart(Cart cart) async {
    final model = CartMapper.toModel(cart);
    await remoteDataSource.saveCart(model);
    return cart;
  }

  @override
  Future<bool> addItemToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
    int quantity = 1,
    String productType = 'single',
    int? boxSize,
    int? setSize,
  }) async {
    return await remoteDataSource.addItemToCart(
      userId: userId,
      productId: productId,
      productName: productName,
      price: price,
      productImage: productImage,
      quantity: quantity,
      productType: productType,
      boxSize: boxSize,
      setSize: setSize,
    );
  }

  @override
  Future<bool> updateItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    return await remoteDataSource.updateItemQuantity(
      userId: userId,
      productId: productId,
      quantity: quantity,
    );
  }

  @override
  Future<bool> removeItemFromCart({
    required String userId,
    required String productId,
  }) async {
    return await remoteDataSource.removeItemFromCart(
      userId: userId,
      productId: productId,
    );
  }

  @override
  Future<bool> removeMultipleItems(
    String userId,
    List<String> productIds,
  ) async {
    return await remoteDataSource.removeMultipleItems(userId, productIds);
  }

  @override
  Future<bool> clearCart(String userId) async {
    return await remoteDataSource.clearCart(userId);
  }

  @override
  Future<bool> isItemInCart({
    required String userId,
    required String productId,
  }) async {
    return await remoteDataSource.isItemInCart(
      userId: userId,
      productId: productId,
    );
  }

  @override
  Future<int> getItemQuantity({
    required String userId,
    required String productId,
  }) async {
    return await remoteDataSource.getItemQuantity(
      userId: userId,
      productId: productId,
    );
  }

  @override
  Future<int> getTotalItems(String userId) async {
    return await remoteDataSource.getTotalItems(userId);
  }

  @override
  Future<double> getTotalPrice(String userId) async {
    return await remoteDataSource.getTotalPrice(userId);
  }

  @override
  Future<List<CartItem>> getCartItems(String userId) async {
    final models = await remoteDataSource.getCartItems(userId);
    return models.map((model) => CartMapper.cartItemToEntity(model)).toList();
  }

  @override
  Future<bool> updateItemInfo({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
  }) async {
    return await remoteDataSource.updateItemInfo(
      userId: userId,
      productId: productId,
      productName: productName,
      price: price,
      productImage: productImage,
    );
  }

  @override
  Future<Map<String, dynamic>> getCartStats(String userId) async {
    return await remoteDataSource.getCartStats(userId);
  }

  @override
  Stream<Cart?> watchUserCart(String userId) {
    return remoteDataSource
        .watchUserCart(userId)
        .map((model) => model != null ? CartMapper.toEntity(model) : null);
  }
}
