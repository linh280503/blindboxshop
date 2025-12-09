import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/cart_item_widget.dart';
import '../providers/cart_provider.dart';
import '../../../product/presentation/providers/product_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _selectAll = false;
  List<bool> _selectedItems = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cart = ref.watch(cartProvider);
    _selectedItems = List.generate(cart.items.length, (index) => false);
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      final cart = ref.read(cartProvider);
      _selectedItems = List.generate(cart.items.length, (index) => _selectAll);
    });
  }

  void _toggleSelectItem(int index) {
    setState(() {
      _selectedItems[index] = !_selectedItems[index];
      _selectAll = _selectedItems.every((selected) => selected);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    final cart = ref.read(cartProvider);
    if (index < cart.items.length) {
      final item = cart.items[index];
      ref
          .read(cartProvider.notifier)
          .updateItemQuantity(item.productId, newQuantity);
    }
  }

  void _removeItem(int index) {
    final cart = ref.read(cartProvider);
    if (index < cart.items.length) {
      final item = cart.items[index];
      ref.read(cartProvider.notifier).removeItem(item.productId);
      setState(() {
        _selectedItems.removeAt(index);
        if (_selectedItems.isEmpty) {
          _selectAll = false;
        }
      });
    }
  }

  void _clearAllItems() {
    ref.read(cartProvider.notifier).clearCart();
    setState(() {
      _selectedItems.clear();
      _selectAll = false;
    });
  }

  double get _totalPrice {
    final cart = ref.read(cartProvider);
    double total = 0;
    for (int i = 0; i < cart.items.length; i++) {
      if (i < _selectedItems.length && _selectedItems[i]) {
        final item = cart.items[i];
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  int get _selectedCount {
    return _selectedItems.where((selected) => selected).length;
  }

  Widget _buildCartItemWithProduct(dynamic item, int index) {
    return Consumer(
      builder: (context, ref, child) {
        final productAsync = ref.watch(productByIdProvider(item.productId));

        return productAsync.when(
          data: (product) {
            if (product == null) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Text('Sản phẩm không tồn tại'),
              );
            }

            return CartItemWidget(
              productId: item.productId,
              productName: item.productName,
              productImage: item.productImage,
              price: item.price,
              quantity: item.quantity,
              stock: product.stock,
              isSelected: index < _selectedItems.length
                  ? _selectedItems[index]
                  : false,
              onToggleSelect: (selected) => _toggleSelectItem(index),
              onQuantityChanged: (newQuantity) =>
                  _updateQuantity(index, newQuantity),
              onRemove: () => _removeItem(index),
              product: product,
            );
          },
          loading: () => Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.lightGrey.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12.w),
                Text('Đang tải thông tin sản phẩm...'),
              ],
            ),
          ),
          error: (error, stack) => Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Lỗi tải sản phẩm: ${item.productName}',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
                TextButton(
                  onPressed: () => _removeItem(index),
                  child: Text('Xóa', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _proceedToCheckout() {
    final cart = ref.read(cartProvider);
    final selectedItems = <String>[];

    for (int i = 0; i < cart.items.length; i++) {
      if (i < _selectedItems.length && _selectedItems[i]) {
        selectedItems.add(cart.items[i].productId);
      }
    }

    if (selectedItems.isNotEmpty) {
      context.go('/checkout', extra: selectedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Giỏ hàng',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Xóa tất cả',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Text(
                        'Bạn có chắc chắn muốn xóa tất cả sản phẩm khỏi giỏ hàng?',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Hủy',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _clearAllItems();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xóa tất cả sản phẩm'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          child: Text(
                            'Xóa',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                'Xóa tất cả',
                style: TextStyle(color: AppColors.error, fontSize: 14.sp),
              ),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItemWithProduct(item, index);
                    },
                  ),
                ),

                // Bottom Checkout Section - Shopee Style
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Select All Row
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _selectAll,
                              onChanged: cart.items.isNotEmpty
                                  ? (value) => _toggleSelectAll()
                                  : null,
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Chọn tất cả',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Tổng cộng:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${_totalPrice.toStringAsFixed(0)}₫',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Checkout Button
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                        child: ElevatedButton(
                          onPressed: _selectedCount > 0
                              ? () => _proceedToCheckout()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            _selectedCount > 0
                                ? 'Đặt hàng ($_selectedCount)'
                                : 'Chọn sản phẩm để đặt',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(60.r),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Mua sắm ngay',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
