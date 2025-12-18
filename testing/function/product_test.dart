import 'package:flutter_test/flutter_test.dart';

/// =============================================================================
/// TEST FILE 3: PRODUCT MODEL TEST
/// =============================================================================
/// 
/// MỤC ĐÍCH: Kiểm tra các chức năng của sản phẩm (Product)
/// - Kiểm tra sản phẩm đang giảm giá
/// - Kiểm tra sản phẩm hết hàng
/// - Kiểm tra loại sản phẩm (single/box/set)
/// - Tính tiền tiết kiệm khi mua box/set
/// 
/// CÁCH CHẠY: flutter test testing/function/product_test.dart

// ============== MOCK CLASSES ==============

enum ProductType { single, box, set, both }

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
  final bool isActive;
  final bool isFeatured;
  final ProductType productType;
  final int? boxSize;
  final double? boxPrice;
  final int? setSize;
  final double? setPrice;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    this.images = const [],
    required this.price,
    required this.originalPrice,
    this.discount = 0,
    required this.stock,
    this.rating = 0,
    this.reviewCount = 0,
    this.sold = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.productType = ProductType.single,
    this.boxSize,
    this.boxPrice,
    this.setSize,
    this.setPrice,
  });

  bool get isOnSale => discount > 0;
  double get finalPrice => price - discount;
  bool get isInStock => stock > 0;

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

  String get discountPercentage {
    if (originalPrice == 0) return '0%';
    return '${((discount / originalPrice) * 100).round()}%';
  }

  String get formattedPrice =>
      '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
}

// ============== TEST CASES ==============

void main() {
  group('Product - Sản phẩm', () {
    /// TEST 11: Kiểm tra sản phẩm đang giảm giá
    /// 
    /// MỤC ĐÍCH: Kiểm tra thuộc tính isOnSale và tính toán finalPrice
    /// khi sản phẩm có giảm giá.
    test('Test 11: Kiểm tra sản phẩm đang giảm giá', () {
      final product = ProductModel(
        id: 'prod-001',
        name: 'Labubu Series 5',
        description: 'Blind box Labubu mới nhất',
        category: 'labubu',
        brand: 'Pop Mart',
        price: 350000,
        originalPrice: 400000,
        discount: 50000,
        stock: 100,
      );

      expect(product.isOnSale, true);
      expect(product.finalPrice, 300000); // 350000 - 50000
      expect(product.discountPercentage, '13%'); // 50000/400000 * 100 ≈ 13%
    });

    /// TEST 12: Kiểm tra sản phẩm hết hàng
    /// 
    /// MỤC ĐÍCH: Kiểm tra thuộc tính isInStock khi stock = 0.
    test('Test 12: Kiểm tra sản phẩm hết hàng', () {
      final outOfStock = ProductModel(
        id: 'prod-002',
        name: 'Molly Limited Edition',
        description: 'Phiên bản giới hạn',
        category: 'molly',
        brand: 'Pop Mart',
        price: 500000,
        originalPrice: 500000,
        stock: 0,
      );

      final inStock = ProductModel(
        id: 'prod-003',
        name: 'Dimoo World',
        description: 'Blind box Dimoo',
        category: 'dimoo',
        brand: 'Pop Mart',
        price: 280000,
        originalPrice: 280000,
        stock: 50,
      );

      expect(outOfStock.isInStock, false);
      expect(inStock.isInStock, true);
    });

    /// TEST 13: Kiểm tra sản phẩm có thể mua Box/Set
    /// 
    /// MỤC ĐÍCH: Kiểm tra các điều kiện productType để xác định
    /// sản phẩm có thể mua dạng đơn lẻ, box, hoặc set.
    test('Test 13: Kiểm tra sản phẩm có thể mua Box/Set', () {
      final boxProduct = ProductModel(
        id: 'prod-004',
        name: 'Labubu Box',
        description: 'Mua nguyên box 12 con',
        category: 'labubu',
        brand: 'Pop Mart',
        price: 350000,
        originalPrice: 350000,
        stock: 20,
        productType: ProductType.box,
        boxSize: 12,
        boxPrice: 3800000,
      );

      final bothProduct = ProductModel(
        id: 'prod-005',
        name: 'Skullpanda All',
        description: 'Có thể mua đơn lẻ hoặc box',
        category: 'skullpanda',
        brand: 'Pop Mart',
        price: 320000,
        originalPrice: 320000,
        stock: 100,
        productType: ProductType.both,
        boxSize: 12,
        boxPrice: 3500000,
      );

      expect(boxProduct.canBuyBox, true);
      expect(boxProduct.canBuySingle, false);
      expect(bothProduct.canBuyBox, true);
      expect(bothProduct.canBuySingle, true);
    });

    /// TEST 14: Tính tiết kiệm khi mua Box/Set
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính số tiền tiết kiệm khi
    /// mua nguyên box thay vì mua lẻ từng sản phẩm.
    test('Test 14: Tính tiết kiệm khi mua Box/Set', () {
      final product = ProductModel(
        id: 'prod-006',
        name: 'Hirono World',
        description: 'Blind box Hirono',
        category: 'hirono',
        brand: 'Pop Mart',
        price: 350000, // Giá lẻ 1 con
        originalPrice: 350000,
        stock: 50,
        productType: ProductType.both,
        boxSize: 12, // 12 con/box
        boxPrice: 3800000, // Giá cả box
        setSize: 6,
        setPrice: 1900000,
      );

      // Box savings: 350000 * 12 - 3800000 = 4200000 - 3800000 = 400000
      expect(product.boxSavings, 400000);

      // Set savings: 350000 * 6 - 1900000 = 2100000 - 1900000 = 200000
      expect(product.setSavings, 200000);
    });
  });
}
