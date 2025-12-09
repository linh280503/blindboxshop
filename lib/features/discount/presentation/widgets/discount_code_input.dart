import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/discount_provider.dart';

class DiscountCodeInput extends ConsumerStatefulWidget {
  final double orderAmount;
  final List<Map<String, dynamic>> orderItems;
  final bool isFirstOrder;
  final Function(double discountAmount, String discountInfo)? onDiscountApplied;

  const DiscountCodeInput({
    super.key,
    required this.orderAmount,
    required this.orderItems,
    this.isFirstOrder = false,
    this.onDiscountApplied,
  });

  @override
  ConsumerState<DiscountCodeInput> createState() => _DiscountCodeInputState();
}

class _DiscountCodeInputState extends ConsumerState<DiscountCodeInput> {
  final TextEditingController _codeController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discountState = ref.watch(discountProvider);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Mã giảm giá',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  if (discountState.selectedDiscount != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Đã áp dụng',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(width: 8.w),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded) ...[
            Divider(height: 1, color: AppColors.lightGrey.withOpacity(0.3)),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Applied Discount Info
                  if (discountState.selectedDiscount != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                discountState.selectedDiscount!.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '-${discountState.discountAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Mã: ${discountState.selectedDiscount!.code}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(discountProvider.notifier).removeDiscount();
                          widget.onDiscountApplied?.call(0.0, '');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Xóa mã giảm giá',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Discount Code Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              hintText: 'Nhập mã giảm giá',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                            ),
                            style: TextStyle(fontSize: 14.sp),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        SizedBox(
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: discountState.isLoading
                                ? null
                                : _applyDiscount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: discountState.isLoading
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Áp dụng',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    // Error Message
                    if (discountState.error != null) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          discountState.error!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 12.h),

                    // First Order Discounts
                    if (widget.isFirstOrder) ...[
                      Text(
                        'Mã giảm giá cho đơn hàng đầu tiên:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Consumer(
                        builder: (context, ref, child) {
                          final firstOrderDiscounts = ref.watch(
                            firstOrderDiscountsProvider,
                          );
                          return firstOrderDiscounts.when(
                            data: (discounts) => Column(
                              children: discounts.take(3).map((discount) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 4.h),
                                  child: InkWell(
                                    onTap: () {
                                      _codeController.text = discount.code;
                                      _applyDiscount();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        // ignore: deprecated_member_use
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                        border: Border.all(
                                          // ignore: deprecated_member_use
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${discount.code} - ${discount.formattedValue}',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12.sp,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            loading: () => Center(
                              child: SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (error, stack) => Text(
                              'Không thể tải mã giảm giá',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.error,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _applyDiscount() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final success = await ref
        .read(discountProvider.notifier)
        .applyDiscountCode(
          code,
          widget.orderAmount,
          widget.orderItems,
          widget.isFirstOrder,
        );

    if (success) {
      final discountState = ref.read(discountProvider);
      widget.onDiscountApplied?.call(
        discountState.discountAmount,
        discountState.discountInfo,
      );
      _codeController.clear();
    }
  }
}
