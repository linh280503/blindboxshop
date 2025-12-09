import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;
  final bool isSelected;
  final VoidCallback? onTap;

  const AddressCard({
    super.key,
    required this.address,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 0, maxWidth: double.infinity),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.lightGrey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
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
              // Header with name and default badge
              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      address.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (address.isDefault) ...[
                    SizedBox(width: 4.w),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Mặc định',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8.h),

              // Phone number
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      address.phone,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      address.fullAddress,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              // Note
              if (address.note != null && address.note!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        address.note!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Actions
              if (onEdit != null ||
                  onDelete != null ||
                  onSetDefault != null) ...[
                SizedBox(height: 12.h),
                Divider(height: 1, color: AppColors.lightGrey.withOpacity(0.3)),
                SizedBox(height: 12.h),
                IntrinsicWidth(
                  child: Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: [
                      if (onEdit != null)
                        _buildCompactActionButton(
                          icon: Icons.edit_outlined,
                          label: 'Sửa',
                          color: AppColors.primary,
                          onPressed: onEdit!,
                        ),
                      if (onDelete != null && !address.isDefault)
                        _buildCompactActionButton(
                          icon: Icons.delete_outline,
                          label: 'Xóa',
                          color: AppColors.error,
                          onPressed: onDelete!,
                        ),
                      if (onSetDefault != null && !address.isDefault)
                        _buildCompactActionButton(
                          icon: Icons.star_outline,
                          label: 'Mặc định',
                          color: AppColors.warning,
                          onPressed: onSetDefault!,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
