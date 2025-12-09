import '../../domain/entities/category.dart';
import '../models/category_model.dart' as model;

class CategoryMapper {
  static Category toEntity(model.CategoryModel model) {
    return Category(
      id: model.id,
      name: model.name,
      description: model.description,
      image: model.image,
      isActive: model.isActive,
      order: model.order,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static model.CategoryModel toModel(Category entity) {
    return model.CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      image: entity.image,
      isActive: entity.isActive,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<Category> toEntityList(List<model.CategoryModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static List<model.CategoryModel> toModelList(List<Category> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
