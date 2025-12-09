import '../../domain/entities/banner.dart';
import '../models/banner_model.dart' as model;

class BannerMapper {
  static Banner toEntity(model.BannerModel model) {
    return Banner(
      id: model.id,
      title: model.title,
      subtitle: model.subtitle,
      image: model.image,
      link: model.link,
      linkType: model.linkType,
      linkValue: model.linkValue,
      isActive: model.isActive,
      order: model.order,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static model.BannerModel toModel(Banner entity) {
    return model.BannerModel(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      image: entity.image,
      link: entity.link,
      linkType: entity.linkType,
      linkValue: entity.linkValue,
      isActive: entity.isActive,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<Banner> toEntityList(List<model.BannerModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static List<model.BannerModel> toModelList(List<Banner> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
