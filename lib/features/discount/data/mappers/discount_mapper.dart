import '../../domain/entities/discount.dart';
import '../models/discount_model.dart' as model;

class DiscountMapper {
  static Discount toEntity(model.DiscountModel model) {
    return Discount(
      id: model.id,
      code: model.code,
      name: model.name,
      description: model.description,
      type: model.type, // Enums are shared from domain
      value: model.value,
      minOrderAmount: model.minOrderAmount,
      maxDiscountAmount: model.maxDiscountAmount,
      usageLimit: model.usageLimit,
      usedCount: model.usedCount,
      startDate: model.startDate,
      endDate: model.endDate,
      status: model.status, // Enums are shared from domain
      applicableProducts: List<String>.from(model.applicableProducts),
      applicableCategories: List<String>.from(model.applicableCategories),
      isFirstOrderOnly: model.isFirstOrderOnly,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static model.DiscountModel toModel(Discount entity) {
    return model.DiscountModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      type: entity.type, // Enums are shared from domain
      value: entity.value,
      minOrderAmount: entity.minOrderAmount,
      maxDiscountAmount: entity.maxDiscountAmount,
      usageLimit: entity.usageLimit,
      usedCount: entity.usedCount,
      startDate: entity.startDate,
      endDate: entity.endDate,
      status: entity.status, // Enums are shared from domain
      applicableProducts: List<String>.from(entity.applicableProducts),
      applicableCategories: List<String>.from(entity.applicableCategories),
      isFirstOrderOnly: entity.isFirstOrderOnly,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<Discount> toEntityList(List<model.DiscountModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static List<model.DiscountModel> toModelList(List<Discount> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
