import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';

class ProductPurchaseOptions extends StatefulWidget {
  final ProductModel product;
  final Function(PurchaseType type, int quantity) onPurchase;
  final int currentQuantity;

  const ProductPurchaseOptions({
    super.key,
    required this.product,
    required this.onPurchase,
    this.currentQuantity = 1,
  });

  @override
  State<ProductPurchaseOptions> createState() => _ProductPurchaseOptionsState();
}

class _ProductPurchaseOptionsState extends State<ProductPurchaseOptions> {
  PurchaseType _selectedType = PurchaseType.single;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _quantity = widget.currentQuantity;

    // Set default purchase type based on product capabilities
    if (widget.product.canBuySingle) {
      _selectedType = PurchaseType.single;
    } else if (widget.product.canBuyBox) {
      _selectedType = PurchaseType.box;
    } else if (widget.product.canBuySet) {
      _selectedType = PurchaseType.set;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purchase Type Selection
          Text(
            'Chọn cách mua',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          // Single Purchase Option
          if (widget.product.canBuySingle)
            _buildPurchaseOption(
              type: PurchaseType.single,
              title: 'Mua đơn lẻ',
              price: widget.product.price,
              description: 'Mua từng sản phẩm riêng lẻ',
              icon: Icons.shopping_bag_outlined,
            ),

          // Box Purchase Option
          if (widget.product.canBuyBox)
            _buildPurchaseOption(
              type: PurchaseType.box,
              title: 'Mua theo Box (${widget.product.boxSize} sản phẩm)',
              price: widget.product.boxPrice!,
              description:
                  'Tiết kiệm ${widget.product.boxSavings.toStringAsFixed(0)}đ',
              icon: Icons.inventory_2_outlined,
              isRecommended: true,
            ),

          // Set Purchase Option
          if (widget.product.canBuySet)
            _buildPurchaseOption(
              type: PurchaseType.set,
              title: 'Mua theo Set (${widget.product.setSize} sản phẩm)',
              price: widget.product.setPrice!,
              description:
                  'Tiết kiệm ${widget.product.setSavings.toStringAsFixed(0)}đ',
              icon: Icons.shopping_cart_outlined,
            ),

          SizedBox(height: 16.h),

          // Quantity Selection (only for single purchase)
          if (_selectedType == PurchaseType.single) ...[
            Text(
              'Số lượng',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _buildQuantitySelector(),
          ],

          SizedBox(height: 16.h),

          // Purchase Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                widget.onPurchase(_selectedType, _quantity);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                _getPurchaseButtonText(),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOption({
    required PurchaseType type,
    required String title,
    required double price,
    required String description,
    required IconData icon,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _quantity = 1; // Reset quantity when changing type
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.lightGrey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Tiết kiệm',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: IconButton(
            onPressed: _quantity > 1
                ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                : null,
            icon: Icon(
              Icons.remove,
              size: 16.sp,
              color: _quantity > 1
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          '$_quantity',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 16.w),
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: IconButton(
            onPressed: _quantity < widget.product.stock
                ? () {
                    setState(() {
                      _quantity++;
                    });
                  }
                : null,
            icon: Icon(
              Icons.add,
              size: 16.sp,
              color: _quantity < widget.product.stock
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'Còn ${widget.product.stock} sản phẩm',
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _getPurchaseButtonText() {
    switch (_selectedType) {
      case PurchaseType.single:
        return 'Thêm vào giỏ hàng';
      case PurchaseType.box:
        return 'Mua Box (${widget.product.boxSize} sản phẩm)';
      case PurchaseType.set:
        return 'Mua Set (${widget.product.setSize} sản phẩm)';
    }
  }
}

enum PurchaseType { single, box, set }
