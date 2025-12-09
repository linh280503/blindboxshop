import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../domain/entities/product_type.dart';

class AdminAddProductPage extends ConsumerStatefulWidget {
  const AdminAddProductPage({super.key});

  @override
  ConsumerState<AdminAddProductPage> createState() =>
      _AdminAddProductPageState();
}

class _AdminAddProductPageState extends ConsumerState<AdminAddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specificationsController = TextEditingController();
  final _tagsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedProductType = 'single';
  String? _selectedCategory;
  String? _selectedBrand;
  bool _isActive = true;
  bool _isFeatured = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _specificationsController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final originalPrice =
          double.tryParse(_originalPriceController.text) ?? 0.0;
      final price = double.parse(_priceController.text);
      final discount = originalPrice > price
          ? ((originalPrice - price) / originalPrice * 100)
          : 0.0;

      final searchKeywords = <String>{};
      searchKeywords.addAll(
        _nameController.text.trim().toLowerCase().split(' '),
      );
      searchKeywords.addAll(_selectedBrand!.toLowerCase().split(' '));
      searchKeywords.addAll(_selectedCategory!.toLowerCase().split(' '));
      if (_tagsController.text.trim().isNotEmpty) {
        searchKeywords.addAll(
          _tagsController.text.split(',').map((e) => e.trim().toLowerCase()),
        );
      }
      searchKeywords.removeWhere((keyword) => keyword.isEmpty);

      final product = ProductModel(
        id: '',
        name: _nameController.text.trim(),
        brand: _selectedBrand!,
        category: _selectedCategory!,
        price: price,
        originalPrice: originalPrice,
        discount: discount,
        stock: int.parse(_stockController.text),
        sold: 0,
        rating: 0.0,
        reviewCount: 0,
        description: _descriptionController.text.trim(),
        specifications: _specificationsController.text.trim().isNotEmpty
            ? {'description': _specificationsController.text.trim()}
            : null,
        tags: _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        images: _imageUrlController.text.trim().isNotEmpty
            ? [_imageUrlController.text.trim()]
            : [],
        searchKeywords: searchKeywords.toList(),
        productType: ProductType.values.firstWhere(
          (e) => e.name == _selectedProductType,
          orElse: () => ProductType.single,
        ),
        boxSize: _selectedProductType == 'box' ? 1 : null,
        setSize: _selectedProductType == 'set' ? 1 : null,
        isActive: _isActive,
        isFeatured: _isFeatured,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(productsProvider.notifier).addProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm sản phẩm thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/admin/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm sản phẩm: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thêm sản phẩm mới'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/products'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionTitle('Thông tin cơ bản'),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _nameController,
                label: 'Tên sản phẩm *',
                hint: 'Nhập tên sản phẩm',
                validator: (value) => value?.isEmpty == true
                    ? 'Vui lòng nhập tên sản phẩm'
                    : null,
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(child: _buildBrandDropdown()),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildCategoryDropdown()),
                ],
              ),

              SizedBox(height: 16.h),

              // Product Type
              _buildSectionTitle('Loại sản phẩm'),
              SizedBox(height: 8.h),

              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildProductTypeOption(
                            'single',
                            'Đơn lẻ',
                            Icons.shopping_bag_outlined,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildProductTypeOption(
                            'box',
                            'Hộp',
                            Icons.inventory_2_outlined,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildProductTypeOption(
                            'set',
                            'Set',
                            Icons.shopping_cart_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Price Information
              _buildSectionTitle('Thông tin giá'),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Giá bán *',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Vui lòng nhập giá bán';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Giá không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _originalPriceController,
                      label: 'Giá gốc',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isNotEmpty == true &&
                            double.tryParse(value!) == null) {
                          return 'Giá không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _stockController,
                label: 'Số lượng tồn kho *',
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Vui lòng nhập số lượng';
                  if (int.tryParse(value!) == null) {
                    return 'Số lượng không hợp lệ';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Images
              _buildSectionTitle('Hình ảnh sản phẩm'),
              SizedBox(height: 8.h),

              _buildTextField(
                controller: _imageUrlController,
                label: 'URL ảnh sản phẩm',
                hint: 'https://example.com/image.jpg',
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || (!uri.scheme.startsWith('http'))) {
                      return 'URL không hợp lệ';
                    }
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Description
              _buildSectionTitle('Mô tả sản phẩm'),
              SizedBox(height: 8.h),

              _buildTextField(
                controller: _descriptionController,
                label: 'Mô tả',
                hint: 'Nhập mô tả sản phẩm',
                maxLines: 3,
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _specificationsController,
                label: 'Thông số kỹ thuật',
                hint: 'Nhập thông số kỹ thuật',
                maxLines: 3,
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _tagsController,
                label: 'Tags (cách nhau bởi dấu phẩy)',
                hint: 'tag1, tag2, tag3',
              ),

              SizedBox(height: 16.h),

              // Status
              _buildSectionTitle('Trạng thái'),
              SizedBox(height: 8.h),

              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Sản phẩm hoạt động'),
                      value: _isActive,
                      onChanged: (value) =>
                          setState(() => _isActive = value ?? false),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Sản phẩm nổi bật'),
                      value: _isFeatured,
                      onChanged: (value) =>
                          setState(() => _isFeatured = value ?? false),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Thêm sản phẩm',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildProductTypeOption(String value, String title, IconData icon) {
    final isSelected = _selectedProductType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedProductType = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        return DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Danh mục *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.name,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn danh mục';
            }
            return null;
          },
        );
      },
      loading: () => Container(
        height: 56.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (error, stack) => Container(
        height: 56.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            'Lỗi tải danh mục',
            style: TextStyle(color: Colors.red, fontSize: 12.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandDropdown() {
    final brandsAsync = ref.watch(brandsProvider);

    return brandsAsync.when(
      data: (brands) {
        return DropdownButtonFormField<String>(
          value: _selectedBrand,
          decoration: InputDecoration(
            labelText: 'Thương hiệu *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          items: brands.map((brand) {
            return DropdownMenuItem(value: brand, child: Text(brand));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBrand = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn thương hiệu';
            }
            return null;
          },
        );
      },
      loading: () => Container(
        height: 56.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (error, stack) => Container(
        height: 56.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            'Lỗi tải thương hiệu',
            style: TextStyle(color: Colors.red, fontSize: 12.sp),
          ),
        ),
      ),
    );
  }
}
