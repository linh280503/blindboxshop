import '../../../../core/usecase/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Parameters for GetActiveCategories use case
class GetActiveCategoriesParams {
  final int? limit;

  GetActiveCategoriesParams({this.limit});
}

/// Use case to get active categories
class GetActiveCategories
    implements UseCase<List<Category>, GetActiveCategoriesParams> {
  final CategoryRepository repository;

  GetActiveCategories(this.repository);

  @override
  Future<List<Category>> call(GetActiveCategoriesParams params) async {
    return await repository.getActiveCategories(limit: params.limit);
  }
}
