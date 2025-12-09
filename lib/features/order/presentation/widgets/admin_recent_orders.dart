import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/order_model.dart';
import '../providers/order_provider.dart';
import '../../domain/entities/order_status.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminRecentOrders extends ConsumerWidget {
  const AdminRecentOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersStreamProvider);
    return ordersAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng gần đây',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push('/admin/orders'),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (e, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng gần đây',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push('/admin/orders'),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              'Lỗi tải dữ liệu: $e',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
      data: (orders) {
        final recentOrders = orders.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng gần đây',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/admin/orders'),
                  child: Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            if (recentOrders.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Chưa có đơn hàng nào',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentOrders.length,
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
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
                        // Top row: order number and total amount
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${order.orderNumber}',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${order.totalAmount.toStringAsFixed(0)} VNĐ',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6.h),

                        // Second row: status chip and actions aligned to end
                        Row(
                          children: [
                            _buildStatusChip(context, order.status),
                            const Spacer(),
                            if (order.status == OrderStatus.pending)
                              SizedBox(
                                height: 34.h,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _confirmOrder(context, order, ref),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: AppColors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Xác nhận',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ),
                            if (order.status == OrderStatus.pending)
                              SizedBox(width: 8.w),
                            SizedBox(
                              height: 34.h,
                              child: OutlinedButton(
                                onPressed: () =>
                                    _viewOrderDetails(context, order),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primary),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                                child: Text(
                                  'Chi tiết',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6.h),

                        // Meta info
                        Consumer(
                          builder: (context, ref, child) {
                            final userAsync = ref.watch(
                              userProfileProvider(order.userId),
                            );
                            return userAsync.when(
                              data: (user) {
                                final displayName =
                                    user?.name != null && user!.name.isNotEmpty
                                    ? user.name
                                    : (user?.email ?? order.userId);
                                return Text(
                                  displayName,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                );
                              },
                              loading: () => Text(
                                'Đang tải...',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              error: (_, __) => Text(
                                order.userId,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${order.items.length} sản phẩm • ${_formatDateTime(order.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'Chờ xác nhận';
        break;
      case OrderStatus.confirmed:
        statusColor = AppColors.info;
        statusText = 'Đã xác nhận';
        break;
      case OrderStatus.preparing:
        statusColor = AppColors.primary;
        statusText = 'Đang chuẩn bị';
        break;
      case OrderStatus.shipping:
        statusColor = AppColors.primary;
        statusText = 'Đang giao';
        break;
      case OrderStatus.delivered:
        statusColor = AppColors.success;
        statusText = 'Đã giao';
        break;
      case OrderStatus.completed:
        statusColor = AppColors.success;
        statusText = 'Hoàn thành';
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Không xác định';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmOrder(
    BuildContext context,
    OrderModel order,
    WidgetRef ref,
  ) async {
    try {
      await ref.read(ordersProvider.notifier).confirmOrder(order.id);
      if (context.mounted) {
        NotificationService.showSuccess(
          'Đã xác nhận đơn hàng #${order.orderNumber}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService.showError('Lỗi xác nhận đơn hàng: ${e.toString()}');
      }
    }
  }

  void _viewOrderDetails(BuildContext context, OrderModel order) {
    // Navigate to order details page
    context.push('/admin/orders', extra: {'orderId': order.id});
  }
}
