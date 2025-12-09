// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/cart_model.dart';
import '../../data/mappers/cart_mapper.dart';
import '../../data/di/cart_providers.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/get_user_cart.dart';
import '../../domain/usecases/add_item_to_cart.dart';
import '../../domain/usecases/update_item_quantity.dart';
import '../../domain/usecases/remove_item_from_cart.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/usecases/watch_user_cart.dart';
import '../../../inventory/data/di/inventory_providers.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../inventory/domain/usecases/check_stock.dart';
import '../../../inventory/domain/usecases/get_stock_info.dart';
import '../../../auth/data/di/auth_providers.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

// Cart state provider
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  final cartRepo = ref.watch(cartRepositoryProvider);
  final getUserCart = ref.watch(getUserCartProvider);
  final addItemToCart = ref.watch(addItemToCartProvider);
  final updateItemQuantity = ref.watch(updateItemQuantityProvider);
  final removeItemFromCart = ref.watch(removeItemFromCartProvider);
  final clearCart = ref.watch(clearCartProvider);
  final watchUserCart = ref.watch(watchUserCartProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  final checkStock = ref.watch(checkStockProvider);
  final getStockInfo = ref.watch(getStockInfoProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return CartNotifier(
    cartRepository: cartRepo,
    getUserCartUC: getUserCart,
    addItemToCartUC: addItemToCart,
    updateItemQuantityUC: updateItemQuantity,
    removeItemFromCartUC: removeItemFromCart,
    clearCartUC: clearCart,
    watchUserCartUC: watchUserCart,
    inventoryRepository: inventoryRepo,
    checkStockUC: checkStock,
    getStockInfoUC: getStockInfo,
    authRepository: authRepo,
  );
});

// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.length;
});

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalPrice;
});

// Cart items count provider
final cartItemsCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});

// Cart is empty provider
final cartIsEmptyProvider = Provider<bool>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.isEmpty;
});

// Cart stream provider for real-time updates
final cartStreamProvider = StreamProvider<Cart?>((ref) {
  final cartNotifier = ref.watch(cartProvider.notifier);
  return cartNotifier.watchCart();
});

// Cart stats provider
final cartStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final cartNotifier = ref.watch(cartProvider.notifier);
  return cartNotifier.getCartStats();
});

class CartNotifier extends StateNotifier<Cart> {
  StreamSubscription? _authSubscription;

  final CartRepository cartRepository;
  final GetUserCart getUserCartUC;
  final AddItemToCart addItemToCartUC;
  final UpdateItemQuantity updateItemQuantityUC;
  final RemoveItemFromCart removeItemFromCartUC;
  final ClearCart clearCartUC;
  final WatchUserCart watchUserCartUC;
  final InventoryRepository inventoryRepository;
  final CheckStock checkStockUC;
  final GetStockInfo getStockInfoUC;
  final AuthRepository authRepository;

