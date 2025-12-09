import '../../../../core/usecase/usecase.dart';
import '../entities/review.dart';
import '../entities/review_status.dart';
import '../repositories/review_repository.dart';

class GetReviewsByProductParams {
  final String productId;
  final ReviewStatus? status;
  final int? limit;
  final String? sortBy;

  GetReviewsByProductParams({
    required this.productId,
    this.status,
    this.limit,
    this.sortBy,
  });
}

class GetReviewsByProduct
    implements UseCase<List<Review>, GetReviewsByProductParams> {
  final ReviewRepository repository;

  GetReviewsByProduct(this.repository);

  @override
  Future<List<Review>> call(GetReviewsByProductParams params) async {
    return await repository.getReviewsByProduct(
      params.productId,
      status: params.status,
      limit: params.limit,
      sortBy: params.sortBy,
    );
  }
}
