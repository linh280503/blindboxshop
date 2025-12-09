import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_type.dart';

class ProductModel {
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

  ProductModel({
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

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      sold: data['sold'] ?? 0,
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      specifications: data['specifications'] as Map<String, dynamic>?,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      productType: ProductType.values.firstWhere(
        (e) => e.name == data['productType'],
        orElse: () => ProductType.single,
      ),
      boxSize: data['boxSize'],
      boxPrice: data['boxPrice']?.toDouble(),
      setSize: data['setSize'],
      setPrice: data['setPrice']?.toDouble(),
      boxContents: data['boxContents'] != null
          ? List<String>.from(data['boxContents'])
          : null,
      setContents: data['setContents'] != null
          ? List<String>.from(data['setContents'])
          : null,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      sold: data['sold'] ?? 0,
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      specifications: data['specifications'] as Map<String, dynamic>?,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      productType: ProductType.values.firstWhere(
        (e) => e.name == data['productType'],
        orElse: () => ProductType.single,
      ),
      boxSize: data['boxSize'],
      boxPrice: data['boxPrice']?.toDouble(),
      setSize: data['setSize'],
      setPrice: data['setPrice']?.toDouble(),
      boxContents: data['boxContents'] != null
          ? List<String>.from(data['boxContents'])
          : null,
      setContents: data['setContents'] != null
          ? List<String>.from(data['setContents'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'images': images,
      'price': price,
      'originalPrice': originalPrice,
      'discount': discount,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'sold': sold,
      'searchKeywords': searchKeywords,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'specifications': specifications,
      'tags': tags,
      'productType': productType.name,
      'boxSize': boxSize,
      'boxPrice': boxPrice,
      'setSize': setSize,
      'setPrice': setPrice,
      'boxContents': boxContents,
      'setContents': setContents,
    };
  }

  ProductModel copyWith({
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
    return ProductModel(
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
      sold: sold,
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

  // Các phương thức hỗ trợ
  bool get isOnSale => discount > 0;
  double get finalPrice => price - discount;
  bool get isInStock => stock > 0;
  String get formattedPrice =>
      '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';

  // Các phương thức hỗ trợ Box/Set
  bool get canBuyBox =>
      productType == ProductType.box || productType == ProductType.both;
  bool get canBuySet =>
      productType == ProductType.set || productType == ProductType.both;
  bool get canBuySingle =>
      productType == ProductType.single || productType == ProductType.both;

  String get formattedBoxPrice => boxPrice != null
      ? '${boxPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ'
      : '';

  String get formattedSetPrice => setPrice != null
      ? '${setPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ'
      : '';

  double get boxSavings => boxPrice != null && boxSize != null
      ? (price * boxSize!) - boxPrice!
      : 0.0;

  double get setSavings => setPrice != null && setSize != null
      ? (price * setSize!) - setPrice!
      : 0.0;
  String get formattedOriginalPrice =>
      '${originalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  String get discountPercentage =>
      '${(discount / originalPrice * 100).round()}%';
}
