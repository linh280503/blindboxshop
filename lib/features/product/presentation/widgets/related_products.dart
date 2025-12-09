// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import 'product_card.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RelatedProducts extends ConsumerStatefulWidget {
  final String productId;
  final String category;

  const RelatedProducts({
    super.key,
    required this.productId,
    required this.category,
  });

  @override
  ConsumerState<RelatedProducts> createState() => _RelatedProductsState();
}

class _RelatedProductsState extends ConsumerState<RelatedProducts> {
  // Yêu thích tạm thời cho demo
  final Set<String> _favoriteIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final relatedAsync = ref.watch(
      relatedProductsByCategoryProvider(widget.category),
    );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Sản phẩm liên quan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to category products
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Products Grid
          relatedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: EdgeInsets.all(12.w),
              child: Text('Lỗi tải sản phẩm liên quan: $e'),
            ),
            data: (products) {
              final items = products
                  .where((p) => p.id != widget.productId)
                  .take(4)
                  .toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 0.45,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return ProductCard(
                    id: product.id,
                    name: product.name,
                    brand: product.brand,
                    price: product.price,
                    originalPrice: product.originalPrice,
                    image: product.images.isNotEmpty
                        ? product.images.first
                        : '',
                    rating: product.rating,
                    sold: product.sold,
                    reviewCount: product.reviewCount,
                    isFavorite: _favoriteIds.contains(product.id),
                    onToggleFavorite: () {
                      setState(() {
                        final id = product.id;
                        if (_favoriteIds.contains(id)) {
                          _favoriteIds.remove(id);
                        } else {
                          _favoriteIds.add(id);
                        }
                      });
                    },
                    onAddToCart: () async {
                      // Kiểm tra đăng nhập trước khi thêm vào giỏ hàng
                      final authState = ref.read(authProvider);
                      if (authState.user == null) {
                        // Chưa đăng nhập, chuyển hướng đến trang đăng nhập
                        if (mounted) {
                          context.go('/login');
                        }
                        return;
                      }

                      await ref
                          .read(cartProvider.notifier)
                          .addItem(
                            product.id,
                            product.name,
                            product.price,
                            product.images.isNotEmpty
                                ? product.images.first
                                : '',
                            quantity: 1,
                            productType: product.productType.name,
                            boxSize: product.boxSize,
                            setSize: product.setSize,
                          );
                    },
                    onTap: () {
                      context.goNamed(
                        'product-detail',
                        pathParameters: {'id': product.id},
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
