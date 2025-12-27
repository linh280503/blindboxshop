import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../review/presentation/widgets/review_widget.dart';

class ProductReviews extends ConsumerStatefulWidget {
  final String productId;
  final double rating;
  final int reviewCount;

  const ProductReviews({
    super.key,
    required this.productId,
    required this.rating,
    required this.reviewCount,
  });

  @override
  ConsumerState<ProductReviews> createState() => _ProductReviewsState();
}

class _ProductReviewsState extends ConsumerState<ProductReviews> {
  String _sortBy = 'newest';
  int _limit = 10;

  @override
  Widget build(BuildContext context) {
    // Use StateNotifierProvider (same as dialog) for consistency
    final reviews = ref.watch(productReviewsProvider(widget.productId));
    final reviewStatsAsync = ref.watch(
      reviewStatsFutureProvider(widget.productId),
    );
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.uid;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.warning, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Đánh giá sản phẩm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      underline: const SizedBox.shrink(),
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Mới nhất'),
                        ),
                        DropdownMenuItem(
                          value: 'highest_rating',
                          child: Text('Đánh giá cao'),
                        ),
                        DropdownMenuItem(
                          value: 'lowest_rating',
                          child: Text('Đánh giá thấp'),
                        ),
                        DropdownMenuItem(
                          value: 'most_helpful',
                          child: Text('Hữu ích'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _sortBy = v);
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    onPressed: () {
                      _showAllReviewsDialog(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Rating Summary
          reviewStatsAsync.when(
            data: (stats) => _buildRatingSummary(context, stats),
            loading: () => _buildRatingSummary(context, {
              'averageRating': widget.rating,
              'totalReviews': widget.reviewCount,
            }),
            error: (error, stack) => _buildRatingSummary(context, {
              'averageRating': widget.rating,
              'totalReviews': widget.reviewCount,
            }),
          ),

          SizedBox(height: 20.h),

          // Reviews List (from StateNotifierProvider)
          if (reviews.isEmpty)
            Column(
              children: [
                Icon(
                  Icons.rate_review,
                  size: 48.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Chưa có đánh giá nào',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            )
          else
            Column(
              children: [
                ...reviews
                    .take(3)
                    .map(
                      (review) => ReviewWidget(
                        review: review,
                        currentUserId: currentUserId,
                        onMarkHelpful: currentUserId == null
                            ? null
                            : () => ref
                                  .read(
                                    productReviewsProvider(
                                      widget.productId,
                                    ).notifier,
                                  )
                                  .markHelpful(review.id, currentUserId),
                        onUnmarkHelpful: currentUserId == null
                            ? null
                            : () => ref
                                  .read(
                                    productReviewsProvider(
                                      widget.productId,
                                    ).notifier,
                                  )
                                  .unmarkHelpful(review.id, currentUserId),
                      ),
                    ),
                SizedBox(height: 16.h),
                if (reviews.length > 3)
                  Center(
                    child: TextButton(
                      onPressed: () => _showAllReviewsDialog(context),
                      child: Text(
                        'Xem tất cả ${reviews.length} đánh giá',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
              ],
            ),

          // Write Review Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showWriteReviewDialog(context, ref);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: AppColors.primary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Viết đánh giá',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context, Map<String, dynamic> stats) {
    final averageRating = stats['averageRating'] as double? ?? 0.0;
    final totalReviews = stats['totalReviews'] as int? ?? 0;

    return Row(
      children: [
        Text(
          averageRating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < averageRating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: AppColors.warning,
                  size: 16.sp,
                );
              }),
            ),
            SizedBox(height: 4.h),
            Text(
              '$totalReviews đánh giá',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  void _showAllReviewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final scrollController = ScrollController();
        int dialogLimit = ref
            .read(productReviewsProvider(widget.productId))
            .length;
        bool isLoadingMore = false;

        return StatefulBuilder(
          builder: (context, setState) {
            // attach listener each build guarded by a simple flag
            // ignore: invalid_use_of_protected_member
            if (scrollController.positions.isEmpty) {
              scrollController.addListener(() async {
                if (scrollController.position.pixels >=
                        scrollController.position.maxScrollExtent - 120 &&
                    !isLoadingMore) {
                  setState(() => isLoadingMore = true);
                  dialogLimit += 10;
                  await ref
                      .read(productReviewsProvider(widget.productId).notifier)
                      .loadReviews(sortBy: _sortBy, limit: dialogLimit);
                  if (mounted) setState(() => isLoadingMore = false);
                }
              });
            }

            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 24.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 600.w, maxHeight: 0.8.sh),
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tất cả đánh giá',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Divider(color: Colors.grey[200], height: 1),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final allReviews = ref.watch(
                            productReviewsProvider(widget.productId),
                          );
                          final currentUserId = ref
                              .watch(authProvider)
                              .user
                              ?.uid;
                          if (allReviews.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.rate_review_outlined,
                                    size: 48.sp,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Chưa có đánh giá nào',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.separated(
                            controller: scrollController,
                            itemCount:
                                allReviews.length + (isLoadingMore ? 1 : 0),
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.grey[100], height: 32.h),
                            itemBuilder: (context, index) {
                              if (index >= allReviews.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final review = allReviews[index];
                              return ReviewWidget(
                                review: review,
                                currentUserId: currentUserId,
                                onMarkHelpful: currentUserId == null
                                    ? null
                                    : () => ref
                                          .read(
                                            productReviewsProvider(
                                              widget.productId,
                                            ).notifier,
                                          )
                                          .markHelpful(
                                            review.id,
                                            currentUserId,
                                          ),
                                onUnmarkHelpful: currentUserId == null
                                    ? null
                                    : () => ref
                                          .read(
                                            productReviewsProvider(
                                              widget.productId,
                                            ).notifier,
                                          )
                                          .unmarkHelpful(
                                            review.id,
                                            currentUserId,
                                          ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWriteReviewDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 600.w, maxHeight: 0.9.sh),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Viết đánh giá',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.grey[400],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey[200], height: 1),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  child: ReviewFormWidget(
                    productId: widget.productId,
                    userId: ref.read(authProvider).user?.uid ?? '',
                    userName: ref.read(authProvider).user?.name ?? 'Người dùng',
                    userAvatar: ref.read(authProvider).user?.avatar ?? '',
                    onSubmitted: () {
                      Navigator.pop(context);
                      ref.invalidate(productReviewsProvider(widget.productId));
                      ref.invalidate(reviewStatsProvider(widget.productId));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
