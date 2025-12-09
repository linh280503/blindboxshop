import '../../../../core/usecase/usecase.dart';
import '../repositories/cart_repository.dart';

class AddItemToCartParams {
  final String userId;
  final String productId;
  final String productName;
  final double price;
  final String productImage;
  final int quantity;
  final String productType;
  final int? boxSize;
  final int? setSize;

  AddItemToCartParams({
    required this.userId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.productImage,
    this.quantity = 1,
    this.productType = 'single',
    this.boxSize,
    this.setSize,
  });
}

class AddItemToCart implements UseCase<bool, AddItemToCartParams> {
  final CartRepository repository;

  AddItemToCart(this.repository);

  @override
  Future<bool> call(AddItemToCartParams params) async {
    return await repository.addItemToCart(
      userId: params.userId,
      productId: params.productId,
      productName: params.productName,
      price: params.price,
      productImage: params.productImage,
      quantity: params.quantity,
      productType: params.productType,
      boxSize: params.boxSize,
      setSize: params.setSize,
    );
  }
}