  CartNotifier({
    required this.cartRepository,
    required this.getUserCartUC,
    required this.addItemToCartUC,
    required this.updateItemQuantityUC,
    required this.removeItemFromCartUC,
    required this.clearCartUC,
    required this.watchUserCartUC,
    required this.inventoryRepository,
    required this.checkStockUC,
    required this.getStockInfoUC,
    required this.authRepository,
  }) : super(Cart(userId: '', lastUpdated: DateTime.now())) {
    _initializeCart();
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Lắng nghe thay đổi authentication để reload giỏ hàng
  void _listenToAuthChanges() {
    _authSubscription = authRepository.onAuthStateChanged.listen((uid) async {
      if (uid != null) {
        // User đăng nhập, load giỏ hàng của user đó
        await _initializeCart();
      } else {
        // User đăng xuất, clear giỏ hàng
        state = Cart(userId: '', lastUpdated: DateTime.now());
      }
    });
  }

  /// Lấy userId từ auth repository
  String? get _userId {
    return authRepository.currentUserId;
  }

  /// Khởi tạo giỏ hàng từ Firestore
  Future<void> _initializeCart() async {
    try {
      final userId = _userId;
      if (userId == null) {
        // Chưa đăng nhập, giỏ hàng rỗng
        state = Cart(userId: '', lastUpdated: DateTime.now());
        return;
      }

      final cartEntity = await getUserCartUC(userId);
      if (cartEntity != null) {
        final cartModel = CartMapper.toModel(cartEntity);
        state = cartModel;
      } else {
        // Giỏ hàng chưa tồn tại, tạo giỏ hàng rỗng trong state
        state = Cart(userId: userId, lastUpdated: DateTime.now());
      }
    } catch (e) {
      NotificationService.showGenericError('khởi tạo giỏ hàng');
    }
  }

  /// Cập nhật userId và load giỏ hàng tương ứng
  Future<void> setUserId(String userId) async {
    await _initializeCart();
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<bool> addItem(
    String productId,
    String productName,
    double price,
    String productImage, {
    int quantity = 1,
    String productType = 'single',
    int? boxSize,
    int? setSize,
  }) async {
    // Kiểm tra đã đăng nhập chưa
    if (_userId == null) {
      NotificationService.showError(
        'Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng',
      );
      return false;
    }
    try {
      // Kiểm tra tồn kho trước khi thêm
      bool isInStock = false;

      if (productType == 'box' && boxSize != null) {
        isInStock = await inventoryRepository.checkBoxSetStock(
          productId,
          quantity,
          boxSize,
        );
      } else if (productType == 'set' && setSize != null) {
        isInStock = await inventoryRepository.checkBoxSetStock(
          productId,
          quantity,
          setSize,
        );
      } else {
        isInStock = await checkStockUC(
          CheckStockParams(productId: productId, quantity: quantity),
        );
      }

      if (!isInStock) {
        NotificationService.showOutOfStock(productName);
        return false;
      }

      // Kiểm tra sản phẩm đã có trong giỏ hàng chưa
      final existingItem = state.getItemByProductId(productId);
      if (existingItem != null && existingItem.productType == productType) {
        final newQuantity = existingItem.quantity + quantity;

        // Kiểm tra tồn kho cho tổng số lượng
        bool hasEnoughStock = false;
        if (productType == 'box' && boxSize != null) {
          hasEnoughStock = await inventoryRepository.checkBoxSetStock(
            productId,
            newQuantity,
            boxSize,
          );
        } else if (productType == 'set' && setSize != null) {
          hasEnoughStock = await inventoryRepository.checkBoxSetStock(
            productId,
            newQuantity,
            setSize,
          );
        } else {
          hasEnoughStock = await checkStockUC(
            CheckStockParams(productId: productId, quantity: newQuantity),
          );
        }

        if (!hasEnoughStock) {
          // Lấy thông tin tồn kho để hiển thị số lượng còn lại
          try {
            final stockInfo = await getStockInfoUC(productId);
            final availableStock = stockInfo.currentStock;
            NotificationService.showExceedStock(productName, availableStock);
          } catch (e) {
            NotificationService.showExceedStock(productName, 0);
          }
          return false;
        }

        // Cập nhật số lượng thông qua use case
        await updateItemQuantityUC(
          UpdateItemQuantityParams(
            userId: _userId!,
            productId: productId,
            quantity: newQuantity,
          ),
        );
        NotificationService.showUpdateCartSuccess(productName, newQuantity);
      } else {
        // Thêm sản phẩm mới thông qua use case
        await addItemToCartUC(
          AddItemToCartParams(
            userId: _userId!,
            productId: productId,
            productName: productName,
            price: price,
            productImage: productImage,
            quantity: quantity,
            productType: productType,
            boxSize: boxSize,
            setSize: setSize,
          ),
        );
        NotificationService.showAddToCartSuccess(productName, quantity);
      }

      // Cập nhật state từ Firestore
      await _refreshCart();
      return true;
    } catch (e) {
      NotificationService.showGenericError('thêm sản phẩm vào giỏ hàng');
      return false;
    }
  }

  /// Cập nhật số lượng sản phẩm
  Future<void> updateItemQuantity(String productId, int quantity) async {
    if (_userId == null) return;

    try {
      if (quantity <= 0) {
        await removeItem(productId);
        return;
      }

      await updateItemQuantityUC(
        UpdateItemQuantityParams(
          userId: _userId!,
          productId: productId,
          quantity: quantity,
        ),
      );

      // Cập nhật state từ Firestore
      await _refreshCart();
    } catch (e) {
      NotificationService.showGenericError('cập nhật số lượng sản phẩm');
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeItem(String productId) async {
    if (_userId == null) return;

    try {
      // Lấy tên sản phẩm để hiển thị thông báo
      final item = state.getItemByProductId(productId);
      final productName = item?.productName ?? 'Sản phẩm';

      await removeItemFromCartUC(
        RemoveItemFromCartParams(userId: _userId!, productId: productId),
      );

      // Cập nhật state từ Firestore
      await _refreshCart();

      NotificationService.showRemoveFromCartSuccess(productName);
    } catch (e) {
      NotificationService.showGenericError('xóa sản phẩm khỏi giỏ hàng');
    }
  }

  Future<void> removeMultipleItems(List<String> productIds) async {
    if (_userId == null || productIds.isEmpty) return;

    try {
      final success = await cartRepository.removeMultipleItems(
        _userId!,
        productIds,
      );

      if (success) {
        // Update local state
        final updatedItems = state.items
            .where((item) => !productIds.contains(item.productId))
            .toList();

        state = Cart(
          userId: state.userId,
          items: updatedItems,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      NotificationService.showGenericError('xóa sản phẩm');
    }
  }

  /// Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      await clearCartUC(_userId!);
      state = Cart(userId: _userId!, lastUpdated: DateTime.now());
      NotificationService.showClearCartSuccess();
    } catch (e) {
      NotificationService.showGenericError('xóa giỏ hàng');
    }
  }

  /// Làm mới giỏ hàng từ Firestore
  Future<void> _refreshCart() async {
    if (_userId == null) return;

    try {
      final cartEntity = await getUserCartUC(_userId!);
      if (cartEntity != null) {
        final cartModel = CartMapper.toModel(cartEntity);
        state = cartModel;
      }
      // Không cần xử lý khi cart == null vì giỏ hàng vẫn giữ nguyên state hiện tại
    } catch (e) {
      NotificationService.showGenericError('làm mới giỏ hàng');
    }
  }

  /// Đồng bộ giỏ hàng hiện tại lên Firestore
  Future<void> syncCart() async {
    try {
      final cartEntity = CartMapper.toEntity(state);
      await cartRepository.saveCart(cartEntity);
      NotificationService.showSyncSuccess();
    } catch (e) {
      NotificationService.showGenericError('đồng bộ giỏ hàng');
    }
  }

  /// Áp dụng mã giảm giá
  void applyCoupon(String couponCode, int discountAmount) {
    try {
      // Coupon validation logic
      // For now, just update the last updated time
      state = state.copyWith(lastUpdated: DateTime.now());
      NotificationService.showInfo('Mã giảm giá "$couponCode" đã được áp dụng');
    } catch (e) {
      NotificationService.showError('Không thể áp dụng mã giảm giá');
    }
  }

  /// Xóa mã giảm giá
  void removeCoupon() {
    try {
      // Coupon removal logic - implement when needed
      // For now, just update the last updated time
      state = state.copyWith(lastUpdated: DateTime.now());
      NotificationService.showInfo('Mã giảm giá đã được xóa');
    } catch (e) {
      NotificationService.showError('Không thể xóa mã giảm giá');
    }
  }

  /// Thiết lập phí vận chuyển
  void setShippingFee(int fee) {
    try {
      state = state.copyWith(lastUpdated: DateTime.now());
      NotificationService.showInfo(
        'Phí vận chuyển đã được cập nhật: ${fee.toStringAsFixed(0)} VNĐ',
      );
    } catch (e) {
      NotificationService.showError('Không thể thiết lập phí vận chuyển');
    }
  }

  /// Kiểm tra sản phẩm có trong giỏ hàng không
  bool isItemInCart(String productId) {
    return state.items.any((item) => item.productId == productId);
  }

  /// Lấy số lượng sản phẩm trong giỏ hàng
  int getItemQuantity(String productId) {
    try {
      final item = state.items.firstWhere(
        (item) => item.productId == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  /// Lấy thống kê giỏ hàng
  Future<Map<String, dynamic>> getCartStats() async {
    if (_userId == null) {
      return {
        'totalItems': 0,
        'totalPrice': 0.0,
        'itemCount': 0,
        'isEmpty': true,
        'lastUpdated': null,
      };
    }

    try {
      return await cartRepository.getCartStats(_userId!);
    } catch (e) {
      return {
        'totalItems': 0,
        'totalPrice': 0.0,
        'itemCount': 0,
        'isEmpty': true,
        'lastUpdated': null,
      };
    }
  }

  /// Lắng nghe thay đổi giỏ hàng real-time
  Stream<Cart?> watchCart() {
    if (_userId == null) {
      return Stream.value(null);
    }
    return watchUserCartUC(_userId!).map((cartEntity) {
      return cartEntity != null ? CartMapper.toModel(cartEntity) : null;
    });
  }
}
