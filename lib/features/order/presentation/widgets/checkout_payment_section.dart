import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutPaymentSection extends StatelessWidget {
  final List<Map<String, dynamic>> paymentMethods;
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodSelected;

  const CheckoutPaymentSection({
    super.key,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
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
                Icons.payment_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Phương thức thanh toán',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Payment Methods List
          ...paymentMethods.map(
            (method) => _buildPaymentMethodItem(context, method),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    BuildContext context,
    Map<String, dynamic> method,
  ) {
    final isSelected = method['id'] == selectedPaymentMethod;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.lightGrey,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8.r),
        color: isSelected
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.white,
      ),
      child: GestureDetector(
        onTap: () => onPaymentMethodSelected(method['id']),
        child: Row(
          children: [
            Radio<String>(
              value: method['id'],
              groupValue: selectedPaymentMethod,
              onChanged: (value) => onPaymentMethodSelected(value!),
              activeColor: AppColors.primary,
            ),

            SizedBox(width: 12.w),

            Icon(
              method['icon'],
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24.sp,
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    method['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
