/// Cart item domain entity
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

  const CartItem({
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

  // Business logic
  double get totalPrice => price * quantity;

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
}
