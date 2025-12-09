// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../product/data/models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/services/notification_service.dart';
import '../widgets/admin_inventory_adjustment_dialog.dart';

final adminProductsProvider = StreamProvider.autoDispose<List<ProductModel>>((
  ref,
) {
  final query = FirebaseFirestore.instance
      .collection('products')
      .orderBy('createdAt', descending: true);
  return query.snapshots().map(
    (snap) => snap.docs.map((doc) => ProductModel.fromFirestore(doc)).toList(),
  );
});

class AdminInventoryManagementPage extends ConsumerStatefulWidget {
  const AdminInventoryManagementPage({super.key});

  @override
  ConsumerState<AdminInventoryManagementPage> createState() =>
      _AdminInventoryManagementPageState();
}

class _AdminInventoryManagementPageState
    extends ConsumerState<AdminInventoryManagementPage> {
  String _selectedTab = 'Tất cả';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = ['Tất cả', 'Còn hàng', 'Sắp hết', 'Hết hàng'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Quản lý tồn kho',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: _exportInventory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Tab selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = tab == _selectedTab;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = tab;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
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
                      // Tab filter (single source of truth)
                      if (_selectedTab == 'Còn hàng' && product.stock <= 0) {
                        return false;
                      }
                      if (_selectedTab == 'Sắp hết' && product.stock > 10) {
                        return false;
                      }
                      if (_selectedTab == 'Hết hàng' && product.stock > 0) {
                        return false;
                      }

                      // Search filter
                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery.toLowerCase();
                        if (!product.name.toLowerCase().contains(query) &&
                            !product.brand.toLowerCase().contains(query) &&
                            !product.category.toLowerCase().contains(query)) {
                          return false;
                        }
                      }

                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return _buildInventoryItem(product);
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

  Widget _buildInventoryItem(ProductModel product) {
    final stock = product.stock;
    final isLowStock = stock <= 10 && stock > 0;
    final isOutOfStock = stock <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
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
      constraints: BoxConstraints(minHeight: 100.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: product.images.isNotEmpty
                ? Image.network(
                    product.images.first,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
          SizedBox(width: 6.w),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${product.brand} • ${product.category}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? Colors.red
                              : isLowStock
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          isOutOfStock
                              ? 'Hết hàng'
                              : isLowStock
                              ? 'Sắp hết'
                              : 'Còn hàng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        'Tồn: ${product.stock}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isOutOfStock
                              ? Colors.red
                              : isLowStock
                              ? Colors.orange
                              : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          // Action buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showAdjustStockDialog(product),
                icon: Icon(Icons.edit, color: AppColors.primary, size: 14.sp),
                tooltip: 'Điều chỉnh tồn kho',
                constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.w),
                padding: EdgeInsets.all(1.w),
              ),
              // Removed stock history button as requested
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: 20.sp,
        color: AppColors.primary.withOpacity(0.6),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Không có sản phẩm nào',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Thử thay đổi bộ lọc hoặc tìm kiếm',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAdjustStockDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AdminInventoryAdjustmentDialog(product: product),
    );
  }

  // Removed stock history feature as requested

  void _exportInventory() async {
    try {
      NotificationService.showInfo('Đang xuất báo cáo tồn kho...');

      await ExportService.exportProducts();

      NotificationService.showSuccess('Xuất báo cáo thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi xuất báo cáo: $e');
    }
  }
}
