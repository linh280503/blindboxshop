import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../services/notification_service.dart';

class StockNotification {
  // Hiển thị thông báo tồn kho thấp
  static void showLowStockSnackBar(
    BuildContext context,
    String productName,
    int stock,
  ) {
    NotificationService.showWarning('$productName chỉ còn $stock sản phẩm');
  }

  // Hiển thị thông báo hết hàng
  static void showOutOfStockSnackBar(BuildContext context, String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '$productName đã hết hàng',
                style: TextStyle(fontSize: 14.sp, color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  // Hiển thị thông báo vượt quá tồn kho
  static void showExceedStockSnackBar(
    BuildContext context,
    String productName,
    int maxStock,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '$productName chỉ còn tối đa $maxStock sản phẩm',
                style: TextStyle(fontSize: 14.sp, color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  // Hiển thị dialog xác nhận khi tồn kho thấp
  static Future<bool?> showLowStockDialog(
    BuildContext context,
    String productName,
    int stock,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Tồn kho thấp',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          '$productName chỉ còn $stock sản phẩm. Bạn có muốn tiếp tục mua không?',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.white,
            ),
            child: Text('Tiếp tục', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog xác nhận khi hết hàng
  static Future<void> showOutOfStockDialog(
    BuildContext context,
    String productName,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Hết hàng',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          '$productName đã hết hàng. Vui lòng chọn sản phẩm khác hoặc thông báo khi có hàng.',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Đóng',
              style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text(
              'Thông báo khi có hàng',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị trạng thái tồn kho
  static Widget buildStockStatusWidget(int stock) {
    String status;
    Color color;
    IconData icon;

    if (stock == 0) {
      status = 'Hết hàng';
      color = AppColors.error;
      icon = Icons.error_outline;
    } else if (stock <= 5) {
      status = 'Sắp hết hàng';
      color = AppColors.warning;
      icon = Icons.warning_amber_rounded;
    } else if (stock <= 20) {
      status = 'Còn ít';
      color = AppColors.info;
      icon = Icons.info_outline;
    } else {
      status = 'Còn hàng';
      color = AppColors.success;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 7.sp, color: color),
          SizedBox(width: 1.w),
          Text(
            status,
            style: TextStyle(
              fontSize: 6.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị số lượng tồn kho
  static Widget buildStockQuantityWidget(int stock) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        'Còn $stock',
        style: TextStyle(
          fontSize: 10.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
