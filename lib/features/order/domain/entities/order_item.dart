import 'order_type.dart';

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final OrderType orderType;
  final int? boxSize;
  final int? setSize;
  final double totalPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.orderType,
    this.boxSize,
    this.setSize,
    required this.totalPrice,
  });

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    OrderType? orderType,
    int? boxSize,
    int? setSize,
    double? totalPrice,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      orderType: orderType ?? this.orderType,
      boxSize: boxSize ?? this.boxSize,
      setSize: setSize ?? this.setSize,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
