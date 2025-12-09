import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/review_model.dart';
import '../providers/review_provider.dart';
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
                          Flexible(
                            child: Text(
                              review.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating
        Center(
          child: Column(
            children: [
              Text(
                'Đánh giá',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => formNotifier.updateRating(index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < formState.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Comment
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            onChanged: formNotifier.updateComment,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Images
        if (formState.images.isNotEmpty) ...[
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
                          onTap: () =>
                              formNotifier.removeImage(formState.images[index]),
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
        SizedBox(
          width:
              double.infinity, // Make button full width if desired, or wrapped
          child: ElevatedButton.icon(
            onPressed: () async {
              final picker = ImagePicker();
              final images = await picker.pickMultiImage(imageQuality: 85);
              if (images.isEmpty) return;

              try {
                final urls = <String>[];
                for (final file in images) {
                  final url = await UploadService.uploadReviewImage(
                    file: file,
                    userId: userId,
                  );
                  urls.add(url);
                }
                formNotifier.addImages(urls);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh: $e')));
              }
            },
            icon: const Icon(Icons.add_photo_alternate, size: 20),
            label: const Text('Thêm hình ảnh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF6C63FF,
              ), // Purple color from design
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Error message
        if (formState.error != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 16),
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
                          content: Text('Đánh giá đã được gửi thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF6C63FF,
              ), // Purple color from design
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: formState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Gửi đánh giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
