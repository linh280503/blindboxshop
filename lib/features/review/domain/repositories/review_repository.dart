import '../entities/review.dart';
import '../entities/review_status.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviews({
    String? productId,
    String? userId,
    ReviewStatus? status,
    int? limit,
    String? orderBy,
    bool descending = true,
  });
  Future<Review?> getReviewById(String reviewId);
  Future<List<Review>> getReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
    String? sortBy,
  });
  Future<List<Review>> getUserReviews(String userId);
  Future<List<Review>> getPendingReviews();
  Future<Review> createReview(Review review);
  Future<void> updateReview(Review review);
  Future<void> deleteReview(String reviewId);
  Future<void> approveReview(String reviewId);
  Future<void> rejectReview(String reviewId);
  Future<void> markHelpful(String reviewId, String userId);
  Future<void> unmarkHelpful(String reviewId, String userId);
  Future<Map<String, dynamic>> getReviewStats(String productId);
  Future<List<Review>> searchReviews(String query);
  Future<List<Review>> getReviewsByRating(
    String productId,
    int rating, {
    int? limit,
  });
  Future<List<Review>> getVerifiedReviews(String productId, {int? limit});
  Future<List<Review>> getReviewsWithImages(String productId, {int? limit});
  Future<bool> hasUserReviewed(String productId, String userId);
  Future<Review?> getUserReviewForProduct(String productId, String userId);

  // Streams
  Stream<Review?> watchReview(String reviewId);
  Stream<List<Review>> watchReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
  });
  Stream<List<Review>> watchUserReviews(String userId);
  Stream<List<Review>> watchPendingReviews();
  Stream<Map<String, dynamic>> watchReviewStats(String productId);
}
