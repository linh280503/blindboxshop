// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/export_service.dart';
import '../widgets/admin_product_dialog.dart';

class AdminProductManagementPage extends ConsumerStatefulWidget {
  const AdminProductManagementPage({super.key});

  @override
  ConsumerState<AdminProductManagementPage> createState() =>
      _AdminProductManagementPageState();
}

// Admin products provider - stream from Firestore
final adminProductsProvider = StreamProvider.autoDispose<List<ProductModel>>((
  ref,
) {
  final query = FirebaseFirestore.instance
      .collection('products')
      .orderBy('createdAt', descending: true);
  return query.snapshots().map(
    (snap) => snap.docs.map((d) => ProductModel.fromFirestore(d)).toList(),
  );
});

final productCategoriesProvider = StreamProvider.autoDispose<List<String>>((
  ref,
) {
  return FirebaseFirestore.instance.collection('products').snapshots().map((
    snap,
  ) {
    final categories = <String>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final category = (data['category'] ?? '').toString();
      if (category.isNotEmpty) categories.add(category);
    }
    final list = categories.toList()..sort();
    return list;
  });
});

class _AdminProductManagementPageState
    extends ConsumerState<AdminProductManagementPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  String _sortBy = 'Mới nhất';

  final List<String> _categories = [
    'Tất cả',
    'Bb3',
    'Labubu',
    'Hirono',
    'Pop Mart',
    'Sonny Angel',
    'Molly',
  ];
  final List<String> _sortOptions = [
    'Mới nhất',
    'Tên A-Z',
    'Tên Z-A',
    'Giá thấp-cao',
    'Giá cao-thấp',
    'Bán chạy',
  ];

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final dynamicCategories = categoriesAsync.maybeWhen(
      data: (cats) => ['Tất cả', ...cats],
      orElse: () => _categories,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Quản lý sản phẩm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddProductDialog,
          ),
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () =>
                          _showFilterBottomSheet(dynamicCategories),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 12.h),
                // Filter chips
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Danh mục', _selectedCategory),
                            SizedBox(width: 8.w),
                            _buildFilterChip('Sắp xếp', _sortBy),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Removed stock/visibility tabs as requested
          // Products list (Firestore)
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final productsAsync = ref.watch(adminProductsProvider);
                return productsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Lỗi tải sản phẩm: $e')),
                  data: (products) {
                    final filtered = products.where((product) {
                      // Search filter
                      if (_searchQuery.isNotEmpty) {
                        final name = product.name.toLowerCase();
                        if (!name.contains(_searchQuery.toLowerCase())) {
                          return false;
                        }
                      }

                      // Category filter
                      if (_selectedCategory != 'Tất cả' &&
                          product.category != _selectedCategory)
                        return false;

                      return true;
                    }).toList();

                    // Apply sort option
                    switch (_sortBy) {
                      case 'Mới nhất':
                        filtered.sort(
                          (a, b) => b.createdAt.compareTo(a.createdAt),
                        );
                        break;
                      case 'Tên A-Z':
                        filtered.sort(
                          (a, b) => a.name.toLowerCase().compareTo(
                            b.name.toLowerCase(),
                          ),
                        );
                        break;
                      case 'Tên Z-A':
                        filtered.sort(
                          (a, b) => b.name.toLowerCase().compareTo(
                            a.name.toLowerCase(),
                          ),
                        );
                        break;
                      case 'Giá thấp-cao':
                        filtered.sort((a, b) => a.price.compareTo(b.price));
                        break;
                      case 'Giá cao-thấp':
                        filtered.sort((a, b) => b.price.compareTo(a.price));
                        break;
                      case 'Bán chạy':
                        filtered.sort((a, b) => b.sold.compareTo(a.sold));
                        break;
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 60.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Không có sản phẩm',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return _buildProductItem(product);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return GestureDetector(
      onTap: () {
        final categories = ref
            .read(productCategoriesProvider)
            .maybeWhen(
              data: (cats) => ['Tất cả', ...cats],
              orElse: () => _categories,
            );
        _showFilterBottomSheet(categories);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    final stock = product.stock;
    final isOutOfStock = stock <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: SizedBox(
          width: 60.w,
          height: 60.w,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  product.images.isNotEmpty
                      ? product.images.first
                      : 'https://via.placeholder.com/100x100',
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
              if (product.createdAt.isAfter(
                DateTime.now().subtract(const Duration(days: 7)),
              ))
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'MỚI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              '${product.brand} • ${product.category}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    '${product.originalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.star, size: 16.sp, color: Colors.amber),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    '${product.rating} (${product.sold} đã bán)',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isOutOfStock ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    isOutOfStock ? 'Hết hàng' : 'Còn ${product.stock}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          onSelected: (value) => _handleProductAction(value, product),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20.sp, color: Colors.grey[700]),
                  SizedBox(width: 12.w),
                  Text(
                    'Chỉnh sửa',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: product.isActive ? 'hide' : 'show',
              child: Row(
                children: [
                  Icon(
                    product.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 20.sp,
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    product.isActive ? 'Ẩn sản phẩm' : 'Hiện sản phẩm',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20.sp, color: Colors.red),
                  SizedBox(width: 12.w),
                  Text(
                    'Xóa',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const AdminProductDialog(),
    );
  }

  void _showFilterBottomSheet(List<String> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bộ lọc',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedCategory = 'Tất cả';
                          _sortBy = 'Mới nhất';
                        });
                      },
                      child: Text(
                        'Đặt lại',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection(
                        'Danh mục',
                        categories,
                        _selectedCategory,
                        (value) {
                          setModalState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      _buildFilterSection('Sắp xếp', _sortOptions, _sortBy, (
                        value,
                      ) {
                        setModalState(() {
                          _sortBy = value;
                        });
                      }),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Rebuild with selected filters
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'Áp dụng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleProductAction(String action, ProductModel product) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(product);
        break;
      case 'hide':
      case 'show':
        _toggleProductVisibility(product);
        break;
      case 'delete':
        _showDeleteDialog(product);
        break;
    }
  }

  void _showEditProductDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AdminProductDialog(product: product),
    );
  }

  void _toggleProductVisibility(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'isActive': !product.isActive});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.isActive ? 'Đã ẩn sản phẩm' : 'Đã hiện sản phẩm',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _showDeleteDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever,
                  size: 32.sp,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Xóa sản phẩm',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Text(
                'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?\nHành động này không thể hoàn tác.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await FirebaseFirestore.instance
                              .collection('products')
                              .doc(product.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa sản phẩm'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportToExcel() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang xuất dữ liệu sản phẩm...'),
          backgroundColor: AppColors.primary,
        ),
      );

      await ExportService.exportProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xuất dữ liệu thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xuất dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Removed _showComingSoon; edit dialog placeholder is used instead
}
