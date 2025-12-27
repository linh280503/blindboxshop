import '../../domain/entities/review.dart';
import '../../domain/entities/review_status.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';
import '../mappers/review_mapper.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Review>> getReviews({
    String? productId,
    String? userId,
    ReviewStatus? status,
    int? limit,
    String? orderBy,
    bool descending = true,
  }) async {
    final models = await remoteDataSource.getReviews(
      productId: productId,
      userId: userId,
      status: status,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    );
    return ReviewMapper.toEntityList(models);
  }

  @override
  Future<Review?> getReviewById(String reviewId) async {
    final model = await remoteDataSource.getReviewById(reviewId);
    return model != null ? ReviewMapper.toEntity(model) : null;
  }

  @override
  Future<List<Review>> getReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
    String? sortBy,
  }) async {
    final models = await remoteDataSource.getReviewsByProduct(
      productId,
      status: status,
      limit: limit,
      sortBy: sortBy,
    );
    return ReviewMapper.toEntityList(models);
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    final models = await remoteDataSource.getUserReviews(userId);
    return ReviewMapper.toEntityList(models);
  }

  @override
  Future<List<Review>> getPendingReviews() async {
    final models = await remoteDataSource.getPendingReviews();
    return ReviewMapper.toEntityList(models);
  }

  @override
  Future<Review> createReview(Review review) async {
    final model = ReviewMapper.toModel(review);
    final createdModel = await remoteDataSource.createReview(model);
    return ReviewMapper.toEntity(createdModel);
  }

  @override
  Future<void> updateReview(Review review) async {
    final model = ReviewMapper.toModel(review);
    await remoteDataSource.updateReview(model);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await remoteDataSource.deleteReview(reviewId);
  }

  @override
  Future<void> approveReview(String reviewId) async {
    await remoteDataSource.approveReview(reviewId);
  }

  @override
  Future<void> rejectReview(String reviewId) async {
    await remoteDataSource.rejectReview(reviewId);
  }

  @override
  Future<void> markHelpful(String reviewId, String userId) async {
    await remoteDataSource.markHelpful(reviewId, userId);
  }

  @override
  Future<void> unmarkHelpful(String reviewId, String userId) async {
    await remoteDataSource.unmarkHelpful(reviewId, userId);
  }

  @override
  Future<Map<String, dynamic>> getReviewStats(String productId) async {
    return await remoteDataSource.getReviewStats(productId);
  }

  @override
  Future<List<Review>> searchReviews(String query) async {
    final models = await remoteDataSource.searchReviews(query);
    return ReviewMapper.toEntityList(models);
  }

  @override
  Future<List<Review>> getReviewsByRating(
    String productId,
    int rating, {
    int? limit,
  }) async {
    final models = await remoteDataSource.getReviewsByRating(
      productId,
      rating,
      limit: limit,
    );
    return ReviewMapper.toEntityList(models);
  }

  @override
  Future<List<Review>> getVerifiedReviews(
    String productId, {
    int? limit,
  }) async {
    final models = await remoteDataSource.getVerifiedReviews(
      productId,
      limit: limit,
    );
    return ReviewMapper.toEntityList(models);
  }

  @override
  Future<List<Review>> getReviewsWithImages(
    String productId, {
    int? limit,
  }) async {
    final models = await remoteDataSource.getReviewsWithImages(
      productId,
      limit: limit,
    );
    return ReviewMapper.toEntityList(models);
  }

  @override
  Future<bool> hasUserReviewed(String productId, String userId) async {
    return await remoteDataSource.hasUserReviewed(productId, userId);
  }

  @override
  Future<Review?> getUserReviewForProduct(
    String productId,
    String userId,
  ) async {
    final model = await remoteDataSource.getUserReviewForProduct(
      productId,
      userId,
    );
    return model != null ? ReviewMapper.toEntity(model) : null;
  }

  @override
  Stream<Review?> watchReview(String reviewId) {
    return remoteDataSource
        .watchReview(reviewId)
        .map((model) => model != null ? ReviewMapper.toEntity(model) : null);
  }

  @override
  Stream<List<Review>> watchReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
  }) {
    return remoteDataSource
        .watchReviewsByProduct(productId, status: status, limit: limit)
        .map((models) => ReviewMapper.toEntityList(models));
  }

  @override
  Stream<List<Review>> watchUserReviews(String userId) {
    return remoteDataSource
        .watchUserReviews(userId)
        .map((models) => ReviewMapper.toEntityList(models));
  }

  @override
  Stream<List<Review>> watchPendingReviews() {
    return remoteDataSource.watchPendingReviews().map(
      (models) => ReviewMapper.toEntityList(models),
    );
  }

  @override
  Stream<Map<String, dynamic>> watchReviewStats(String productId) {
    return remoteDataSource.watchReviewStats(productId);
  }
}
