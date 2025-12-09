import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  });
  Future<Category?> getCategoryById(String categoryId);
  Future<List<Category>> getActiveCategories({int? limit});
  Future<Category> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String categoryId);
  Future<void> updateCategoryStatus(String categoryId, bool isActive);
  Future<void> updateCategoryOrder(String categoryId, int newOrder);
  Future<void> reorderCategories(List<String> categoryIds);
  Future<Map<String, dynamic>> getCategoryStats();
  Future<List<Category>> searchCategories(String query);
  Future<Category?> getCategoryByName(String name);
  Future<bool> categoryExists(String name);
  Future<List<String>> getCategoryNames();

  // Streams
  Stream<Category?> watchCategory(String categoryId);
  Stream<List<Category>> watchCategories({bool? isActive, int? limit});
  Stream<List<Category>> watchActiveCategories({int? limit});
}
