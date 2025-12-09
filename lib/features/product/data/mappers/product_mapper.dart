import '../../domain/entities/product.dart';
import '../models/product_model.dart' as model;

/// Mapper between Product domain entity and ProductModel DTO
class ProductMapper {
  /// Convert ProductModel (DTO) to Product (Entity)
  static Product toEntity(model.ProductModel model) {
    return Product(
      id: model.id,
      name: model.name,
      description: model.description,
      category: model.category,
      brand: model.brand,
      images: List<String>.from(model.images),
      price: model.price,
      originalPrice: model.originalPrice,
      discount: model.discount,
      stock: model.stock,
      rating: model.rating,
      reviewCount: model.reviewCount,
      sold: model.sold,
      searchKeywords: List<String>.from(model.searchKeywords),
      isActive: model.isActive,
      isFeatured: model.isFeatured,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      specifications: model.specifications != null
          ? Map<String, dynamic>.from(model.specifications!)
          : null,
      tags: model.tags != null ? List<String>.from(model.tags!) : null,
      productType: model.productType,
      boxSize: model.boxSize,
      boxPrice: model.boxPrice,
      setSize: model.setSize,
      setPrice: model.setPrice,
      boxContents: model.boxContents != null
          ? List<String>.from(model.boxContents!)
          : null,
      setContents: model.setContents != null
          ? List<String>.from(model.setContents!)
          : null,
    );
  }

  /// Convert Product (Entity) to ProductModel (DTO)
  static model.ProductModel toModel(Product entity) {
    return model.ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      brand: entity.brand,
      images: List<String>.from(entity.images),
      price: entity.price,
      originalPrice: entity.originalPrice,
      discount: entity.discount,
      stock: entity.stock,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      sold: entity.sold,
      searchKeywords: List<String>.from(entity.searchKeywords),
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      specifications: entity.specifications != null
          ? Map<String, dynamic>.from(entity.specifications!)
          : null,
      tags: entity.tags != null ? List<String>.from(entity.tags!) : null,
      productType: entity.productType,
      boxSize: entity.boxSize,
      boxPrice: entity.boxPrice,
      setSize: entity.setSize,
      setPrice: entity.setPrice,
      boxContents: entity.boxContents != null
          ? List<String>.from(entity.boxContents!)
          : null,
      setContents: entity.setContents != null
          ? List<String>.from(entity.setContents!)
          : null,
    );
  }

  /// Convert list of ProductModel to list of Product
  static List<Product> toEntityList(List<model.ProductModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convert list of Product to list of ProductModel
  static List<model.ProductModel> toModelList(List<Product> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
