// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';

/// Abstract datasource for remote cart data
abstract class CartRemoteDataSource {
  Future<Cart?> getUserCart(String userId);
  Future<void> saveCart(Cart cart);
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
  Stream<Cart?> watchUserCart(String userId);
}

/// Firestore implementation of CartRemoteDataSource
/// Refactored from CartService
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _cartsCollection = 'carts';

  CartRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> _saveCart(Cart cart) async {
    try {
      await firestore
          .collection(_cartsCollection)
          .doc(cart.userId)
          .set(cart.toJson());
    } catch (e) {
      throw Exception('Lỗi lưu giỏ hàng: $e');
    }
  }

  @override
  Future<Cart?> getUserCart(String userId) async {
    try {
      if (userId.isEmpty) {
        return null;
      }

      final doc = await firestore
          .collection(_cartsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return Cart.fromJson(data);
    } catch (e) {
      throw Exception('Lỗi lấy giỏ hàng: $e');
    }
  }

  @override
  Future<void> saveCart(Cart cart) async {
    await _saveCart(cart);
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
    try {
      Cart currentCart =
          await getUserCart(userId) ??
          Cart(userId: userId, items: [], lastUpdated: DateTime.now());

      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        userId: userId,
        productName: productName,
        productImage: productImage,
        price: price,
        quantity: quantity,
        productType: productType,
        boxSize: boxSize,
        setSize: setSize,
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedCart = currentCart.addItem(newItem);
      await _saveCart(updatedCart);

      return true;
    } catch (e) {
      throw Exception('Lỗi thêm sản phẩm vào giỏ hàng: $e');
    }
  }

  @override
  Future<bool> updateItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final currentCart = await getUserCart(userId);
      if (currentCart == null) {
        return false;
      }

      final updatedCart = currentCart.updateItemQuantity(productId, quantity);
      await _saveCart(updatedCart);

      return true;
    } catch (e) {
      throw Exception('Lỗi cập nhật số lượng sản phẩm: $e');
    }
  }

  @override
  Future<bool> removeItemFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final currentCart = await getUserCart(userId);
      if (currentCart == null) {
        return false;
      }

      final updatedCart = currentCart.removeItem(productId);
      await _saveCart(updatedCart);

      return true;
    } catch (e) {
      throw Exception('Lỗi xóa sản phẩm khỏi giỏ hàng: $e');
    }
  }

  @override
  Future<bool> removeMultipleItems(
    String userId,
    List<String> productIds,
  ) async {
    try {
      if (productIds.isEmpty) return true;

      final currentCart = await getUserCart(userId);
      if (currentCart == null) {
        return false;
      }

      final updatedItems = currentCart.items
          .where((item) => !productIds.contains(item.productId))
          .toList();

      final updatedCart = currentCart.copyWith(
        items: updatedItems,
        lastUpdated: DateTime.now(),
      );

      await _saveCart(updatedCart);
      return true;
    } catch (e) {
      throw Exception('Lỗi xóa nhiều sản phẩm: $e');
    }
  }

  @override
  Future<bool> clearCart(String userId) async {
    try {
      final emptyCart = Cart(
        userId: userId,
        items: [],
        lastUpdated: DateTime.now(),
      );

      await _saveCart(emptyCart);
      return true;
    } catch (e) {
      throw Exception('Lỗi xóa giỏ hàng: $e');
    }
  }

  @override
  Future<bool> isItemInCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final cart = await getUserCart(userId);
      if (cart == null) return false;

      return cart.getItemByProductId(productId) != null;
    } catch (e) {
      throw Exception('Lỗi kiểm tra sản phẩm trong giỏ hàng: $e');
    }
  }

  @override
  Future<int> getItemQuantity({
    required String userId,
    required String productId,
  }) async {
    try {
      final cart = await getUserCart(userId);
      if (cart == null) return 0;

      final item = cart.getItemByProductId(productId);
      return item?.quantity ?? 0;
    } catch (e) {
      throw Exception('Lỗi lấy số lượng sản phẩm: $e');
    }
  }

  @override
  Future<int> getTotalItems(String userId) async {
    try {
      final cart = await getUserCart(userId);
      if (cart == null) return 0;

      return cart.totalItems;
    } catch (e) {
      throw Exception('Lỗi lấy tổng số sản phẩm: $e');
    }
  }

  @override
  Future<double> getTotalPrice(String userId) async {
    try {
      final cart = await getUserCart(userId);
      if (cart == null) return 0.0;

      return cart.totalPrice;
    } catch (e) {
      throw Exception('Lỗi lấy tổng giá trị giỏ hàng: $e');
    }
  }

  @override
  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final cart = await getUserCart(userId);
      if (cart == null) return [];

      return cart.items;
    } catch (e) {
      throw Exception('Lỗi lấy danh sách sản phẩm: $e');
    }
  }

  @override
  Future<bool> updateItemInfo({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
  }) async {
    try {
      final currentCart = await getUserCart(userId);
      if (currentCart == null) {
        throw Exception('Không thể lấy giỏ hàng');
      }

      final itemIndex = currentCart.items.indexWhere(
        (item) => item.productId == productId,
      );

      if (itemIndex == -1) {
        throw Exception('Sản phẩm không tồn tại trong giỏ hàng');
      }

      final updatedItems = List<CartItem>.from(currentCart.items);
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        productName: productName,
        price: price,
        productImage: productImage,
        updatedAt: DateTime.now(),
      );

      final updatedCart = currentCart.copyWith(
        items: updatedItems,
        lastUpdated: DateTime.now(),
      );

      await _saveCart(updatedCart);
      return true;
    } catch (e) {
      throw Exception('Lỗi cập nhật thông tin sản phẩm: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCartStats(String userId) async {
    try {
      final cart = await getUserCart(userId);
      if (cart == null) {
        return {
          'totalItems': 0,
          'totalPrice': 0.0,
          'itemCount': 0,
          'isEmpty': true,
          'lastUpdated': null,
        };
      }

      return {
        'totalItems': cart.totalItems,
        'totalPrice': cart.totalPrice,
        'itemCount': cart.items.length,
        'isEmpty': cart.isEmpty,
        'lastUpdated': cart.lastUpdated,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê giỏ hàng: $e');
    }
  }

  @override
  Stream<Cart?> watchUserCart(String userId) {
    return firestore.collection(_cartsCollection).doc(userId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return null;
      }

      try {
        return Cart.fromJson(snapshot.data()!);
      } catch (e) {
        return null;
      }
    });
  }
}
