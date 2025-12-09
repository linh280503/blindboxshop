import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../review/data/models/review_model.dart';
import '../../../review/presentation/providers/review_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/upload_service.dart';

class ReviewWidget extends ConsumerWidget {
  final ReviewModel review;
  final String? currentUserId;
  final VoidCallback? onMarkHelpful;
  final VoidCallback? onUnmarkHelpful;

  const ReviewWidget({
    super.key,
    required this.review,
    this.currentUserId,
    this.onMarkHelpful,
    this.onUnmarkHelpful,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHelpful =
        currentUserId != null && review.helpfulUsers.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.userAvatar.isNotEmpty
                      ? CachedNetworkImageProvider(review.userAvatar)
                      : null,
                  child: review.userAvatar.isEmpty
                      ? Text(
                          review.userName.isNotEmpty
                              ? review.userName[0].toUpperCase()
                              : 'U',
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (review.isVerified) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Đã mua',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStarRating(review.rating),
                          const SizedBox(width: 8),
                          Text(
                            review.formattedDate,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Comment
            if (review.comment.isNotEmpty)
              Text(review.comment, style: const TextStyle(fontSize: 14)),

            // Images
            if (review.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: review.images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Helpful button
            if (currentUserId != null && currentUserId != review.userId)
              Row(
                children: [
                  GestureDetector(
                    onTap: isHelpful ? onUnmarkHelpful : onMarkHelpful,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isHelpful ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.thumb_up,
                            size: 16,
                            color: isHelpful ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hữu ích (${review.helpfulCount})',
                            style: TextStyle(
                              color: isHelpful
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}

class ReviewStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ReviewStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final averageRating = stats['averageRating'] as double? ?? 0.0;
    final totalReviews = stats['totalReviews'] as int? ?? 0;
    final ratingDistribution =
        stats['ratingDistribution'] as Map<int, int>? ?? {};

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đánh giá sản phẩm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Overall rating
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          _buildStarRating(averageRating.round()),
                          Text(
                            'Dựa trên $totalReviews đánh giá',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),

                      // Rating distribution
                      Expanded(
                        child: Column(
                          children: List.generate(5, (index) {
                            final rating = 5 - index;
                            final count = ratingDistribution[rating] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(
                                    '$rating',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: totalReviews > 0
                                          ? count / totalReviews
                                          : 0,
                                      backgroundColor: Colors.grey[300],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.amber,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$count',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}

class ReviewFormWidget extends ConsumerWidget {
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String? orderId;
  final VoidCallback? onSubmitted;

  const ReviewFormWidget({
    super.key,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.orderId,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(reviewFormProvider);
    final formNotifier = ref.read(reviewFormProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Viết đánh giá',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Rating
            Row(
              children: [
                const Text('Đánh giá: '),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => formNotifier.updateRating(index + 1),
                    child: Icon(
                      index < formState.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // Comment
            TextField(
              onChanged: formNotifier.updateComment,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Images
            if (formState.images.isNotEmpty) ...[
              const Text('Hình ảnh đánh giá:'),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: formState.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: formState.images[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => formNotifier.removeImage(
                                formState.images[index],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Add image button
            ElevatedButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                final images = await picker.pickMultiImage(imageQuality: 85);
                if (images.isEmpty) return;

                final notifier = ref.read(reviewFormProvider.notifier);
                try {
                  const userId = 'anonymous';
                  final urls = <String>[];
                  for (final file in images) {
                    final url = await UploadService.uploadReviewImage(
                      file: file,
                      userId: userId,
                    );
                    urls.add(url);
                  }
                  notifier.addImages(urls);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh: $e')));
                }
              },
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Thêm hình ảnh'),
            ),

            const SizedBox(height: 16),

            // Error message
            if (formState.error != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  formState.error!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),

            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: formState.isLoading
                    ? null
                    : () async {
                        await formNotifier.submitReview(
                          productId: productId,
                          userId: userId,
                          userName: userName,
                          userAvatar: userAvatar,
                          orderId: orderId,
                        );

                        if (formState.error == null) {
                          onSubmitted?.call();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đánh giá đã được gửi, chờ duyệt'),
                            ),
                          );
                        }
                      },
                child: formState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Gửi đánh giá'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
