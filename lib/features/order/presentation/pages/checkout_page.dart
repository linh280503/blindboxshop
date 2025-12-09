// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/checkout_address_section.dart';
import '../widgets/checkout_payment_section.dart';
import '../widgets/checkout_order_summary.dart';
import '../widgets/checkout_coupon_section.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../address/presentation/providers/address_provider.dart';
import '../../../address/data/di/address_providers.dart';
import '../../../address/data/mappers/address_mapper.dart';
import '../../../discount/presentation/providers/discount_provider.dart';
import '../../../discount/data/di/discount_providers.dart';
import '../../../discount/domain/usecases/validate_discount_code.dart';
import '../../data/di/order_providers.dart';
import '../../domain/usecases/update_order_status.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../../data/mappers/order_mapper.dart';
import '../../../../core/services/email_service.dart';
import '../../../../core/services/stripe_service.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/models/order_model.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _noteController = TextEditingController();

  // Selected options
  String _selectedAddressId = '';
  String _selectedPaymentMethod = AppConstants.paymentCod;
  String? _selectedCouponCode;

  // Selected items for checkout
  List<String> _selectedItemIds = [];

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': AppConstants.paymentCod,
      'name': 'Thanh toán khi nhận hàng',
      'description': 'Thanh toán bằng tiền mặt khi nhận hàng',
      'icon': Icons.money,
    },
    {
      'id': 'stripe',
      'name': 'Stripe',
      'description': 'Thanh toán bằng thẻ (Stripe PaymentSheet)',
      'icon': Icons.credit_card,
    },
  ];

  List<Map<String, dynamic>> availableCoupons = [];

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nhận danh sách sản phẩm đã chọn
    final extra = GoRouterState.of(context).extra;
    if (extra is List<String>) {
      _selectedItemIds = extra;
    }
  }

  Future<void> _loadCoupons() async {
    try {
      final discounts = await ref.read(activeDiscountsProvider.future);
      if (mounted) {
        setState(() {
          availableCoupons = discounts
              .map(
                (d) => {
                  'code': d.code,
                  'name': d.name,
                  'description': d.description,
                  'type': d.type.name,
                  'value': d.value,
                  'minOrderAmount': d.minOrderAmount,
                  'maxDiscountAmount': d.maxDiscountAmount,
                  'formattedValue': d.formattedValue,
                  'formattedMinOrderAmount': d.formattedMinOrderAmount,
                  'isFirstOrderOnly': d.isFirstOrderOnly,
                  'applicableProducts': d.applicableProducts,
                  'applicableCategories': d.applicableCategories,
                },
              )
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          availableCoupons = [];
        });
      }
    }
  }

  Future<bool> _validateCouponCode(String code) async {
    try {
      final cart = ref.read(cartProvider);
      if (cart.items.isEmpty) return false;

      // Lọc chỉ sản phẩm đã chọn
      final selectedItems = cart.items.where(
        (item) => _selectedItemIds.contains(item.productId),
      );
      if (selectedItems.isEmpty) return false;

      // Tạo order items để validate
      final orderItems = selectedItems
          .map((item) => {'productId': item.productId, 'category': 'blind_box'})
          .toList();

      final orderAmount = selectedItems.fold(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      // Kiểm tra xem có phải đơn hàng đầu tiên không
      final auth = ref.read(authProvider);
      final uid = auth.user?.uid;
      bool isFirstOrder = false;
      if (uid != null) {
        final orderRepo = ref.read(orderRepositoryProvider);
        final stats = await orderRepo.getUserOrderStats(uid);
        isFirstOrder = stats['isFirstOrder'] as bool? ?? true;
      }

      final validateDiscountCode = ref.read(validateDiscountCodeProvider);
      final validation = await validateDiscountCode(
        ValidateDiscountCodeParams(
          code: code,
          orderAmount: orderAmount,
          orderItems: orderItems,
          isFirstOrder: isFirstOrder,
        ),
      );

      return validation['isValid'] as bool;
    } catch (e) {
      return false;
    }
  }

  Future<void> _applyCouponCode(String code) async {
    try {
      final isValid = await _validateCouponCode(code);
      if (isValid) {
        setState(() {
          _selectedCouponCode = code;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Áp dụng mã giảm giá $code thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Mã giảm giá $code không hợp lệ hoặc không áp dụng được',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi áp dụng mã giảm giá: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeCouponCode() {
    setState(() {
      _selectedCouponCode = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa mã giảm giá'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildAddressSection() {
    final auth = ref.watch(authProvider);
    final uid = auth.user?.uid;
    if (uid == null) {
      return Container();
    }
    final addressesAsync = ref.watch(userAddressesProvider(uid));

    return addressesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Lỗi tải địa chỉ: $e'),
      data: (addresses) {
        if (addresses.isEmpty) {
          return CheckoutAddressSection(
            addresses: const [],
            selectedAddressId: _selectedAddressId,
            onAddressSelected: (id) {
              setState(() {
                _selectedAddressId = id;
              });
            },
            onAddNewAddress: () async {
              await context.push('/add-address');
              // Invalidate provider để reload danh sách địa chỉ
              if (mounted) {
                ref.invalidate(userAddressesProvider(uid));
              }
            },
          );
        }

        // ensure selected default
        if (_selectedAddressId.isEmpty) {
          final def = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
          _selectedAddressId = def.id;
        }

        return CheckoutAddressSection(
          addresses: addresses,
          selectedAddressId: _selectedAddressId,
          onAddressSelected: (id) {
            setState(() {
              _selectedAddressId = id;
            });
          },
          onAddNewAddress: () async {
            await context.push('/add-address');
            // Invalidate provider để reload danh sách địa chỉ
            if (mounted) {
              ref.invalidate(userAddressesProvider(uid));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Thanh toán',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/cart');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              context.go('/cart');
            },
            tooltip: 'Giỏ hàng',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // Delivery Address
                    _buildAddressSection(),

                    SizedBox(height: 16.h),

                    // Payment Method
                    CheckoutPaymentSection(
                      paymentMethods: paymentMethods,
                      selectedPaymentMethod: _selectedPaymentMethod,
                      onPaymentMethodSelected: (methodId) {
                        setState(() {
                          _selectedPaymentMethod = methodId;
                        });
                      },
                    ),

                    SizedBox(height: 16.h),

                    // Coupon Section
                    Builder(
                      builder: (context) {
                        final cart = ref.watch(cartProvider);
                        final selectedItems = cart.items.where(
                          (item) => _selectedItemIds.contains(item.productId),
                        );
                        final subtotal = selectedItems.fold(0.0, (sum, item) {
                          return sum + (item.price * item.quantity);
                        });

                        return CheckoutCouponSection(
                          availableCoupons: availableCoupons,
                          selectedCouponCode: _selectedCouponCode,
                          currentSubtotal: subtotal,
                          onCouponSelected: (couponCode) {
                            setState(() {
                              _selectedCouponCode = couponCode;
                            });
                          },
                          onApplyCouponCode: _applyCouponCode,
                          onRemoveCouponCode: _removeCouponCode,
                        );
                      },
                    ),

                    SizedBox(height: 16.h),

                    // Order Note
                    Container(
                      padding: EdgeInsets.all(20.w),
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
                          Text(
                            'Ghi chú đơn hàng',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Nhập ghi chú cho đơn hàng (tùy chọn)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Order Summary
                    Builder(
                      builder: (context) {
                        final cart = ref.watch(cartProvider);

                        // Lọc chỉ sản phẩm đã chọn
                        final selectedCartItems = cart.items
                            .where(
                              (item) =>
                                  _selectedItemIds.contains(item.productId),
                            )
                            .map(
                              (item) => {
                                'id': item.productId,
                                'productName': item.productName,
                                'productImage': item.productImage,
                                'price': item.price,
                                'quantity': item.quantity,
                              },
                            )
                            .toList();

                        // Calculate price breakdown using current state
                        final priceBreakdown = _calculatePriceBreakdown();

                        return CheckoutOrderSummary(
                          items: selectedCartItems,
                          shippingFee: priceBreakdown['shipping']!,
                          discountAmount: priceBreakdown['discount']!,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Order Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng:',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_calculateTotal().toStringAsFixed(0)} VNĐ',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Đặt hàng',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculatePriceBreakdown() {
    // Lấy giỏ hàng hiện tại để tính toán
    final cart = ref.read(cartProvider);

    // Chỉ tính toán sản phẩm đã chọn
    final selectedItems = cart.items.where(
      (item) => _selectedItemIds.contains(item.productId),
    );
    double subtotal = selectedItems.fold(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    double discount = 0;
    if (_selectedCouponCode != null) {
      final coupon = availableCoupons.firstWhere(
        (c) => c['code'] == _selectedCouponCode,
        orElse: () => {},
      );
      if (coupon.isNotEmpty) {
        // Sử dụng logic tính toán từ DiscountModel
        if (coupon['type'] == 'percentage') {
          discount = subtotal * ((coupon['value'] ?? 0) / 100.0);
        } else {
          discount = (coupon['value'] ?? 0).toDouble();
        }

        // Áp dụng giới hạn giảm giá tối đa
        final maxDiscount = coupon['maxDiscountAmount'] as double?;
        if (maxDiscount != null && discount > maxDiscount) {
          discount = maxDiscount;
        }

        // Kiểm tra đơn hàng tối thiểu
        final minOrder = coupon['minOrderAmount'] as double?;
        if (minOrder != null && subtotal < minOrder) {
          discount = 0;
        }

        // Không được giảm nhiều hơn giá trị đơn hàng
        if (discount > subtotal) discount = subtotal;
      }
    }

    double shippingFee = subtotal >= 500000 ? 0 : 30000;
    double total = subtotal + shippingFee - discount;

    return {
      'subtotal': subtotal,
      'shipping': shippingFee,
      'discount': discount,
      'total': total,
    };
  }

  double _calculateTotal() {
    return _calculatePriceBreakdown()['total']!;
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = ref.read(authProvider);
      final uid = auth.user?.uid;
      if (uid == null) {
        throw Exception('Bạn cần đăng nhập để đặt hàng');
      }

      if (_selectedAddressId.isEmpty) {
        throw Exception('Vui lòng chọn địa chỉ giao hàng');
      }

      final addressRepo = ref.read(addressRepositoryProvider);
      final addressEntity = await addressRepo.getAddressById(
        _selectedAddressId,
      );
      if (addressEntity == null) {
        throw Exception('Không tìm thấy địa chỉ đã chọn');
      }
      // Convert entity to model for compatibility
      final address = AddressMapper.toModel(addressEntity);

      // Lấy giỏ hàng hiện tại
      final cart = ref.read(cartProvider);
      if (cart.items.isEmpty) {
        throw Exception('Giỏ hàng trống');
      }

      // Lọc chỉ sản phẩm đã chọn
      final selectedCartItems = cart.items
          .where((item) => _selectedItemIds.contains(item.productId))
          .toList();
      if (selectedCartItems.isEmpty) {
        throw Exception('Không có sản phẩm nào được chọn');
      }

      // Tạo OrderItems từ cart items đã chọn
      final orderItems = selectedCartItems
          .map(
            (cartItem) => OrderItem(
              productId: cartItem.productId,
              productName: cartItem.productName,
              productImage: cartItem.productImage,
              price: cartItem.price,
              quantity: cartItem.quantity,
              orderType: OrderType.single, // Default to single
              totalPrice: cartItem.price * cartItem.quantity,
            ),
          )
          .toList();

      // Tính toán giá trị đơn hàng
      final priceBreakdown = _calculatePriceBreakdown();
      final subtotal = priceBreakdown['subtotal']!;
      final shipping = priceBreakdown['shipping']!;
      final discountAmount = priceBreakdown['discount']!;
      final orderTotal = priceBreakdown['total']!;

      // Tạo OrderModel
      final order = OrderModel(
        id: '', // Sẽ được tạo bởi OrderService
        userId: uid,
        orderNumber: '', // Sẽ được tạo bởi OrderService
        items: orderItems,
        subtotal: subtotal,
        discountAmount: discountAmount,
        shippingFee: shipping,
        totalAmount: orderTotal,
        status: OrderStatus.pending,
        deliveryAddressId: address.id,
        deliveryAddress: {
          'id': address.id,
          'name': address.name,
          'phone': address.phone,
          'address': address.address,
          'ward': address.ward,
          'district': address.district,
          'city': address.city,
          'note': address.note,
        },
        paymentMethodId: _selectedPaymentMethod,
        paymentMethodName: paymentMethods.firstWhere(
          (p) => p['id'] == _selectedPaymentMethod,
          orElse: () => {'name': 'Thanh toán khi nhận hàng'},
        )['name'],
        discountCode: _selectedCouponCode,
        note: _noteController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Xử lý thanh toán
      if (_selectedPaymentMethod == 'stripe') {
        // Stripe: trình bày PaymentSheet trước khi tạo đơn hàng
        try {
          // Tính amount theo minor units (cents)
          final amountMinor = (orderTotal * 100).round();
          await StripeService.presentPaymentSheet(
            amountInMinorUnit: amountMinor,
            currency: 'usd',
            metadata: {'userId': uid},
            merchantDisplayName: 'Blind Box Shop',
          );

          // Nếu thành công: tạo đơn hàng confirmed
          final orderEntity = OrderMapper.toEntity(order);
          final createOrder = ref.read(createOrderProvider);
          final createdOrderEntity = await createOrder(orderEntity);
          final createdOrder = OrderMapper.toModel(createdOrderEntity);

          final updateOrderStatus = ref.read(updateOrderStatusProvider);
          await updateOrderStatus(
            UpdateOrderStatusParams(
              orderId: createdOrder.id,
              status: OrderStatus.confirmed,
            ),
          );

          await ref
              .read(cartProvider.notifier)
              .removeMultipleItems(_selectedItemIds.toList());

          // Gửi email thông báo đơn hàng
          try {
            final email = auth.user?.email ?? '';
            final userName = auth.user?.name ?? 'Khách hàng';
            if (email.isNotEmpty) {
              await EmailService.sendOrderNotificationEmail(
                userEmail: email,
                order: createdOrder,
                userName: userName,
              );
            }
          } catch (_) {}

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thanh toán Stripe thành công!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/orders');
          }
          return;
        } catch (e) {
          print('Stripe payment error: $e');
          if (mounted) {
            if (e is PaymentCanceledException) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thanh toán Stripe thất bại: ${e.toString()}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      }

      // Thanh toán COD - tạo đơn hàng trực tiếp
      final orderEntity = OrderMapper.toEntity(order);
      final createOrder = ref.read(createOrderProvider);
      final createdOrderEntity = await createOrder(orderEntity);
      final createdOrder = OrderMapper.toModel(createdOrderEntity);

      // Xóa chỉ sản phẩm đã chọn khỏi giỏ hàng
      for (final itemId in _selectedItemIds) {
        await ref.read(cartProvider.notifier).removeItem(itemId);
      }

      // Gửi email thông báo đơn hàng
      try {
        final email = auth.user?.email ?? '';
        final userName = auth.user?.name ?? 'Khách hàng';
        if (email.isNotEmpty) {
          await EmailService.sendOrderNotificationEmail(
            userEmail: email,
            order: createdOrder,
            userName: userName,
          );
        }
      } catch (e) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công! Đơn hàng đang được xử lý.'),
            backgroundColor: AppColors.success,
          ),
        );

        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt hàng thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
