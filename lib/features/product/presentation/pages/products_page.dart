import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/product_card.dart';
import '../providers/product_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../data/models/product_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage>
    with AutomaticKeepAliveClientMixin {
  String? _selectedCategory;
  String? _selectedBrand;
  String _sortBy = 'createdAt_desc';
  String _query = '';
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final uri = GoRouterState.of(context).uri;
    final initialCategory = uri.queryParameters['category'];
    final initialBrand = uri.queryParameters['brand'];
    final initialQuery = uri.queryParameters['q'];

    // Check if URL parameters have changed
    bool urlChanged = false;
    if (_selectedCategory != initialCategory) {
      _selectedCategory = initialCategory;
      urlChanged = true;
    }
    if (_selectedBrand != initialBrand) {
      _selectedBrand = initialBrand;
      urlChanged = true;
    }
    if (_query != (initialQuery ?? '')) {
      _query = initialQuery ?? '';
      urlChanged = true;
    }

    if (urlChanged) {
      _hasInitialized = false;
      if (initialCategory != null) {
        _selectedBrand = null;
      }
    }

    if (urlChanged) {
      _hasInitialized = false;
    }

    if (_hasInitialized &&
        !urlChanged &&
        _selectedCategory == null &&
        _selectedBrand == null &&
        _query.isEmpty) {
      return;
    }

    bool shouldReload = false;

    if (_selectedCategory != null) {
      shouldReload = true;
    }
    if (_selectedBrand != null) {
      shouldReload = true;
    }
    if (_query.isNotEmpty) {
      shouldReload = true;
    }

    if (shouldReload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _applyFilters();
            _hasInitialized = true;
          }
        });
      });
    } else {
      // Load all products if no filters
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ref.read(productsProvider.notifier).loadProducts(isActive: true);
            _hasInitialized = true;
          }
        });
      });
    }
  }

  void _applyFilters() {
    // Map display category names to database category names
    String? mappedCategory = _mapCategoryName(_selectedCategory);

    ref
        .read(productsProvider.notifier)
        .loadProducts(
          category: mappedCategory,
          brand: _selectedBrand,
          isActive: true,
        );
  }

  void _updateUrlAndApplyFilters() {
    // Update URL with current filters
    final uri = GoRouterState.of(context).uri;
    final queryParams = Map<String, String>.from(uri.queryParameters);

    if (_selectedCategory != null) {
      queryParams['category'] = _selectedCategory!;
    } else {
      queryParams.remove('category');
    }

    if (_selectedBrand != null) {
      queryParams['brand'] = _selectedBrand!;
    } else {
      queryParams.remove('brand');
    }

    if (_query.isNotEmpty) {
      queryParams['q'] = _query;
    } else {
      queryParams.remove('q');
    }

    // Navigate to updated URL
    final newUri = uri.replace(queryParameters: queryParams);
    context.go(newUri.toString());

    // Apply filters
    _applyFilters();
  }

  String? _mapCategoryName(String? displayName) {
    if (displayName == null) return null;

    // Get categories from provider to create dynamic mapping
    final categoriesAsync = ref.read(activeCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        // Find category by name and return its id
        final category = categories.firstWhere(
          (c) => c.name == displayName,
          orElse: () => categories.first, // fallback
        );
        return category.id;
      },
      loading: () {
        return displayName;
      },
      error: (_, __) {
        return displayName;
      },
    );
  }

  List<ProductModel> _applyFiltersAndSort(List<ProductModel> products) {
    Iterable<ProductModel> result = products;

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      });
    }

    final list = result.toList();

    // Apply sorting
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'sold_desc':
        list.sort((a, b) => b.sold.compareTo(a.sold));
        break;
      case 'rating_desc':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'createdAt_desc':
      default:
        // Server already sorts by createdAt, no need to sort again
        break;
    }
    return list;
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.50,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                ),
              ),
              // Content skeleton
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        height: 10.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        height: 10.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateWithFilters() {
    final hasFilters =
        _selectedCategory != null ||
        _selectedBrand != null ||
        _query.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            hasFilters
                ? 'Không tìm thấy sản phẩm phù hợp'
                : 'Không có sản phẩm',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Hãy thử thay đổi bộ lọc hoặc tìm kiếm khác'
                : 'Vui lòng thử lại sau',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasFilters) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedBrand = null;
                      _query = '';
                    });
                    _updateUrlAndApplyFilters();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Xóa bộ lọc'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
              ],
              ElevatedButton.icon(
                onPressed: () {
                  _applyFilters();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tải lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return _buildEmptyStateWithFilters();
    }
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      cacheExtent: 1000, // Cache more items for smoother scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.50,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return RepaintBoundary(
          child: ProductCard(
            id: product.id,
            name: product.name,
            brand: product.brand,
            price: product.price,
            originalPrice: product.originalPrice,
            rating: product.rating,
            sold: product.sold,
            reviewCount: product.reviewCount,
            image: product.images.isNotEmpty ? product.images.first : '',
            onTap: () {
              context.go('/product/${product.id}');
            },
            onAddToCart: () async {
              // Kiểm tra đăng nhập trước khi thêm vào giỏ hàng
              final authState = ref.read(authProvider);
              if (authState.user == null) {
                // Chưa đăng nhập, chuyển hướng đến trang đăng nhập
                if (context.mounted) {
                  context.go('/login');
                }
                return;
              }

              await ref
                  .read(cartProvider.notifier)
                  .addItem(
                    product.id,
                    product.name,
                    product.price,
                    product.images.isNotEmpty ? product.images.first : '',
                    quantity: 1,
                    productType: product.productType.name,
                    boxSize: product.boxSize,
                    setSize: product.setSize,
                  );
            },
          ),
        );
      },
    );
  }

  Widget _buildFiltersBar() {
    final categoriesAsync = ref.watch(activeCategoriesProvider);
    final brandsAsync = ref.watch(brandsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Category dropdown
          categoriesAsync.when(
            data: (categories) {
              final items = <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tất cả danh mục'),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.name,
                    child: Text(c.name),
                  ),
                ),
              ];
              final categoryNames = categories.map((c) => c.name).toSet();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.lightGrey.withOpacity(0.5),
                  ),
                ),
                child: DropdownButton<String?>(
                  value:
                      (_selectedCategory != null &&
                          categoryNames.contains(_selectedCategory))
                      ? _selectedCategory
                      : null,
                  hint: const Text('Danh mục'),
                  underline: const SizedBox.shrink(),
                  items: items,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    _updateUrlAndApplyFilters();
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          SizedBox(width: 12.w),

          // Brand dropdown
          brandsAsync.when(
            data: (brands) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.lightGrey.withOpacity(0.5),
                  ),
                ),
                child: DropdownButton<String?>(
                  value:
                      (_selectedBrand != null &&
                          brands.contains(_selectedBrand))
                      ? _selectedBrand
                      : null,
                  hint: const Text('Thương hiệu'),
                  underline: const SizedBox.shrink(),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tất cả thương hiệu'),
                    ),
                    ...brands.map(
                      (b) =>
                          DropdownMenuItem<String?>(value: b, child: Text(b)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                    });
                    _updateUrlAndApplyFilters();
                  },
                ),
              );
            },
            loading: () => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
              ),
              child: const Text('Đang tải...'),
            ),
            error: (_, __) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
              ),
              child: const Text('Lỗi tải thương hiệu'),
            ),
          ),

          SizedBox(width: 12.w),

          // Reset button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _selectedBrand = null;
                  _query = '';
                });
                _updateUrlAndApplyFilters();
              },
              child: const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
          ),

          SizedBox(width: 12.w),

          // Sort dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              hint: const Text('Sắp xếp'),
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: 'createdAt_desc',
                  child: Text('Mới nhất'),
                ),
                DropdownMenuItem(
                  value: 'price_asc',
                  child: Text('Giá tăng dần'),
                ),
                DropdownMenuItem(
                  value: 'price_desc',
                  child: Text('Giá giảm dần'),
                ),
                DropdownMenuItem(value: 'sold_desc', child: Text('Bán chạy')),
                DropdownMenuItem(
                  value: 'rating_desc',
                  child: Text('Đánh giá cao'),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _sortBy = v;
                });
              },
            ),
          ),

          SizedBox(width: 12.w),

          // Reset button
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedBrand = null;
                _sortBy = 'createdAt_desc';
              });
              context.go('/products');
            },
            child: const Text('Xóa bộ lọc'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final uri = GoRouterState.of(context).uri;
    final type = uri.queryParameters['type'] ?? 'all';
    final category = uri.queryParameters['category'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltersBar(),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (type == 'hot') {
                    final hotAsync = ref.watch(hotProductsProvider);
                    return hotAsync.when(
                      data: (data) => buildGrid(_applyFiltersAndSort(data)),
                      loading: () => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Đang tải sản phẩm hot...'),
                          ],
                        ),
                      ),
                      error: (e, _) =>
                          Center(child: Text('Lỗi tải sản phẩm hot: $e')),
                    );
                  }
                  if (type == 'new') {
                    final newAsync = ref.watch(newProductsProvider);
                    return newAsync.when(
                      data: (data) => buildGrid(_applyFiltersAndSort(data)),
                      loading: () => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Đang tải sản phẩm mới...'),
                          ],
                        ),
                      ),
                      error: (e, _) =>
                          Center(child: Text('Lỗi tải sản phẩm mới: $e')),
                    );
                  }
                  final allProducts = ref.watch(productsProvider);

                  // Show loading skeleton while products are being loaded
                  if (allProducts.isEmpty && !_hasInitialized) {
                    return _buildLoadingSkeleton();
                  }

                  // Apply filters and sorting
                  final filteredProducts = _applyFiltersAndSort(allProducts);
                  return buildGrid(filteredProducts);
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          category != null && category.isNotEmpty
              ? 'Danh mục: $category'
              : type == 'hot'
              ? 'Tất cả sản phẩm hot'
              : type == 'new'
              ? 'Tất cả sản phẩm mới'
              : 'Tất cả sản phẩm',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          if ((category != null && category.isNotEmpty) || type != 'all')
            TextButton(
              onPressed: () {
                context.go('/products');
              },
              child: const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
