import '../entities/product_type.dart';

/// Product domain entity
/// Pure business object, no dependencies on external frameworks
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final List<String> images;
  final double price;
  final double originalPrice;
  final double discount;
  final int stock;
  final double rating;
  final int reviewCount;
  final int sold;
  final List<String> searchKeywords;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? specifications;
  final List<String>? tags;

  // Chức năng Box/Set
  final ProductType productType;
  final int? boxSize; // Số sản phẩm trong 1 box
  final double? boxPrice; // Giá mua cả box
  final int? setSize; // Số sản phẩm trong 1 set
  final double? setPrice; // Giá mua cả set
  final List<String>? boxContents; // Danh sách sản phẩm trong box
  final List<String>? setContents; // Danh sách sản phẩm trong set

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.images,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    required this.sold,
    required this.searchKeywords,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    this.specifications,
    this.tags,
    required this.productType,
    this.boxSize,
    this.boxPrice,
    this.setSize,
    this.setPrice,
    this.boxContents,
    this.setContents,
  });

  // Business logic methods
  bool get isOnSale => discount > 0;
  double get finalPrice => price - discount;
  bool get isInStock => stock > 0;

  // Box/Set methods
  bool get canBuyBox =>
      productType == ProductType.box || productType == ProductType.both;
  bool get canBuySet =>
      productType == ProductType.set || productType == ProductType.both;
  bool get canBuySingle =>
      productType == ProductType.single || productType == ProductType.both;

  double get boxSavings => boxPrice != null && boxSize != null
      ? (price * boxSize!) - boxPrice!
      : 0.0;

  double get setSavings => setPrice != null && setSize != null
      ? (price * setSize!) - setPrice!
      : 0.0;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? brand,
    List<String>? images,
    double? price,
    double? originalPrice,
    double? discount,
    int? stock,
    double? rating,
    int? reviewCount,
    int? sold,
    List<String>? searchKeywords,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    ProductType? productType,
    int? boxSize,
    double? boxPrice,
    int? setSize,
    double? setPrice,
    List<String>? boxContents,
    List<String>? setContents,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discount: discount ?? this.discount,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      sold: sold ?? this.sold,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
      productType: productType ?? this.productType,
      boxSize: boxSize ?? this.boxSize,
      boxPrice: boxPrice ?? this.boxPrice,
      setSize: setSize ?? this.setSize,
      setPrice: setPrice ?? this.setPrice,
      boxContents: boxContents ?? this.boxContents,
      setContents: setContents ?? this.setContents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
