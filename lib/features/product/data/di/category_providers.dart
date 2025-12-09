import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/category_remote_datasource.dart';
import '../repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_active_categories.dart';

// Datasource provider
final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  return CategoryRemoteDataSourceImpl();
});

// Repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource: dataSource);
});

// Use cases providers
final getActiveCategoriesProvider = Provider<GetActiveCategories>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetActiveCategories(repository);
});
