import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class ProductInfoSection extends StatelessWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final Function(int) onQuantityChanged;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product['originalPrice'] != null &&
        product['originalPrice'] > product['price'];
    final discountPercentage = hasDiscount
        ? ((product['originalPrice'] - product['price']) /
                  product['originalPrice'] *
                  100)
              .round()
        : 0;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          // Brand and Category
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  product['brand'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  product['category'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Product Name
          Text(
            product['name'],
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 16.h),

          // Rating and Sold
          Row(
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.warning, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    product['rating'].toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${product['reviewCount']} đánh giá',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Đã bán ${(product['sold'] ?? 0).toString()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Price Section
          Row(
            children: [
              Expanded(
                child: Text(
                  '${product['price'].toStringAsFixed(0)} VNĐ',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasDiscount) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${product['originalPrice'].toStringAsFixed(0)} VNĐ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '-$discountPercentage%',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 20.h),

          // Quantity Selector
          Row(
            children: [
              Text(
                'Số lượng:',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 16.w),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1
                          ? () => onQuantityChanged(quantity - 1)
                          : null,
                      icon: Icon(
                        Icons.remove,
                        size: 18.sp,
                        color: quantity > 1
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      width: 50.w,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        quantity.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: quantity < product['stock']
                          ? () => onQuantityChanged(quantity + 1)
                          : null,
                      icon: Icon(
                        Icons.add,
                        size: 18.sp,
                        color: quantity < product['stock']
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),
          Text(
            'Còn ${product['stock']} sản phẩm',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),

          SizedBox(height: 20.h),

          // Description
          Text(
            'Mô tả sản phẩm',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          if ((product['description'] ?? '').toString().trim().isNotEmpty)
            Text(
              product['description'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          if ((product['description'] ?? '').toString().trim().isEmpty)
            Text(
              'Chưa có mô tả cho sản phẩm này',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),

          SizedBox(height: 20.h),
          ...(() {
            final rawSpecs = product['specifications'];
            final Map<String, dynamic> specs = rawSpecs is Map
                ? rawSpecs.cast<String, dynamic>()
                : {};
            if (specs.isEmpty) return <Widget>[];
            return <Widget>[
              Text(
                'Thông số kỹ thuật',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              ...specs.entries
                  .map<Widget>((entry) {
                    final String key = entry.key.toString();
                    final String value = entry.value?.toString() ?? '';
                    if (value.trim().isEmpty) return const SizedBox.shrink();
                    final String keyVi = _translateSpecKey(key);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100.w,
                            child: Text(
                              keyVi,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              ': $value',
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .whereType<Widget>()
                  ,
            ];
          })(),

          SizedBox(height: 20.h),

          ...(() {
            final rawTags = product['tags'];
            final List<String> tags = rawTags is List
                ? rawTags
                      .map((e) => e.toString())
                      .where((e) => e.trim().isNotEmpty)
                      .toList()
                : <String>[];
            if (tags.isEmpty) return <Widget>[];
            return <Widget>[
              Text(
                'Nhãn',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: tags.map<Widget>((tagStr) {
                  final String tagVi = _translateTag(tagStr);
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      tagVi,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ];
          })(),
        ],
      ),
    );
  }

  String _translateSpecKey(String key) {
    final lower = key.trim().toLowerCase();
    switch (lower) {
      case 'material':
        return 'Chất liệu';
      case 'weight':
        return 'Khối lượng';
      case 'age':
        return 'Độ tuổi';
      case 'height':
        return 'Chiều cao';
      case 'width':
        return 'Chiều rộng';
      case 'length':
        return 'Chiều dài';
      case 'size':
        return 'Kích thước';
      case 'color':
        return 'Màu sắc';
      case 'brand':
        return 'Thương hiệu';
      case 'model':
        return 'Mẫu';
      default:
        return key;
    }
  }

  String _translateTag(String tag) {
    final lower = tag.trim().toLowerCase();
    switch (lower) {
      case 'new':
      case 'new arrival':
        return 'mới';
      case 'popular':
      case 'trending':
        return 'phổ biến';
      case 'limited':
      case 'limited edition':
        return 'giới hạn';
      case 'sale':
      case 'discount':
        return 'khuyến mãi';
      case 'preorder':
      case 'pre-order':
        return 'đặt trước';
      default:
        return tag;
    }
  }
}
