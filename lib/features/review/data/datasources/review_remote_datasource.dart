// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../../domain/entities/review_status.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviews({
    String? productId,
    String? userId,
    ReviewStatus? status,
    int? limit,
    String? orderBy,
    bool descending = true,
  });
  Future<ReviewModel?> getReviewById(String reviewId);
  Future<List<ReviewModel>> getReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
    String? sortBy,
  });
  Future<List<ReviewModel>> getUserReviews(String userId);
  Future<List<ReviewModel>> getPendingReviews();
  Future<ReviewModel> createReview(ReviewModel review);
  Future<void> updateReview(ReviewModel review);
  Future<void> deleteReview(String reviewId);
  Future<void> approveReview(String reviewId);
  Future<void> rejectReview(String reviewId);
  Future<void> markHelpful(String reviewId, String userId);
  Future<void> unmarkHelpful(String reviewId, String userId);
  Future<Map<String, dynamic>> getReviewStats(String productId);
  Future<List<ReviewModel>> searchReviews(String query);
  Future<List<ReviewModel>> getReviewsByRating(
    String productId,
    int rating, {
    int? limit,
  });
  Future<List<ReviewModel>> getVerifiedReviews(String productId, {int? limit});
  Future<List<ReviewModel>> getReviewsWithImages(
    String productId, {
    int? limit,
  });
  Future<bool> hasUserReviewed(String productId, String userId);
  Future<ReviewModel?> getUserReviewForProduct(String productId, String userId);
  Stream<ReviewModel?> watchReview(String reviewId);
  Stream<List<ReviewModel>> watchReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
  });
  Stream<List<ReviewModel>> watchUserReviews(String userId);
  Stream<List<ReviewModel>> watchPendingReviews();
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _reviewsCollection = 'reviews';

  ReviewRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ReviewModel>> getReviews({
    String? productId,
    String? userId,
    ReviewStatus? status,
    int? limit,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      Query query = firestore.collection(_reviewsCollection);

      if (productId != null && productId.isNotEmpty) {
        query = query.where('productId', isEqualTo: productId);
      }
      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (orderBy != null) {
        String actualField;
        switch (orderBy) {
          case 'newest':
            actualField = 'createdAt';
            break;
          case 'oldest':
            actualField = 'createdAt';
            descending = false;
            break;
          case 'highest_rating':
            actualField = 'rating';
            break;
          case 'lowest_rating':
            actualField = 'rating';
            descending = false;
            break;
          case 'most_helpful':
            actualField = 'helpfulCount';
            break;
          default:
            actualField = orderBy;
        }
        query = query.orderBy(actualField, descending: descending);
      } else {
        query = query.orderBy('createdAt', descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đánh giá: $e');
    }
  }

  @override
  Future<ReviewModel?> getReviewById(String reviewId) async {
    try {
      final doc = await firestore
          .collection(_reviewsCollection)
          .doc(reviewId)
          .get();

      if (!doc.exists) return null;

      return ReviewModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
    String? sortBy,
  }) async {
    try {
      return await getReviews(
        productId: productId,
        status: status ?? ReviewStatus.approved,
        limit: limit,
        orderBy: sortBy,
      );
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá theo sản phẩm: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      return await getReviews(
        userId: userId,
        orderBy: 'createdAt',
        descending: true,
      );
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá của user: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getPendingReviews() async {
    try {
      return await getReviews(
        status: ReviewStatus.pending,
        orderBy: 'createdAt',
        descending: true,
      );
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá chờ duyệt: $e');
    }
  }

  @override
  Future<ReviewModel> createReview(ReviewModel review) async {
    try {
      final docRef = await firestore
          .collection(_reviewsCollection)
          .add(review.toFirestore());

      return review.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Lỗi tạo đánh giá: $e');
    }
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    try {
      await firestore
          .collection(_reviewsCollection)
          .doc(review.id)
          .update(review.toFirestore());
    } catch (e) {
      throw Exception('Lỗi cập nhật đánh giá: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await firestore.collection(_reviewsCollection).doc(reviewId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa đánh giá: $e');
    }
  }

  @override
  Future<void> approveReview(String reviewId) async {
    try {
      await firestore.collection(_reviewsCollection).doc(reviewId).update({
        'status': ReviewStatus.approved.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi duyệt đánh giá: $e');
    }
  }

  @override
  Future<void> rejectReview(String reviewId) async {
    try {
      await firestore.collection(_reviewsCollection).doc(reviewId).update({
        'status': ReviewStatus.rejected.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi từ chối đánh giá: $e');
    }
  }

  @override
  Future<void> markHelpful(String reviewId, String userId) async {
    try {
      final review = await getReviewById(reviewId);
      if (review == null) {
        throw Exception('Đánh giá không tồn tại');
      }

      if (review.helpfulUsers.contains(userId)) {
        throw Exception('Bạn đã đánh dấu hữu ích rồi');
      }

      await firestore.collection(_reviewsCollection).doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
        'helpfulUsers': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi đánh dấu hữu ích: $e');
    }
  }

  @override
  Future<void> unmarkHelpful(String reviewId, String userId) async {
    try {
      final review = await getReviewById(reviewId);
      if (review == null) {
        throw Exception('Đánh giá không tồn tại');
      }

      if (!review.helpfulUsers.contains(userId)) {
        throw Exception('Bạn chưa đánh dấu hữu ích');
      }

      await firestore.collection(_reviewsCollection).doc(reviewId).update({
        'helpfulCount': FieldValue.increment(-1),
        'helpfulUsers': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi bỏ đánh dấu hữu ích: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getReviewStats(String productId) async {
    try {
      final reviews = await getReviewsByProduct(
        productId,
        status: ReviewStatus.approved,
      );

      if (reviews.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          'verifiedReviews': 0,
          'withImages': 0,
        };
      }

      final totalReviews = reviews.length;
      final averageRating =
          reviews.fold(0.0, (sum, review) => sum + review.rating) /
          totalReviews;

      final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final review in reviews) {
        ratingDistribution[review.rating] =
            (ratingDistribution[review.rating] ?? 0) + 1;
      }

      final verifiedReviews = reviews.where((r) => r.isVerified).length;
      final withImages = reviews.where((r) => r.images.isNotEmpty).length;

      return {
        'totalReviews': totalReviews,
        'averageRating': averageRating,
        'ratingDistribution': ratingDistribution,
        'verifiedReviews': verifiedReviews,
        'withImages': withImages,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê đánh giá: $e');
    }
  }

  @override
  Future<List<ReviewModel>> searchReviews(String query) async {
    try {
      final snapshot = await firestore.collection(_reviewsCollection).get();

      List<ReviewModel> reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      if (query.isNotEmpty) {
        reviews = reviews.where((review) {
          return review.comment.toLowerCase().contains(query.toLowerCase()) ||
              review.userName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reviews;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm đánh giá: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByRating(
    String productId,
    int rating, {
    int? limit,
  }) async {
    try {
      final reviews = await getReviewsByProduct(
        productId,
        status: ReviewStatus.approved,
      );
      final filteredReviews = reviews.where((r) => r.rating == rating).toList();

      if (limit != null && limit > 0) {
        return filteredReviews.take(limit).toList();
      }

      return filteredReviews;
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá theo rating: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getVerifiedReviews(
    String productId, {
    int? limit,
  }) async {
    try {
      final reviews = await getReviewsByProduct(
        productId,
        status: ReviewStatus.approved,
      );
      final verifiedReviews = reviews.where((r) => r.isVerified).toList();

      if (limit != null && limit > 0) {
        return verifiedReviews.take(limit).toList();
      }

      return verifiedReviews;
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá đã xác minh: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsWithImages(
    String productId, {
    int? limit,
  }) async {
    try {
      final reviews = await getReviewsByProduct(
        productId,
        status: ReviewStatus.approved,
      );
      final reviewsWithImages = reviews
          .where((r) => r.images.isNotEmpty)
          .toList();

      if (limit != null && limit > 0) {
        return reviewsWithImages.take(limit).toList();
      }

      return reviewsWithImages;
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá có hình ảnh: $e');
    }
  }

  @override
  Future<bool> hasUserReviewed(String productId, String userId) async {
    try {
      final reviews = await getReviews(productId: productId, userId: userId);
      return reviews.isNotEmpty;
    } catch (e) {
      throw Exception('Lỗi kiểm tra đánh giá: $e');
    }
  }

  @override
  Future<ReviewModel?> getUserReviewForProduct(
    String productId,
    String userId,
  ) async {
    try {
      final reviews = await getReviews(productId: productId, userId: userId);
      return reviews.isNotEmpty ? reviews.first : null;
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá của user: $e');
    }
  }

  @override
  Stream<ReviewModel?> watchReview(String reviewId) {
    return firestore
        .collection(_reviewsCollection)
        .doc(reviewId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return ReviewModel.fromFirestore(snapshot);
        });
  }

  @override
  Stream<List<ReviewModel>> watchReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
  }) {
    try {
      Query query = firestore
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      // Fallback: Load without status filter if index is not ready
      Query query = firestore
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        List<ReviewModel> reviews = snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList();

        if (status != null) {
          reviews = reviews.where((review) => review.status == status).toList();
        }

        return reviews;
      });
    }
  }

  @override
  Stream<List<ReviewModel>> watchUserReviews(String userId) {
    return firestore
        .collection(_reviewsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<ReviewModel>> watchPendingReviews() {
    return firestore
        .collection(_reviewsCollection)
        .where('status', isEqualTo: ReviewStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromFirestore(doc))
              .toList();
        });
  }
}
