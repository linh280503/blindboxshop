import '../../domain/entities/address.dart';
import '../models/address_model.dart' as model;

class AddressMapper {
  static Address toEntity(model.AddressModel model) {
    return Address(
      id: model.id,
      userId: model.userId,
      name: model.name,
      phone: model.phone,
      address: model.address,
      ward: model.ward,
      district: model.district,
      city: model.city,
      note: model.note,
      isDefault: model.isDefault,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static model.AddressModel toModel(Address entity) {
    return model.AddressModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      ward: entity.ward,
      district: entity.district,
      city: entity.city,
      note: entity.note,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert list of AddressModel to list of Address
  static List<Address> toEntityList(List<model.AddressModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convert list of Address to list of AddressModel
  static List<model.AddressModel> toModelList(List<Address> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
