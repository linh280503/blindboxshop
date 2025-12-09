import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class CartSummary extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback onCheckout;

  const CartSummary({super.key, required this.items, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final shippingFee = _calculateShippingFee();
    final discount = _calculateDiscount();
    final total = subtotal + shippingFee - discount;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary Items
          _buildSummaryRow(
            context,
            'Tạm tính',
            '${subtotal.toStringAsFixed(0)} VNĐ',
          ),

          if (shippingFee > 0)
            _buildSummaryRow(
              context,
              'Phí vận chuyển',
              '${shippingFee.toStringAsFixed(0)} VNĐ',
            ),

          if (discount > 0)
            _buildSummaryRow(
              context,
              'Giảm giá',
              '-${discount.toStringAsFixed(0)} VNĐ',
              isDiscount: true,
            ),

          Divider(color: AppColors.lightGrey),

          _buildSummaryRow(
            context,
            'Tổng cộng',
            '${total.toStringAsFixed(0)} VNĐ',
            isTotal: true,
          ),

          SizedBox(height: 16.h),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                'Thanh toán',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
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
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDiscount
                  ? AppColors.error
                  : isTotal
                  ? AppColors.primary
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

  double _calculateShippingFee() {
    // Mock shipping fee calculation
    final subtotal = _calculateSubtotal();
    if (subtotal >= 500000) {
      return 0; // Free shipping for orders >= 500k
    }
    return 30000; // 30k shipping fee
  }

  double _calculateDiscount() {
    // Mock discount calculation
    final subtotal = _calculateSubtotal();
    if (subtotal >= 1000000) {
      return subtotal * 0.1; // 10% discount for orders >= 1M
    }
    return 0;
  }
}
