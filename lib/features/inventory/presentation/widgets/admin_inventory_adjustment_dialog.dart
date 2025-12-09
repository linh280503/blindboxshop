import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../product/data/models/product_model.dart';

class AdminInventoryAdjustmentDialog extends StatefulWidget {
  final ProductModel product;

  const AdminInventoryAdjustmentDialog({super.key, required this.product});

  @override
  State<AdminInventoryAdjustmentDialog> createState() =>
      _AdminInventoryAdjustmentDialogState();
}

class _AdminInventoryAdjustmentDialogState
    extends State<AdminInventoryAdjustmentDialog> {
  late TextEditingController _stockController;
  String _adjustmentType = 'set'; // set, add, subtract
  int _previewStock = 0;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _previewStock = widget.product.stock;
    _stockController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _stockController.removeListener(_updatePreview);
    _stockController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final input = int.tryParse(_stockController.text) ?? 0;
    int newStock = widget.product.stock;

    switch (_adjustmentType) {
      case 'set':
        newStock = input;
        break;
      case 'add':
        newStock = widget.product.stock + input;
        break;
      case 'subtract':
        newStock = widget.product.stock - input;
        break;
    }

    setState(() {
      _previewStock = newStock;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(24.w),
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Điều chỉnh tồn kho',
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
                  color: Colors.grey[400],
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Product Info
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[200]!),
                      image: widget.product.images.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.product.images.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.product.images.isEmpty
                        ? Icon(Icons.inventory_2, color: Colors.grey[400])
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Hiện tại: ${widget.product.stock}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Adjustment Type
            Text(
              'Loại điều chỉnh',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    'set',
                    'Đặt lại',
                    Icons.edit_outlined,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildTypeOption(
                    'add',
                    'Thêm',
                    Icons.add_circle_outline,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildTypeOption(
                    'subtract',
                    'Trừ',
                    Icons.remove_circle_outline,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Input
            Text(
              'Số lượng',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Nhập số lượng',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            SizedBox(height: 24.h),

            // Preview
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _previewStock < 0
                    ? Colors.red[50]
                    : AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _previewStock < 0
                      ? Colors.red.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tồn kho sau khi sửa:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _previewStock < 0
                          ? Colors.red
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _previewStock.toString(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: _previewStock < 0 ? Colors.red : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _previewStock < 0 ? null : _saveStock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cập nhật',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _adjustmentType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _adjustmentType = value;
          if (value == 'set') {
            _stockController.text = widget.product.stock.toString();
          } else {
            _stockController.text = '0';
          }
          _updatePreview();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[400],
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveStock() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update({'stock': _previewStock});

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close dialog
        NotificationService.showSuccess('Đã cập nhật tồn kho: $_previewStock');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        NotificationService.showError('Lỗi cập nhật: $e');
      }
    }
  }
}
