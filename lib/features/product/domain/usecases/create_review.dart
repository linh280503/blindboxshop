import '../../../../core/usecase/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Use case to create a review
class CreateReview implements UseCase<Review, Review> {
  final ReviewRepository repository;

  CreateReview(this.repository);

  @override
  Future<Review> call(Review review) async {
    return await repository.createReview(review);
  }
}
