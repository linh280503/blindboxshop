import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class ProductActions extends StatelessWidget {
  final String productId;
  final int quantity;
  final int stock;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const ProductActions({
    super.key,
    required this.productId,
    required this.quantity,
    required this.stock,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stock Status
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: stock > 0 ? AppColors.success : AppColors.error,
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  stock > 0 ? 'Còn hàng ($stock sản phẩm)' : 'Hết hàng',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: stock > 0 ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Action Buttons - Shopee Style
          Row(
            children: [
              // Add to Cart Button
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: stock > 0 ? onAddToCart : null,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: AppColors.primary,
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Thêm vào giỏ',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Buy Now Button
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: stock > 0 ? onBuyNow : null,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Center(
                        child: Text(
                          'Mua ngay',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
