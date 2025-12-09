import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_status.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final int rating; // 1-5 stars
  final String comment;
  final List<String> images;
  final ReviewStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final String? orderId;
  final int helpfulCount;
  final List<String> helpfulUsers;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.images,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.orderId,
    this.helpfulCount = 0,
    this.helpfulUsers = const [],
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      rating: data['rating'] ?? 5,
      comment: data['comment'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReviewStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      orderId: data['orderId'],
      helpfulCount: data['helpfulCount'] ?? 0,
      helpfulUsers: List<String>.from(data['helpfulUsers'] ?? []),
    );
  }

  factory ReviewModel.fromMap(Map<String, dynamic> data) {
    return ReviewModel(
      id: data['id'] ?? '',
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      rating: data['rating'] ?? 5,
      comment: data['comment'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReviewStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      orderId: data['orderId'],
      helpfulCount: data['helpfulCount'] ?? 0,
      helpfulUsers: List<String>.from(data['helpfulUsers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'images': images,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
      'orderId': orderId,
      'helpfulCount': helpfulCount,
      'helpfulUsers': helpfulUsers,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userAvatar,
    int? rating,
    String? comment,
    List<String>? images,
    ReviewStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? orderId,
    int? helpfulCount,
    List<String>? helpfulUsers,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      orderId: orderId ?? this.orderId,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
    );
  }

  // Helper methods
  bool get isApproved => status == ReviewStatus.approved;
  bool get isPending => status == ReviewStatus.pending;
  bool get isRejected => status == ReviewStatus.rejected;

  String get statusText {
    switch (status) {
      case ReviewStatus.pending:
        return 'Chờ duyệt';
      case ReviewStatus.approved:
        return 'Đã duyệt';
      case ReviewStatus.rejected:
        return 'Từ chối';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa rồi';
    }
  }

  // Rating stars helper
  List<bool> get starRatings {
    return List.generate(5, (index) => index < rating);
  }
}
