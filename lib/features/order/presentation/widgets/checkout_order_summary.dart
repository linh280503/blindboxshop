import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double shippingFee;
  final double discountAmount;

  const CheckoutOrderSummary({
    super.key,
    required this.items,
    required this.shippingFee,
    required this.discountAmount,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final total = subtotal + shippingFee - discountAmount;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Tóm tắt đơn hàng',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Order Items
          ...items.map((item) => _buildOrderItem(context, item)),

          SizedBox(height: 16.h),

          Divider(color: AppColors.lightGrey),

          SizedBox(height: 16.h),

          // Price Breakdown
          _buildPriceRow(context, 'Tạm tính', subtotal),

          _buildPriceRow(
            context,
            'Phí vận chuyển',
            shippingFee,
            isShipping: true,
          ),

          if (discountAmount > 0)
            _buildPriceRow(
              context,
              'Giảm giá',
              -discountAmount,
              isDiscount: true,
            ),

          SizedBox(height: 12.h),

          Divider(color: AppColors.lightGrey, thickness: 2),

          SizedBox(height: 12.h),

          _buildPriceRow(context, 'Tổng cộng', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.surfaceVariant,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child:
                  (item['productImage'] is String &&
                      ((item['productImage'] as String).startsWith('http') ||
                          (item['productImage'] as String).startsWith('https')))
                  ? Image.network(
                      item['productImage'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        );
                      },
                    )
                  : Image.asset(
                      item['productImage'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        );
                      },
                    ),
            ),
          ),

          SizedBox(width: 12.w),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['productName'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 4.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Số lượng: ${item['quantity']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(item['price'] * item['quantity']).toStringAsFixed(0)} VNĐ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
    bool isShipping = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            isShipping && amount == 0
                ? 'Miễn phí'
                : '${amount.toStringAsFixed(0)} VNĐ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDiscount
                  ? AppColors.error
                  : isTotal
                  ? AppColors.primary
                  : isShipping && amount == 0
                  ? AppColors.success
                  : AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return items.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
  }
}
