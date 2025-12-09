class CartItem {
  final String id;
  final String productId;
  final String userId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String productType; // 'single', 'box', 'set'
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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      userId: json['user_id'],
      productName: json['product_name'],
      productImage: json['product_image'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      productType: json['product_type'] ?? 'single',
      boxSize: json['box_size'],
      setSize: json['set_size'],
      addedAt: DateTime.parse(json['added_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
      'product_type': productType,
      'box_size': boxSize,
      'set_size': setSize,
      'added_at': addedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get totalPrice => price * quantity;
  String get displayPrice => '${price.toStringAsFixed(0)} VNĐ';
  String get displayTotalPrice => '${totalPrice.toStringAsFixed(0)} VNĐ';
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

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['user_id'],
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e))
              .toList() ??
          [],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
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

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);
  String get displayTotalPrice => '${totalPrice.toStringAsFixed(0)} VNĐ';

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
}
