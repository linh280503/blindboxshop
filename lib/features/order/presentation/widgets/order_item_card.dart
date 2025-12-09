import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../domain/entities/order_status.dart';

class OrderItemCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;
  final VoidCallback? onReorder;
  final VoidCallback? onConfirmReceived;

  const OrderItemCard({
    super.key,
    required this.order,
    this.onTap,
    this.onCancel,
    this.onReview,
    this.onReorder,
    this.onConfirmReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đơn hàng #${order.orderNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(context),
                  ],
                ),

                SizedBox(height: 12.h),

                // Order Items
                ...order.items.map<Widget>(
                  (item) => _buildOrderItem(context, item),
                ),

                SizedBox(height: 12.h),

                Divider(color: AppColors.lightGrey),

                SizedBox(height: 12.h),

                // Order Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng cộng: ${order.totalAmount.toStringAsFixed(0)} VNĐ',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${order.totalItems} sản phẩm • ${order.createdAt.toString().split(' ').first}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Action Buttons
                    _buildActionButtons(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final statusColor = order.statusColor;
    final statusText = order.statusText;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              color: AppColors.surfaceVariant,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.network(
                item.productImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    color: AppColors.textSecondary,
                    size: 16.sp,
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = order.status;
    final buttons = <Widget>[];

    if ((status == OrderStatus.confirmed || status == OrderStatus.shipping) &&
        onConfirmReceived != null) {
      buttons.add(
        Expanded(
          child: TextButton(
            onPressed: onConfirmReceived,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              'Đã nhận hàng',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      );
    }

    if (status == OrderStatus.pending && onCancel != null) {
      buttons.add(
        Expanded(
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      );
    }

    if (status == OrderStatus.delivered || status == OrderStatus.completed) {
      if (onReview != null) {
        buttons.add(
          Expanded(
            child: TextButton(
              onPressed: onReview,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              child: Text(
                'Đánh giá',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        );
      }
      if (onReorder != null) {
        buttons.add(
          Expanded(
            child: TextButton(
              onPressed: onReorder,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              child: Text(
                'Mua lại',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        );
      }
    }

    if (status != OrderStatus.delivered && status != OrderStatus.cancelled) {
      buttons.add(
        Expanded(
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              'Chi tiết',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(children: buttons);
  }
}
