import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../domain/entities/order_status.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminOrderDetailDialog extends ConsumerWidget {
  final OrderModel order;

  const AdminOrderDetailDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(16.w),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 600.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusSection(context),
                    SizedBox(height: 24.h),
                    _buildCustomerSection(context, ref),
                    SizedBox(height: 24.h),
                    _buildShippingSection(context),
                    SizedBox(height: 24.h),
                    _buildProductList(context),
                    SizedBox(height: 24.h),
                    _buildPaymentSection(context),
                    SizedBox(height: 24.h),
                    _buildOrderSummary(context),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chi tiết đơn hàng',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusDisplayName(order.status);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái đơn hàng',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Mã đơn hàng',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '#${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin khách hàng',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final userAsync = ref.watch(userProfileProvider(order.userId));
              return userAsync.when(
                data: (user) {
                  final name = user?.name != null && user!.name.isNotEmpty
                      ? user.name
                      : 'Chưa cập nhật tên';
                  final email = user?.email ?? '—';
                  final phone = user?.phone ?? '—';

                  return Column(
                    children: [
                      _buildInfoRow(Icons.person_outline, 'Họ tên', name),
                      Divider(height: 24.h, color: Colors.grey[200]),
                      _buildInfoRow(Icons.email_outlined, 'Email', email),
                      Divider(height: 24.h, color: Colors.grey[200]),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Số điện thoại',
                        phone,
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text('Không thể tải thông tin khách hàng'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShippingSection(BuildContext context) {
    final address = order.deliveryAddress;
    final fullAddress = _formatAddress(address);
    final note = order.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin giao hàng',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.location_on_outlined,
                'Địa chỉ',
                fullAddress,
                isMultiLine: true,
              ),
              if (note != null && note.isNotEmpty) ...[
                Divider(height: 24.h, color: Colors.grey[200]),
                _buildInfoRow(
                  Icons.note_alt_outlined,
                  'Ghi chú',
                  note,
                  isMultiLine: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sản phẩm (${order.items.length})',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: order.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == order.items.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                            image: item.productImage.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(item.productImage),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: item.productImage.isEmpty
                              ? Icon(Icons.image, color: Colors.grey[400])
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'x${item.quantity}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(item.price * item.quantity),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: Colors.grey[200]),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thanh toán',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: _buildInfoRow(
            Icons.payment,
            'Phương thức',
            order.paymentMethodName ?? 'Thanh toán khi nhận hàng',
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Tạm tính', order.subtotal),
          SizedBox(height: 8.h),
          _buildSummaryRow('Phí vận chuyển', order.shippingFee),
          if (order.discountAmount > 0) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              'Giảm giá',
              -order.discountAmount,
              isDiscount: true,
            ),
          ],
          Divider(height: 24.h, color: AppColors.primary.withOpacity(0.1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _formatCurrency(order.totalAmount),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Đóng',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20.sp, color: AppColors.textSecondary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return '—';
    final parts = [
      address['address'],
      address['ward'],
      address['district'],
      address['city'],
    ].where((part) => part != null && part.toString().isNotEmpty).join(', ');
    return parts.isEmpty ? '—' : parts;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.shipping:
        return Colors.cyan;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.returned:
        return 'Đã trả hàng';
    }
  }
}
