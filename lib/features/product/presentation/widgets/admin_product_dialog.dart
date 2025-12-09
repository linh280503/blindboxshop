import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/product_model.dart';
import '../pages/admin_product_management_page.dart'; // Import for productCategoriesProvider

class AdminProductDialog extends ConsumerStatefulWidget {
  final ProductModel? product;

  const AdminProductDialog({super.key, this.product});

  @override
  ConsumerState<AdminProductDialog> createState() => _AdminProductDialogState();
}

class _AdminProductDialogState extends ConsumerState<AdminProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _categoryController;
  late TextEditingController _imageController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  bool _isActive = true;
  String _previewImage = '';

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _imageController = TextEditingController(
      text: p?.images.isNotEmpty == true ? p!.images.first : '',
    );
    _priceController = TextEditingController(
      text: p?.price.toStringAsFixed(0) ?? '',
    );
    _originalPriceController = TextEditingController(
      text: p?.originalPrice.toStringAsFixed(0) ?? '',
    );
    _stockController = TextEditingController(text: p?.stock.toString() ?? '0');
    _isActive = p?.isActive ?? true;
    _previewImage = _imageController.text;

    _imageController.addListener(() {
      setState(() {
        _previewImage = _imageController.text;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final categories = categoriesAsync.maybeWhen(
      data: (cats) => cats,
      orElse: () => <String>[],
    );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: Colors.white,
      child: Container(
        width: 600.w,
        constraints: BoxConstraints(maxWidth: 600.w, maxHeight: 0.9.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Preview & URL
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreview(),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _imageController,
                                  label: 'URL hình ảnh',
                                  icon: Icons.image_outlined,
                                  validator: (v) => v?.isEmpty == true
                                      ? 'Vui lòng nhập URL'
                                      : null,
                                ),
                                SizedBox(height: 12.h),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    'Kích hoạt sản phẩm',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  value: _isActive,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) =>
                                      setState(() => _isActive = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Basic Info
                      // Basic Info
                      _buildSectionTitle('Thông tin cơ bản'),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Tên sản phẩm',
                        icon: Icons.shopping_bag_outlined,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Vui lòng nhập tên' : null,
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _brandController,
                        label: 'Thương hiệu',
                        icon: Icons.branding_watermark_outlined,
                        validator: (v) => v?.isEmpty == true
                            ? 'Vui lòng nhập thương hiệu'
                            : null,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Danh mục',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: Colors.grey[500],
                            size: 20.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        value: categories.contains(_categoryController.text)
                            ? _categoryController.text
                            : null,
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _categoryController.text = val;
                            });
                          }
                        },
                        hint: Text('Chọn hoặc nhập bên dưới'),
                      ),
                      SizedBox(height: 8.h),
                      // Category manual input (if not in list or want to create new)
                      _buildTextField(
                        controller: _categoryController,
                        label: 'Nhập tên danh mục (nếu mới)',
                        icon: Icons.edit_outlined,
                        validator: (v) => v?.isEmpty == true
                            ? 'Vui lòng nhập danh mục'
                            : null,
                      ),

                      SizedBox(height: 24.h),

                      // Pricing & Stock
                      _buildSectionTitle('Giá & Tồn kho'),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'Giá bán',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Nhập giá bán' : null,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _originalPriceController,
                              label: 'Giá gốc',
                              icon: Icons.money_off_csred_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Nhập giá gốc' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _stockController,
                        label: 'Tồn kho',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Nhập tồn kho' : null,
                      ),
                    ],
                  ),
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
            widget.product == null ? 'Thêm sản phẩm' : 'Chỉnh sửa sản phẩm',
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
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: _previewImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                _previewImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image, color: Colors.grey[400]),
                ),
              ),
            )
          : Center(
              child: Icon(
                Icons.image_outlined,
                color: Colors.grey[400],
                size: 32.sp,
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20.sp),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
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
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.product == null ? 'Thêm' : 'Cập nhật',
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
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final brand = _brandController.text.trim();
      final category = _categoryController.text.trim();
      final image = _imageController.text.trim();
      final price = double.tryParse(_priceController.text.trim());
      final original = double.tryParse(_originalPriceController.text.trim());
      final stock = int.tryParse(_stockController.text.trim());

      if (price == null || original == null || stock == null) {
        NotificationService.showError('Giá/Tồn kho không hợp lệ');
        return;
      }

      try {
        if (widget.product == null) {
          // Add new
          await FirebaseFirestore.instance.collection('products').add({
            'name': name,
            'brand': brand,
            'category': category,
            'images': [image],
            'price': price,
            'originalPrice': original,
            'stock': stock,
            'isActive': _isActive,
            'createdAt': DateTime.now(),
            'updatedAt': DateTime.now(),
            'sold': 0,
            'rating': 0.0,
            'reviews': 0,
          });
        } else {
          // Update
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.product!.id)
              .update({
                'name': name,
                'brand': brand,
                'category': category,
                'images': image.isNotEmpty ? [image] : widget.product!.images,
                'price': price,
                'originalPrice': original,
                'stock': stock,
                'isActive': _isActive,
                'updatedAt': DateTime.now(),
              });
        }

        if (mounted) {
          Navigator.pop(context);
          NotificationService.showSuccess('Đã lưu sản phẩm');
        }
      } catch (e) {
        NotificationService.showError('Lỗi lưu sản phẩm: $e');
      }
    }
  }
}
