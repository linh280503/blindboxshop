import 'cart_item.dart';

/// Cart domain entity
class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime lastUpdated;

  const Cart({
    required this.userId,
    this.items = const [],
    required this.lastUpdated,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

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
            updatedAt: DateTime.now(),
          );
        }
        return item;
      }).toList();

      return copyWith(items: updatedItems, lastUpdated: DateTime.now());
    } else {
      return copyWith(items: [...items, newItem], lastUpdated: DateTime.now());
    }
  }

  Cart updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity, updatedAt: DateTime.now());
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems, lastUpdated: DateTime.now());
  }

  Cart removeItem(String productId) {
    final updatedItems = items
        .where((item) => item.productId != productId)
        .toList();
    return copyWith(items: updatedItems, lastUpdated: DateTime.now());
  }

  Cart clear() {
    return copyWith(items: [], lastUpdated: DateTime.now());
  }

  Cart copyWith({
    String? userId,
    List<CartItem>? items,
    DateTime? lastUpdated,
  }) {
    return Cart(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cart &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
