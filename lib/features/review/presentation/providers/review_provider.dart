import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/review_model.dart';
import '../../domain/entities/review_status.dart';
import '../../data/mappers/review_mapper.dart';
import '../../data/di/review_providers.dart';
import '../../domain/repositories/review_repository.dart';

final productReviewsProvider =
    StateNotifierProvider.family<
      ProductReviewsNotifier,
      List<ReviewModel>,
      String
    >((ref, productId) {
      final repo = ref.watch(reviewRepositoryProvider);
      return ProductReviewsNotifier(productId, repo);
    });

// Review stats provider (repository)
final reviewStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, productId) async {
    try {
      final repo = ref.watch(reviewRepositoryProvider);
      return await repo.getReviewStats(productId);
    } catch (e) {
      NotificationService.showError(
        'Lỗi tải thống kê đánh giá: ${e.toString()}',
      );
      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        'verifiedReviews': 0,
        'withImages': 0,
      };
    }
  },
);

// Pending reviews provider (for admin)
final pendingReviewsProvider =
    StateNotifierProvider<PendingReviewsNotifier, List<ReviewModel>>((ref) {
      final repo = ref.watch(reviewRepositoryProvider);
      return PendingReviewsNotifier(repo);
    });

// User reviews provider
final userReviewsProvider =
    StateNotifierProvider.family<
      UserReviewsNotifier,
      List<ReviewModel>,
      String
    >((ref, userId) {
      final repo = ref.watch(reviewRepositoryProvider);
      return UserReviewsNotifier(userId, repo);
    });

// Review form provider
final reviewFormProvider =
    StateNotifierProvider<ReviewFormNotifier, ReviewFormState>((ref) {
      final repo = ref.watch(reviewRepositoryProvider);
      return ReviewFormNotifier(repo);
    });

class ProductReviewsNotifier extends StateNotifier<List<ReviewModel>> {
  final String _productId;
  final ReviewRepository _repository;

  ProductReviewsNotifier(this._productId, this._repository) : super([]) {
    loadReviews();
  }

  Future<void> loadReviews({String? sortBy, int? limit}) async {
    try {
      final entities = await _repository.getReviewsByProduct(
        _productId,
        sortBy: sortBy,
        limit: limit,
      );
      state = ReviewMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError('Lỗi tải đánh giá: ${e.toString()}');
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      final createdEntity = await _repository.createReview(
        ReviewMapper.toEntity(review),
      );
      state = [ReviewMapper.toModel(createdEntity), ...state];
      NotificationService.showSuccess('Thêm đánh giá thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi thêm đánh giá: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> markHelpful(String reviewId, String userId) async {
    try {
      await _repository.markHelpful(reviewId, userId);

      final index = state.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final updatedReviews = List<ReviewModel>.from(state);
        final currentReview = updatedReviews[index];
        updatedReviews[index] = currentReview.copyWith(
          helpfulCount: currentReview.helpfulCount + 1,
          helpfulUsers: [...currentReview.helpfulUsers, userId],
        );
        state = updatedReviews;
      }

      NotificationService.showSuccess('Đánh dấu hữu ích thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi đánh dấu hữu ích: ${e.toString()}');
    }
  }

  Future<void> unmarkHelpful(String reviewId, String userId) async {
    try {
      await _repository.unmarkHelpful(reviewId, userId);

      final index = state.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final updatedReviews = List<ReviewModel>.from(state);
        final currentReview = updatedReviews[index];
        updatedReviews[index] = currentReview.copyWith(
          helpfulCount: currentReview.helpfulCount - 1,
          helpfulUsers: currentReview.helpfulUsers
              .where((id) => id != userId)
              .toList(),
        );
        state = updatedReviews;
      }

      NotificationService.showSuccess('Bỏ đánh dấu hữu ích thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi bỏ đánh dấu hữu ích: ${e.toString()}');
    }
  }
}

class PendingReviewsNotifier extends StateNotifier<List<ReviewModel>> {
  final ReviewRepository _repository;
  PendingReviewsNotifier(this._repository) : super([]) {
    loadPendingReviews();
  }

  Future<void> loadPendingReviews() async {
    try {
      final entities = await _repository.getPendingReviews();
      state = ReviewMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError(
        'Lỗi tải đánh giá chờ duyệt: ${e.toString()}',
      );
    }
  }

