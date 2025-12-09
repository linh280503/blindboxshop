import '../../domain/entities/review.dart';
import '../models/review_model.dart' as model;

class ReviewMapper {
  static Review toEntity(model.ReviewModel model) {
    return Review(
      id: model.id,
      productId: model.productId,
      userId: model.userId,
      userName: model.userName,
      userAvatar: model.userAvatar,
      rating: model.rating,
      comment: model.comment,
      images: List<String>.from(model.images),
      status: model.status, // Enums are shared from domain
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isVerified: model.isVerified,
      orderId: model.orderId,
      helpfulCount: model.helpfulCount,
      helpfulUsers: List<String>.from(model.helpfulUsers),
    );
  }

  static model.ReviewModel toModel(Review entity) {
    return model.ReviewModel(
      id: entity.id,
      productId: entity.productId,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      rating: entity.rating,
      comment: entity.comment,
      images: List<String>.from(entity.images),
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isVerified: entity.isVerified,
      orderId: entity.orderId,
      helpfulCount: entity.helpfulCount,
      helpfulUsers: List<String>.from(entity.helpfulUsers),
    );
  }

  /// Convert list of ReviewModel to list of Review
  static List<Review> toEntityList(List<model.ReviewModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convert list of Review to list of ReviewModel
  static List<model.ReviewModel> toModelList(List<Review> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
