import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/product_card.dart';
import '../providers/product_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HotProductsSection extends ConsumerWidget {
  const HotProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotProductsAsync = ref.watch(hotProductsProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.error,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Sản phẩm hot',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.go('/products?type=hot');
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
          SizedBox(
            height: 294.h,
            child: hotProductsAsync.when(
              data: (hotProducts) {
                if (hotProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có sản phẩm hot',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hotProducts.length,
                  itemBuilder: (context, index) {
                    final product = hotProducts[index];
                    return Container(
                      width: 180.w,
                      margin: EdgeInsets.only(right: 12.w),
                      child: ProductCard(
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
                        isFavorite: false,
                        product: product,
                        onTap: () {
                          context.go('/product/${product.id}');
                        },
                        onAddToCart: () async {
                          final authState = ref.read(authProvider);
                          if (authState.user == null) {
                            if (context.mounted) {
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
                        onToggleFavorite: () {},
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Lỗi tải sản phẩm hot: $error',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
