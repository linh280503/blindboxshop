import 'package:flutter_test/flutter_test.dart';

/// =============================================================================
/// TEST FILE 1: CART MODEL TEST
/// =============================================================================
/// 
/// MỤC ĐÍCH: Kiểm tra các chức năng của giỏ hàng (Cart)
/// - Thêm sản phẩm vào giỏ
/// - Gộp số lượng khi thêm sản phẩm đã tồn tại
/// - Cập nhật số lượng sản phẩm
/// - Xóa sản phẩm khỏi giỏ
/// - Tính tổng tiền giỏ hàng
/// 
/// CÁCH CHẠY: flutter test testing/function/cart_test.dart

// ============== MOCK CLASSES (copy từ cart_model.dart) ==============

class CartItem {
  final String id;
  final String productId;
  final String userId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String productType;
  final int? boxSize;
  final int? setSize;
  final DateTime addedAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.userId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.productType = 'single',
    this.boxSize,
    this.setSize,
    required this.addedAt,
    required this.updatedAt,
  });

  double get totalPrice => price * quantity;
  String get displayPrice => '${price.toStringAsFixed(0)} VNĐ';
  String get displayTotalPrice => '${totalPrice.toStringAsFixed(0)} VNĐ';

  CartItem copyWith({
    String? id,
    String? productId,
    String? userId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? productType,
    int? boxSize,
    int? setSize,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      productType: productType ?? this.productType,
      boxSize: boxSize ?? this.boxSize,
      setSize: setSize ?? this.setSize,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime lastUpdated;

  Cart({
    required this.userId,
    this.items = const [],
    required this.lastUpdated,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  String get displayTotalPrice => '${totalPrice.toStringAsFixed(0)} VNĐ';
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Cart copyWith({
    String? userId,
    List<CartItem>? items,
    DateTime? lastUpdated,
  }) {
    return Cart(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  CartItem? getItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  Cart addItem(CartItem newItem) {
    final existingItem = getItemByProductId(newItem.productId);

    if (existingItem != null) {
      final updatedItems = items.map((item) {
        if (item.productId == newItem.productId) {
          return item.copyWith(
            quantity: item.quantity + newItem.quantity,
          );
        }
        return item;
      }).toList();

      return copyWith(items: updatedItems);
    } else {
      return copyWith(items: [...items, newItem]);
    }
  }

  Cart updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems);
  }

  Cart removeItem(String productId) {
    final updatedItems = items.where((item) => item.productId != productId).toList();
    return copyWith(items: updatedItems);
  }

  Cart clear() {
    return copyWith(items: []);
  }
}

// ============== TEST CASES ==============

void main() {
  group('Cart - Giỏ hàng', () {
    /// TEST 1: Thêm sản phẩm mới vào giỏ hàng trống
    /// 
    /// MỤC ĐÍCH: Kiểm tra khi thêm sản phẩm đầu tiên vào giỏ hàng rỗng,
    /// giỏ hàng được cập nhật đúng với số lượng và thông tin sản phẩm.
    test('Test 1: Thêm sản phẩm mới vào giỏ hàng trống', () {
      final cart = Cart(userId: 'user-001', lastUpdated: DateTime.now());
      final newItem = CartItem(
        id: 'item-001',
        productId: 'prod-001',
        userId: 'user-001',
        productName: 'Blind Box Labubu',
        productImage: 'labubu.jpg',
        price: 350000,
        quantity: 1,
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedCart = cart.addItem(newItem);

      expect(updatedCart.items.length, 1);
      expect(updatedCart.totalItems, 1);
      expect(updatedCart.totalPrice, 350000);
      expect(updatedCart.isEmpty, false);
    });

    /// TEST 2: Thêm sản phẩm đã tồn tại - gộp số lượng
    /// 
    /// MỤC ĐÍCH: Kiểm tra khi thêm sản phẩm đã có trong giỏ hàng,
    /// hệ thống sẽ tăng số lượng thay vì tạo item mới.
    test('Test 2: Thêm sản phẩm đã tồn tại - gộp số lượng', () {
      final existingItem = CartItem(
        id: 'item-001',
        productId: 'prod-001',
        userId: 'user-001',
        productName: 'Blind Box Labubu',
        productImage: 'labubu.jpg',
        price: 350000,
        quantity: 2,
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final cart = Cart(
        userId: 'user-001',
        items: [existingItem],
        lastUpdated: DateTime.now(),
      );

      final sameProduct = CartItem(
        id: 'item-002',
        productId: 'prod-001', // Cùng productId
        userId: 'user-001',
        productName: 'Blind Box Labubu',
        productImage: 'labubu.jpg',
        price: 350000,
        quantity: 3,
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedCart = cart.addItem(sameProduct);

      expect(updatedCart.items.length, 1); // Vẫn chỉ 1 item
      expect(updatedCart.items[0].quantity, 5); // 2 + 3 = 5
      expect(updatedCart.totalPrice, 1750000); // 350000 * 5
    });

    /// TEST 3: Cập nhật số lượng sản phẩm trong giỏ hàng
    /// 
    /// MỤC ĐÍCH: Kiểm tra chức năng thay đổi số lượng của một sản phẩm
    /// đã có trong giỏ hàng (không phải thêm mới).
    test('Test 3: Cập nhật số lượng sản phẩm trong giỏ hàng', () {
      final item = CartItem(
        id: 'item-001',
        productId: 'prod-001',
        userId: 'user-001',
        productName: 'Blind Box Dimoo',
        productImage: 'dimoo.jpg',
        price: 280000,
        quantity: 1,
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final cart = Cart(userId: 'user-001', items: [item], lastUpdated: DateTime.now());
      final updatedCart = cart.updateItemQuantity('prod-001', 5);

      expect(updatedCart.items[0].quantity, 5);
      expect(updatedCart.totalPrice, 1400000); // 280000 * 5
    });

    /// TEST 4: Xóa sản phẩm khi cập nhật số lượng về 0
    /// 
    /// MỤC ĐÍCH: Kiểm tra khi người dùng giảm số lượng về 0 hoặc số âm,
    /// sản phẩm sẽ tự động bị xóa khỏi giỏ hàng.
    test('Test 4: Xóa sản phẩm khi cập nhật số lượng về 0', () {
      final item = CartItem(
        id: 'item-001',
        productId: 'prod-001',
        userId: 'user-001',
        productName: 'Blind Box Molly',
        productImage: 'molly.jpg',
        price: 320000,
        quantity: 3,
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final cart = Cart(userId: 'user-001', items: [item], lastUpdated: DateTime.now());
      final updatedCart = cart.updateItemQuantity('prod-001', 0);

      expect(updatedCart.items.length, 0);
      expect(updatedCart.isEmpty, true);
    });

    /// TEST 5: Tính tổng giá trị giỏ hàng với nhiều sản phẩm
    /// 
    /// MỤC ĐÍCH: Kiểm tra việc tính tổng tiền của giỏ hàng khi có
    /// nhiều sản phẩm với số lượng và giá khác nhau.
    test('Test 5: Tính tổng giá trị giỏ hàng với nhiều sản phẩm', () {
      final now = DateTime.now();
      final items = [
        CartItem(id: '1', productId: 'p1', userId: 'u1', productName: 'Box A', productImage: 'a.jpg', price: 350000, quantity: 2, addedAt: now, updatedAt: now),
        CartItem(id: '2', productId: 'p2', userId: 'u1', productName: 'Box B', productImage: 'b.jpg', price: 280000, quantity: 3, addedAt: now, updatedAt: now),
        CartItem(id: '3', productId: 'p3', userId: 'u1', productName: 'Box C', productImage: 'c.jpg', price: 420000, quantity: 1, addedAt: now, updatedAt: now),
      ];

      final cart = Cart(userId: 'u1', items: items, lastUpdated: now);

      // 350000*2 + 280000*3 + 420000*1 = 700000 + 840000 + 420000 = 1960000
      expect(cart.totalPrice, 1960000);
      expect(cart.totalItems, 6); // 2 + 3 + 1
      expect(cart.displayTotalPrice, '1960000 VNĐ');
    });
  });
}
