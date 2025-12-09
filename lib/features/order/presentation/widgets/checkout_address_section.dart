import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../address/data/models/address_model.dart';

class CheckoutAddressSection extends StatelessWidget {
  final List<AddressModel> addresses;
  final String selectedAddressId;
  final Function(String) onAddressSelected;
  final VoidCallback onAddNewAddress;

  const CheckoutAddressSection({
    super.key,
    required this.addresses,
    required this.selectedAddressId,
    required this.onAddressSelected,
    required this.onAddNewAddress,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Địa chỉ giao hàng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onAddNewAddress,
                child: Text(
                  'Thêm địa chỉ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Address List
          ...addresses.map((address) => _buildAddressItem(context, address)),
        ],
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, AddressModel address) {
    final isSelected = address.id == selectedAddressId;

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
        onTap: () => onAddressSelected(address.id),
        child: Row(
          children: [
            Radio<String>(
              value: address.id,
              groupValue: selectedAddressId,
              onChanged: (value) => onAddressSelected(value!),
              activeColor: AppColors.primary,
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Mặc định',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Phone row
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          address.phone,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    '${address.address}, ${address.ward}, ${address.district}, ${address.city}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.visible,
                    maxLines: null,
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
