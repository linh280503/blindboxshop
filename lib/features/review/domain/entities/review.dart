import 'review_status.dart';

class Review {
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

  const Review({
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

  // Business logic
  bool get isApproved => status == ReviewStatus.approved;
  bool get isPending => status == ReviewStatus.pending;
  bool get isRejected => status == ReviewStatus.rejected;

  Review copyWith({
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
    return Review(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
