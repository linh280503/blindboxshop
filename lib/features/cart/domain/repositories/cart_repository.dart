import '../entities/cart.dart';
import '../entities/cart_item.dart';

/// Repository interface for Cart domain
abstract class CartRepository {
  Future<Cart?> getUserCart(String userId);
  Future<Cart> saveCart(Cart cart);
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
  });
  Future<bool> updateItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  });
  Future<bool> removeItemFromCart({
    required String userId,
    required String productId,
  });
  Future<bool> removeMultipleItems(String userId, List<String> productIds);
  Future<bool> clearCart(String userId);
  Future<bool> isItemInCart({
    required String userId,
    required String productId,
  });
  Future<int> getItemQuantity({
    required String userId,
    required String productId,
  });
  Future<int> getTotalItems(String userId);
  Future<double> getTotalPrice(String userId);
  Future<List<CartItem>> getCartItems(String userId);
  Future<bool> updateItemInfo({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
  });
  Future<Map<String, dynamic>> getCartStats(String userId);

  // Streams
  Stream<Cart?> watchUserCart(String userId);
}
