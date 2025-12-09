import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../models/order_model.dart' as model;

class OrderMapper {
  static OrderItem orderItemToEntity(model.OrderItem modelItem) {
    return OrderItem(
      productId: modelItem.productId,
      productName: modelItem.productName,
      productImage: modelItem.productImage,
      price: modelItem.price,
      quantity: modelItem.quantity,
      orderType: modelItem.orderType,
      boxSize: modelItem.boxSize,
      setSize: modelItem.setSize,
      totalPrice: modelItem.totalPrice,
    );
  }

  static model.OrderItem orderItemToModel(OrderItem entity) {
    return model.OrderItem(
      productId: entity.productId,
      productName: entity.productName,
      productImage: entity.productImage,
      price: entity.price,
      quantity: entity.quantity,
      orderType: entity.orderType,
      boxSize: entity.boxSize,
      setSize: entity.setSize,
      totalPrice: entity.totalPrice,
    );
  }

  static Order toEntity(model.OrderModel model) {
    return Order(
      id: model.id,
      userId: model.userId,
      orderNumber: model.orderNumber,
      items: model.items.map(orderItemToEntity).toList(),
      subtotal: model.subtotal,
      discountAmount: model.discountAmount,
      shippingFee: model.shippingFee,
      totalAmount: model.totalAmount,
      status: model.status,
      statusNote: model.statusNote,
      deliveryAddressId: model.deliveryAddressId,
      deliveryAddress: model.deliveryAddress != null
          ? Map<String, dynamic>.from(model.deliveryAddress!)
          : null,
      paymentMethodId: model.paymentMethodId,
      paymentMethodName: model.paymentMethodName,
      paymentStatus: model.paymentStatus,
      paymentTransactionId: model.paymentTransactionId,
      discountCode: model.discountCode,
      discountName: model.discountName,
      note: model.note,
      trackingNumber: model.trackingNumber,
      estimatedDeliveryDate: model.estimatedDeliveryDate,
      deliveredAt: model.deliveredAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Convert Order (Entity) to OrderModel (DTO)
  static model.OrderModel toModel(Order entity) {
    return model.OrderModel(
      id: entity.id,
      userId: entity.userId,
      orderNumber: entity.orderNumber,
      items: entity.items.map(orderItemToModel).toList(),
      subtotal: entity.subtotal,
      discountAmount: entity.discountAmount,
      shippingFee: entity.shippingFee,
      totalAmount: entity.totalAmount,
      status: entity.status, // Enums are shared from domain
      statusNote: entity.statusNote,
      deliveryAddressId: entity.deliveryAddressId,
      deliveryAddress: entity.deliveryAddress != null
          ? Map<String, dynamic>.from(entity.deliveryAddress!)
          : null,
      paymentMethodId: entity.paymentMethodId,
      paymentMethodName: entity.paymentMethodName,
      paymentStatus: entity.paymentStatus,
      paymentTransactionId: entity.paymentTransactionId,
      discountCode: entity.discountCode,
      discountName: entity.discountName,
      note: entity.note,
      trackingNumber: entity.trackingNumber,
      estimatedDeliveryDate: entity.estimatedDeliveryDate,
      deliveredAt: entity.deliveredAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert list of OrderModel to list of Order
  static List<Order> toEntityList(List<model.OrderModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convert list of Order to list of OrderModel
  static List<model.OrderModel> toModelList(List<Order> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
