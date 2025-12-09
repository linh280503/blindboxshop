import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/category_model.dart';
import '../../data/mappers/category_mapper.dart';
import '../../data/di/category_providers.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_active_categories.dart';

final activeCategoriesProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  try {
    final usecase = ref.watch(getActiveCategoriesProvider);
    final entities = await usecase(GetActiveCategoriesParams());
    return CategoryMapper.toModelList(entities);
  } catch (e) {
    NotificationService.showError('Lỗi tải danh mục: ${e.toString()}');
    return [];
  }
});

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
      final repo = ref.watch(categoryRepositoryProvider);
      return CategoryNotifier(repo);
    });

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super([]);

  /// Tải tất cả danh mục
  Future<void> loadCategories({bool? isActive, int? limit}) async {
    try {
      final entities = await _repository.getCategories(
        isActive: isActive,
        limit: limit,
        orderBy: 'order',
        descending: false,
      );
      state = CategoryMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError(
        'Lỗi tải danh sách danh mục: ${e.toString()}',
      );
    }
  }

  /// Tìm kiếm danh mục
  Future<void> searchCategories(String query) async {
    try {
      final entities = await _repository.searchCategories(query);
      state = CategoryMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError('Lỗi tìm kiếm danh mục: ${e.toString()}');
    }
  }

  /// Tạo danh mục mới
  Future<void> addCategory(CategoryModel category) async {
    try {
      final created = await _repository.createCategory(
        CategoryMapper.toEntity(category),
      );
      state = [CategoryMapper.toModel(created), ...state];
      NotificationService.showSuccess('Thêm danh mục thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi thêm danh mục: ${e.toString()}');
    }
  }

  /// Cập nhật danh mục
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _repository.updateCategory(CategoryMapper.toEntity(category));

      // Cập nhật local state
      final index = state.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        final updatedCategories = List<CategoryModel>.from(state);
        updatedCategories[index] = category;
        state = updatedCategories;
      }

      NotificationService.showSuccess('Cập nhật danh mục thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi cập nhật danh mục: ${e.toString()}');
    }
  }

  /// Xóa danh mục
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _repository.deleteCategory(categoryId);

      // Cập nhật local state
      state = state.where((c) => c.id != categoryId).toList();

      NotificationService.showSuccess('Xóa danh mục thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi xóa danh mục: ${e.toString()}');
    }
  }

  /// Cập nhật thứ tự danh mục
  Future<void> updateCategoryOrder(String categoryId, int newOrder) async {
    try {
      await _repository.updateCategoryOrder(categoryId, newOrder);

      // Cập nhật local state
      final index = state.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        final updatedCategories = List<CategoryModel>.from(state);
        updatedCategories[index] = updatedCategories[index].copyWith(
          order: newOrder,
        );
        state = updatedCategories;
      }

      NotificationService.showSuccess('Cập nhật thứ tự danh mục thành công!');
    } catch (e) {
      NotificationService.showError(
        'Lỗi cập nhật thứ tự danh mục: ${e.toString()}',
      );
    }
  }

  /// Sắp xếp lại danh mục
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      await _repository.reorderCategories(categoryIds);

      // Reload categories để cập nhật thứ tự
      await loadCategories();

      NotificationService.showSuccess('Sắp xếp danh mục thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi sắp xếp danh mục: ${e.toString()}');
    }
  }

  /// Kích hoạt danh mục
  Future<void> activateCategory(String categoryId) async {
    try {
      await _repository.updateCategoryStatus(categoryId, true);

      // Cập nhật local state
      final index = state.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        final updatedCategories = List<CategoryModel>.from(state);
        updatedCategories[index] = updatedCategories[index].copyWith(
          isActive: true,
        );
        state = updatedCategories;
      }

      NotificationService.showSuccess('Kích hoạt danh mục thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi kích hoạt danh mục: ${e.toString()}');
    }
  }

  /// Vô hiệu hóa danh mục
  Future<void> deactivateCategory(String categoryId) async {
    try {
      await _repository.updateCategoryStatus(categoryId, false);

      // Cập nhật local state
      final index = state.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        final updatedCategories = List<CategoryModel>.from(state);
        updatedCategories[index] = updatedCategories[index].copyWith(
          isActive: false,
        );
        state = updatedCategories;
      }

      NotificationService.showSuccess('Vô hiệu hóa danh mục thành công!');
    } catch (e) {
      NotificationService.showError(
        'Lỗi vô hiệu hóa danh mục: ${e.toString()}',
      );
    }
  }
}


final categoryStreamProvider = StreamProvider.family<CategoryModel?, String>((
  ref,
  categoryId,
) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo
      .watchCategory(categoryId)
      .map((entity) => entity != null ? CategoryMapper.toModel(entity) : null);
});

final categoriesStreamProvider =
    StreamProvider.family<List<CategoryModel>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final repo = ref.watch(categoryRepositoryProvider);
      return repo
          .watchCategories(
            isActive: params['isActive'] as bool?,
            limit: params['limit'] as int?,
          )
          .map(CategoryMapper.toModelList);
    });

final activeCategoriesStreamProvider = StreamProvider<List<CategoryModel>>((
  ref,
) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchActiveCategories().map(CategoryMapper.toModelList);
});

// Category stats provider
final categoryStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return await repo.getCategoryStats();
});
