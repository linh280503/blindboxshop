// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/stock_notification.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatefulWidget {
  final String id;
  final String name;
  final String brand;
  final String image;
  final double price;
  final double? originalPrice;
  final double rating;
  final int sold;
  final int reviewCount;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final double width;
  final double margin;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final ProductModel? product;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.sold,
    required this.reviewCount,
    this.onTap,
    this.onAddToCart,
    this.width = 160,
    this.margin = 8,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get hasDiscount =>
      widget.originalPrice != null && widget.originalPrice! > widget.price;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            onTap: () {
              _animationController.reverse();
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
            child: Container(
              width: widget.width,
              margin: EdgeInsets.all(widget.margin),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.08),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.04),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: _isPressed
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.lightGrey.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image với Badge giảm giá và Favorite
                  Stack(
                    children: [
                      Container(
                        height: 138.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.surfaceVariant.withOpacity(0.3),
                              AppColors.surfaceVariant.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                          child: widget.image.isNotEmpty
                              ? Image.network(
                                  widget.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                )
                              : _buildImagePlaceholder(),
                        ),
                      ),

                      // Discount Badge - Modern Design
                      if (hasDiscount)
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.error,
                                  AppColors.error.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error.withOpacity(0.3),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Text(
                              '-${((widget.originalPrice! - widget.price) / widget.originalPrice! * 100).round()}%',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                      // Favorite Button - Modern Design
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: widget.onToggleFavorite,
                          child: Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.isFavorite
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Product Info - Modern Design
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand - reserve fixed height to keep cards equal
                          SizedBox(
                            height: 12.h,
                            child: widget.brand.isNotEmpty
                                ? Text(
                                    widget.brand.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary.withOpacity(0.7),
                                      letterSpacing: 0.5,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(height: 2.h),

                          // Product Name - fixed height (2 lines)
                          SizedBox(
                            height: 32.h,
                            child: Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          // Rating và Stock Status
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: AppColors.warning,
                                        size: 10.sp,
                                      ),
                                      SizedBox(width: 1.w),
                                      Flexible(
                                        child: Text(
                                          widget.rating.toString(),
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.warning,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                flex: 2,
                                child: Text(
                                  '(${widget.reviewCount})',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.product != null) ...[
                                SizedBox(width: 4.w),
                                Flexible(
                                  flex: 3,
                                  child:
                                      StockNotification.buildStockStatusWidget(
                                        widget.product!.stock,
                                      ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: 4.h),

                          // Price - Modern Design
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${widget.price.toStringAsFixed(0)}₫',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasDiscount) ...[
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    '${widget.originalPrice!.toStringAsFixed(0)}₫',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: AppColors.textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: 4.h),

                          // Purchase Options
                          if (widget.product?.canBuyBox == true ||
                              widget.product?.canBuySet == true)
                            _buildPurchaseOptions()
                          else
                            // Add to Cart Button - Modern Design
                            SizedBox(
                              width: double.infinity,
                              height: 22.h,
                              child: ElevatedButton(
                                onPressed: widget.onAddToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Thêm',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceVariant.withOpacity(0.3),
            AppColors.surfaceVariant.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: 32.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              'No Image',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOptions() {
    if (widget.product == null) return SizedBox.shrink();

    return Column(
      children: [
        // Box option
        if (widget.product!.canBuyBox)
          Container(
            width: double.infinity,
            height: 28.h,
            margin: EdgeInsets.only(bottom: 4.h),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
              ),
              child: Text(
                'Box ${widget.product!.boxSize} (${widget.product!.formattedBoxPrice})',
                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),

        // Set option
        if (widget.product!.canBuySet)
          SizedBox(
            width: double.infinity,
            height: 28.h,
            child: ElevatedButton(
              onPressed: () {
                // Set purchase functionality - implement when needed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
              ),
              child: Text(
                'Set ${widget.product!.setSize} (${widget.product!.formattedSetPrice})',
                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
