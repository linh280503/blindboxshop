import '../../domain/entities/user.dart' as domain;
import '../models/user_model.dart' as model;

/// Mapper between User domain entity and UserModel DTO
class UserMapper {
  /// Convert UserModel (DTO) to User (Entity)
  static domain.User toEntity(
    model.UserModel model, {
    bool isEmailVerified = false,
  }) {
    return domain.User(
      uid: model.uid,
      email: model.email,
      name: model.name,
      phone: model.phone,
      avatar: model.avatar,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isActive: model.isActive,
      role: model.role,
      points: model.points,
      totalOrders: model.totalOrders,
      totalSpent: model.totalSpent,
      isEmailVerified: isEmailVerified,
    );
  }

  /// Convert User (Entity) to UserModel (DTO)
  static model.UserModel toModel(domain.User entity) {
    return model.UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      avatar: entity.avatar,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      role: entity.role,
      points: entity.points,
      totalOrders: entity.totalOrders,
      totalSpent: entity.totalSpent,
    );
  }
}
