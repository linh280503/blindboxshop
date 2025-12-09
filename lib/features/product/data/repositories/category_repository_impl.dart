import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../mappers/category_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    final models = await remoteDataSource.getCategories(
      isActive: isActive,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    );
    return CategoryMapper.toEntityList(models);
  }

  @override
  Future<Category?> getCategoryById(String categoryId) async {
    final model = await remoteDataSource.getCategoryById(categoryId);
    return model != null ? CategoryMapper.toEntity(model) : null;
  }

  @override
  Future<List<Category>> getActiveCategories({int? limit}) async {
    final models = await remoteDataSource.getActiveCategories(limit: limit);
    return CategoryMapper.toEntityList(models);
  }

  @override
  Future<Category> createCategory(Category category) async {
    final model = CategoryMapper.toModel(category);
    final createdModel = await remoteDataSource.createCategory(model);
    return CategoryMapper.toEntity(createdModel);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryMapper.toModel(category);
    await remoteDataSource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await remoteDataSource.deleteCategory(categoryId);
  }

  @override
  Future<void> updateCategoryStatus(String categoryId, bool isActive) async {
    await remoteDataSource.updateCategoryStatus(categoryId, isActive);
  }

  @override
  Future<void> updateCategoryOrder(String categoryId, int newOrder) async {
    await remoteDataSource.updateCategoryOrder(categoryId, newOrder);
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    await remoteDataSource.reorderCategories(categoryIds);
  }

  @override
  Future<Map<String, dynamic>> getCategoryStats() async {
    return await remoteDataSource.getCategoryStats();
  }

  @override
  Future<List<Category>> searchCategories(String query) async {
    final models = await remoteDataSource.searchCategories(query);
    return CategoryMapper.toEntityList(models);
  }

  @override
  Future<Category?> getCategoryByName(String name) async {
    final model = await remoteDataSource.getCategoryByName(name);
    return model != null ? CategoryMapper.toEntity(model) : null;
  }

  @override
  Future<bool> categoryExists(String name) async {
    return await remoteDataSource.categoryExists(name);
  }

  @override
  Future<List<String>> getCategoryNames() async {
    return await remoteDataSource.getCategoryNames();
  }

  @override
  Stream<Category?> watchCategory(String categoryId) {
    return remoteDataSource
        .watchCategory(categoryId)
        .map((model) => model != null ? CategoryMapper.toEntity(model) : null);
  }

  @override
  Stream<List<Category>> watchCategories({bool? isActive, int? limit}) {
    return remoteDataSource
        .watchCategories(isActive: isActive, limit: limit)
        .map((models) => CategoryMapper.toEntityList(models));
  }

  @override
  Stream<List<Category>> watchActiveCategories({int? limit}) {
    return remoteDataSource
        .watchActiveCategories(limit: limit)
        .map((models) => CategoryMapper.toEntityList(models));
  }
}
