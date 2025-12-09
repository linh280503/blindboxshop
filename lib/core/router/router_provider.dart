import 'package:blind_box_shop/core/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';

import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/personal_info_page.dart';
import '../../features/auth/presentation/pages/delivery_address_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/product/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/products_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/order/presentation/pages/checkout_page.dart';
import '../../features/order/presentation/pages/order_history_page.dart';
import '../../features/order/presentation/pages/review_page.dart';
import '../../features/order/presentation/pages/review_all_products_page.dart';
import '../../features/order/presentation/pages/order_detail_page.dart';
import '../../features/address/presentation/pages/address_list_page.dart';
import '../../features/address/presentation/pages/add_address_page.dart';
import '../../features/address/data/models/address_model.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/product/presentation/pages/admin_product_management_page.dart';
import '../../features/product/presentation/pages/admin_add_product_page.dart';
import '../../features/order/presentation/pages/admin_order_management_page.dart';
import '../../features/auth/presentation/pages/admin_customer_management_page.dart';
import '../../features/admin/presentation/pages/admin_analytics_page.dart';
import '../../features/inventory/presentation/pages/admin_inventory_management_page.dart';
import '../../features/banner/presentation/pages/banner_management_page.dart';
import '../../features/discount/presentation/pages/admin_voucher_management_page.dart';
import '../../features/discount/presentation/pages/admin_create_voucher_page.dart';
import '../../features/discount/presentation/pages/admin_edit_voucher_page.dart';
import '../../features/intro/presentation/pages/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      // Nếu đang loading, giữ ở trang Splash
      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn =
          authState.user != null && authState.user!.isEmailVerified;
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';
      final isForgotPassword = state.uri.path == '/forgot-password';

      final isSplash = state.uri.path == '/splash';

      // Nếu chưa login
      if (!isLoggedIn) {
        if (isSplash) {
          return '/home';
        }

        // Các trang yêu cầu auth
        if (state.uri.path.startsWith('/admin') ||
            state.uri.path.startsWith('/profile') ||
            state.uri.path.startsWith('/cart') ||
            state.uri.path.startsWith('/orders') ||
            state.uri.path.startsWith('/address-list') ||
            state.uri.path.startsWith('/add-address') ||
            state.uri.path.startsWith('/edit-address') ||
            state.uri.path.startsWith('/checkout')) {
          return '/login';
        }
        return null;
      }

      // Nếu đã login
      // Check role
      final role = authState.user?.role ?? 'customer';

      if (isSplash) {
        return role == 'admin' ? '/admin' : '/home';
      }

      // Nếu đang ở trang login/register mà đã login rồi -> redirect về đúng nơi
      if (isLoggingIn || isRegistering || isForgotPassword) {
        return role == 'admin' ? '/admin' : '/home';
      }

      // Nếu user là admin
      if (role == 'admin') {
        // Nếu đang ở home, redirect sang admin dashboard
        if (state.uri.path == '/home') {
          return '/admin';
        }
        // Admin được phép truy cập mọi trang, nhưng nếu muốn restrict admin khỏi trang customer thì thêm logic
      }

      // Nếu user là customer
      if (role != 'admin') {
        // Cấm vào trang admin
        if (state.uri.path.startsWith('/admin')) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      // Splash Route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailPage(
            key: ValueKey<String>(productId),
            productId: productId,
          );
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) =>
            const AuthGuard(requireAuth: true, child: CartPage()),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) =>
            const AuthGuard(requireAuth: true, child: OrderHistoryPage()),
      ),
      GoRoute(
        path: '/order-history',
        name: 'order-history',
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'];
          if (orderId != null && orderId.isNotEmpty) {
            return OrderDetailPage(orderId: orderId);
          }
          return const OrderHistoryPage();
        },
      ),
      GoRoute(
        path: '/review',
        name: 'review',
        builder: (context, state) {
          final productId = state.uri.queryParameters['productId'] ?? '';
          final productName = state.uri.queryParameters['productName'] ?? '';
          final productImage = state.uri.queryParameters['productImage'] ?? '';
          return ReviewPage(
            productId: productId,
            productName: productName,
            productImage: productImage,
          );
        },
      ),
      GoRoute(
        path: '/review-all',
        name: 'review-all',
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'] ?? '';
          return ReviewAllProductsPage(orderId: orderId);
        },
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) =>
            const AuthGuard(requireAuth: true, child: ProfilePage()),
      ),
      GoRoute(
        path: '/personal-info',
        name: 'personal-info',
        builder: (context, state) => const PersonalInfoPage(),
      ),
      GoRoute(
        path: '/delivery-address',
        name: 'delivery-address',
        builder: (context, state) => const DeliveryAddressPage(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/address-list',
        name: 'address-list',
        builder: (context, state) => const AddressListPage(),
      ),
      GoRoute(
        path: '/add-address',
        name: 'add-address',
        builder: (context, state) => const AddAddressPage(),
      ),
      GoRoute(
        path: '/edit-address',
        name: 'edit-address',
        builder: (context, state) {
          final address = state.extra as AddressModel?;
          return AddAddressPage(initialAddress: address);
        },
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminDashboardPage(),
        ),
      ),
      GoRoute(
        path: '/admin/products',
        name: 'admin-products',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminProductManagementPage(),
        ),
      ),
      GoRoute(
        path: '/admin/products/add',
        name: 'admin-add-product',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminAddProductPage(),
        ),
      ),
      GoRoute(
        path: '/admin/orders',
        name: 'admin-orders',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminOrderManagementPage(),
        ),
      ),
      GoRoute(
        path: '/admin/customers',
        name: 'admin-customers',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminCustomerManagementPage(),
        ),
      ),
      GoRoute(
        path: '/admin/analytics',
        name: 'admin-analytics',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminAnalyticsPage(),
        ),
      ),
      GoRoute(
        path: '/admin/analytics/revenue',
        name: 'admin-analytics-revenue',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminAnalyticsPage(initialSection: 'Doanh thu'),
        ),
      ),
      GoRoute(
        path: '/admin/analytics/orders',
        name: 'admin-analytics-orders',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminAnalyticsPage(initialSection: 'Đơn hàng'),
        ),
      ),
      GoRoute(
        path: '/admin/analytics/products',
        name: 'admin-analytics-products',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminAnalyticsPage(initialSection: 'Sản phẩm'),
        ),
      ),
      GoRoute(
        path: '/admin/analytics/customers',
        name: 'admin-analytics-customers',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminAnalyticsPage(initialSection: 'Khách hàng'),
        ),
      ),
      GoRoute(
        path: '/admin/inventory',
        name: 'admin-inventory',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminInventoryManagementPage(),
        ),
      ),
      GoRoute(
        path: '/admin/banners',
        name: 'admin-banners',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: BannerManagementPage(),
        ),
      ),
      GoRoute(
        path: '/admin/voucher',
        name: 'admin-voucher',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminVoucherManagementPage(),
        ),
      ),
      GoRoute(
        path: '/admin/voucher/create',
        name: 'admin-voucher-create',
        builder: (context, state) => const AuthGuard(
          requireAuth: true,
          requireAdmin: true,
          child: AdminCreateVoucherPage(),
        ),
      ),
      GoRoute(
        path: '/admin/voucher/edit/:id',
        name: 'admin-voucher-edit',
        builder: (context, state) {
          final voucherId = state.pathParameters['id']!;
          return AuthGuard(
            requireAuth: true,
            requireAdmin: true,
            child: AdminEditVoucherPage(voucherId: voucherId),
          );
        },
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}