  Future<void> approveReview(String reviewId) async {
    try {
      await _repository.approveReview(reviewId);
      state = state.where((r) => r.id != reviewId).toList();
      NotificationService.showSuccess('Duyệt đánh giá thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi duyệt đánh giá: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> rejectReview(String reviewId) async {
    try {
      await _repository.rejectReview(reviewId);
      state = state.where((r) => r.id != reviewId).toList();
      NotificationService.showSuccess('Từ chối đánh giá thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi từ chối đánh giá: ${e.toString()}');
      rethrow;
    }
  }
}

class UserReviewsNotifier extends StateNotifier<List<ReviewModel>> {
  final String _userId;
  final ReviewRepository _repository;

  UserReviewsNotifier(this._userId, this._repository) : super([]) {
    loadUserReviews();
  }

  Future<void> loadUserReviews() async {
    try {
      final entities = await _repository.getUserReviews(_userId);
      state = ReviewMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError(
        'Lỗi tải đánh giá của bạn: ${e.toString()}',
      );
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _repository.deleteReview(reviewId);
      state = state.where((r) => r.id != reviewId).toList();
      NotificationService.showSuccess('Xóa đánh giá thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi xóa đánh giá: ${e.toString()}');
      rethrow;
    }
  }
}

class ReviewFormState {
  final int rating;
  final String comment;
  final List<String> images;
  final bool isLoading;
  final String? error;

  const ReviewFormState({
    this.rating = 5,
    this.comment = '',
    this.images = const [],
    this.isLoading = false,
    this.error,
  });

  ReviewFormState copyWith({
    int? rating,
    String? comment,
    List<String>? images,
    bool? isLoading,
    String? error,
  }) {
    return ReviewFormState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ReviewFormNotifier extends StateNotifier<ReviewFormState> {
  final ReviewRepository _repository;
  ReviewFormNotifier(this._repository) : super(const ReviewFormState());

  void updateRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void updateComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  void addImage(String imageUrl) {
    final newImages = List<String>.from(state.images)..add(imageUrl);
    state = state.copyWith(images: newImages);
  }

  void removeImage(String imageUrl) {
    final newImages = List<String>.from(state.images)..remove(imageUrl);
    state = state.copyWith(images: newImages);
  }

  void addImages(List<String> imageUrls) {
    final newImages = List<String>.from(state.images)..addAll(imageUrls);
    state = state.copyWith(images: newImages);
  }

  void clearForm() {
    state = const ReviewFormState();
  }

  Future<void> submitReview({
    required String productId,
    required String userId,
    required String userName,
    required String userAvatar,
    String? orderId,
  }) async {
    if (state.comment.trim().isEmpty) {
      state = state.copyWith(error: 'Vui lòng nhập đánh giá');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final entity = ReviewMapper.toEntity(
        ReviewModel(
          id: '',
          productId: productId,
          userId: userId,
          userName: userName,
          userAvatar: userAvatar,
          rating: state.rating,
          comment: state.comment.trim(),
          images: state.images,
          status: ReviewStatus.approved,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          orderId: orderId,
          isVerified: orderId != null,
        ),
      );

      await _repository.createReview(entity);
      clearForm();
      NotificationService.showSuccess('Gửi đánh giá thành công!');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Lỗi gửi đánh giá: $e');
      NotificationService.showError('Lỗi gửi đánh giá: ${e.toString()}');
    }
  }
}

// Stream providers (repository)
final reviewStreamProvider = StreamProvider.family<ReviewModel?, String>((
  ref,
  reviewId,
) {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo
      .watchReview(reviewId)
      .map((entity) => entity != null ? ReviewMapper.toModel(entity) : null);
});

final productReviewsStreamProvider =
    StreamProvider.family<List<ReviewModel>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final repo = ref.watch(reviewRepositoryProvider);
      return repo
          .watchReviewsByProduct(
            params['productId'] as String,
            status: params['status'] as ReviewStatus?,
            limit: params['limit'] as int?,
          )
          .map(ReviewMapper.toModelList);
    });

final userReviewsStreamProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, userId) {
      final repo = ref.watch(reviewRepositoryProvider);
      return repo.watchUserReviews(userId).map(ReviewMapper.toModelList);
    });

final pendingReviewsStreamProvider = StreamProvider<List<ReviewModel>>((ref) {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.watchPendingReviews().map(ReviewMapper.toModelList);
});

// Stream provider for review stats (realtime)
final reviewStatsStreamProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, productId) {
      final repo = ref.watch(reviewRepositoryProvider);
      return repo.watchReviewStats(productId);
    });

// FutureProvider for reviews (to avoid Firestore index issues)
final productReviewsFutureProvider =
    FutureProvider.family<List<ReviewModel>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repo = ref.watch(reviewRepositoryProvider);
      final reviews = await repo.getReviewsByProduct(
        params['productId'] as String,
        limit: params['limit'] as int?,
      );
      return ReviewMapper.toModelList(reviews);
    });

// FutureProvider for review stats (to avoid Firestore index issues)
final reviewStatsFutureProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, productId) async {
      final repo = ref.watch(reviewRepositoryProvider);
      return await repo.getReviewStats(productId);
    });
