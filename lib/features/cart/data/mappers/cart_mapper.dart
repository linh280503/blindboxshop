import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../models/cart_model.dart' as model;

/// Mapper between Cart domain entity and CartModel DTO
class CartMapper {
  /// Convert CartItemModel to CartItem entity
  static CartItem cartItemToEntity(model.CartItem modelItem) {
    return CartItem(
      id: modelItem.id,
      productId: modelItem.productId,
      userId: modelItem.userId,
      productName: modelItem.productName,
      productImage: modelItem.productImage,
      price: modelItem.price,
      quantity: modelItem.quantity,
      productType: modelItem.productType,
      boxSize: modelItem.boxSize,
      setSize: modelItem.setSize,
      addedAt: modelItem.addedAt,
      updatedAt: modelItem.updatedAt,
    );
  }

  /// Convert CartItem entity to CartItemModel
  static model.CartItem cartItemToModel(CartItem entity) {
    return model.CartItem(
      id: entity.id,
      productId: entity.productId,
      userId: entity.userId,
      productName: entity.productName,
      productImage: entity.productImage,
      price: entity.price,
      quantity: entity.quantity,
      productType: entity.productType,
      boxSize: entity.boxSize,
      setSize: entity.setSize,
      addedAt: entity.addedAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert CartModel (DTO) to Cart (Entity)
  static Cart toEntity(model.Cart model) {
    return Cart(
      userId: model.userId,
      items: model.items.map(cartItemToEntity).toList(),
      lastUpdated: model.lastUpdated,
    );
  }

  /// Convert Cart (Entity) to CartModel (DTO)
  static model.Cart toModel(Cart entity) {
    return model.Cart(
      userId: entity.userId,
      items: entity.items.map(cartItemToModel).toList(),
      lastUpdated: entity.lastUpdated,
    );
  }
}
