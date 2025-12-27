import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_actions.dart';
import '../widgets/product_reviews.dart';
import '../widgets/related_products.dart';
import '../providers/product_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage>
    with AutomaticKeepAliveClientMixin {
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    // Use stream provider for realtime updates (sold, rating, reviewCount, stock)
    final productAsync = ref.watch(productStreamProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.white,
            expandedHeight: 0,
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
          ),

          // Product content
          productAsync.when(
            loading: () => SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải sản phẩm...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            error: (e, st) => SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Lỗi tải sản phẩm: $e'),
              ),
            ),
            data: (product) {
              if (product == null) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Sản phẩm không tồn tại'),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Images
                  RepaintBoundary(
                    child: ProductImageCarousel(
                      images: product.images,
                      selectedIndex: _selectedImageIndex,
                      onImageSelected: (index) {
                        setState(() {
                          _selectedImageIndex = index;
                        });
                      },
                    ),
                  ),

                  // Info
                  RepaintBoundary(
                    child: ProductInfoSection(
                      product: {
                        'id': product.id,
                        'name': product.name,
                        'brand': product.brand,
                        'category': product.category,
                        'price': product.price,
                        'originalPrice': product.originalPrice,
                        'stock': product.stock,
                        'sold': product.sold,
                        'rating': product.rating,
                        'reviewCount': product.reviewCount,
                        'description': product.description,
                        'specifications': product.specifications,
                        'tags': product.tags,
                      },
                      quantity: _quantity,
                      onQuantityChanged: (q) {
                        setState(() {
                          _quantity = q;
                        });
                      },
                    ),
                  ),

                  // Actions
                  RepaintBoundary(
                    child: ProductActions(
                      productId: widget.productId,
                      quantity: _quantity,
                      stock: product.stock,
                      onAddToCart: _addToCart,
                      onBuyNow: _buyNow,
                    ),
                  ),

                  // Reviews
                  RepaintBoundary(
                    child: ProductReviews(
                      productId: widget.productId,
                      rating: product.rating,
                      reviewCount: product.reviewCount,
                    ),
                  ),

                  // Related
                  RepaintBoundary(
                    child: RelatedProducts(
                      productId: widget.productId,
                      category: product.category,
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addToCart() async {
    try {
      // Kiểm tra đăng nhập trước khi thêm vào giỏ hàng
      final authState = ref.read(authProvider);
      if (authState.user == null) {
        // Chưa đăng nhập, chuyển hướng đến trang đăng nhập
        if (mounted) {
          context.go('/login');
        }
        return;
      }

      final productAsync = ref.read(productByIdProvider(widget.productId));
      final product = productAsync.value;
      if (product == null) {
        throw Exception('Không tìm thấy thông tin sản phẩm');
      }

      // Thêm sản phẩm vào giỏ hàng
      await ref
          .read(cartProvider.notifier)
          .addItem(
            product.id,
            product.name,
            product.price,
            product.images.isNotEmpty ? product.images.first : '',
            quantity: _quantity,
          );
    } catch (e) {
      // Error handling is done in cartProvider.addItem()
    }
  }

  void _buyNow() async {
    try {
      final productAsync = ref.read(productByIdProvider(widget.productId));
      final product = productAsync.value;
      if (product == null) {
        throw Exception('Không tìm thấy thông tin sản phẩm');
      }

      // Thêm sản phẩm vào giỏ hàng trước khi checkout
      final success = await ref
          .read(cartProvider.notifier)
          .addItem(
            product.id,
            product.name,
            product.price,
            product.images.isNotEmpty ? product.images.first : '',
            quantity: _quantity,
            productType: product.productType.name,
            boxSize: product.boxSize,
            setSize: product.setSize,
          );

      if (success) {
        context.go('/checkout', extra: [product.id]);
      }
      // Error handling is done in cartProvider.addItem()
    } catch (e) {
      // Error handling is done in cartProvider.addItem()
    }
  }
}
