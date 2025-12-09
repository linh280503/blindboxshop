import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../providers/order_provider.dart';

class OrderDetailPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderStreamProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi tải đơn hàng: $e')),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng'));
          }
          return _buildOrderContent(context, order);
        },
      ),
    );
  }

  Widget _buildOrderContent(BuildContext context, OrderModel order) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildHeader(context, order),
        SizedBox(height: 12.h),
        _buildAddress(context, order),
        SizedBox(height: 12.h),
        _buildItems(context, order),
        SizedBox(height: 12.h),
        _buildTotals(context, order),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng #${order.orderNumber}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  order.statusText,
                  style: TextStyle(
                    color: order.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text('Ngày tạo: ${order.createdAt.toString().split(' ').first}'),
          if (order.statusNote != null && order.statusNote!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text('Ghi chú: ${order.statusNote!}'),
          ],
        ],
      ),
    );
  }

  Widget _buildAddress(BuildContext context, OrderModel order) {
    final addr = order.deliveryAddress ?? const {};
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Địa chỉ giao hàng',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text('${addr['name']} • ${addr['phone']}'),
          SizedBox(height: 4.h),
          Text(
            '${addr['address']}, ${addr['ward']}, ${addr['district']}, ${addr['city']}',
          ),
          if ((order.note ?? '').isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text('Ghi chú: ${order.note!}'),
          ],
        ],
      ),
    );
  }

  Widget _buildItems(BuildContext context, OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sản phẩm',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          ...order.items.map((it) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      it.productImage,
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50.w,
                        height: 50.w,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text('Số lượng: ${it.quantity}'),
                      ],
                    ),
                  ),
                  Text('${it.price.toStringAsFixed(0)}₫'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context, OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thanh toán',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          _row('Tạm tính', '${order.subtotal.toStringAsFixed(0)}₫'),
          _row('Phí vận chuyển', '${order.shippingFee.toStringAsFixed(0)}₫'),
          if (order.discountAmount > 0)
            _row('Giảm giá', '-${order.discountAmount.toStringAsFixed(0)}₫'),
          Divider(height: 16.h),
          _row(
            'Tổng cộng',
            '${order.totalAmount.toStringAsFixed(0)}₫',
            isEmphasis: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isEmphasis = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isEmphasis ? FontWeight.bold : FontWeight.normal,
              color: isEmphasis ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
