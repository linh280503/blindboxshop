import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../../../core/constants/app_colors.dart';

class ReviewPage extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final String productImage;

  const ReviewPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
  });

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isAnonymous = false;
  final List<String> _selectedTags = [];

  final List<String> _availableTags = [
    'Chất lượng tốt',
    'Đóng gói đẹp',
    'Giao hàng nhanh',
    'Giá hợp lý',
    'Sản phẩm đúng mô tả',
    'Dịch vụ tốt',
    'Sẽ mua lại',
    'Tuyệt vời',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Đánh giá sản phẩm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/orders');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            _buildProductInfo(),
            SizedBox(height: 24.h),
            // Rating section
            _buildRatingSection(),
            SizedBox(height: 24.h),
            // Review text
            _buildReviewTextSection(),
            SizedBox(height: 24.h),
            // Tags section
            _buildTagsSection(),
            SizedBox(height: 24.h),
            // Anonymous option
            _buildAnonymousOption(),
            SizedBox(height: 32.h),
            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: widget.productImage.isNotEmpty
                ? Image.network(
                    widget.productImage,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80.w,
                        height: 80.w,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 32.sp,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 80.w,
                    height: 80.w,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 32.sp,
                    ),
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Cảm ơn bạn đã mua sản phẩm! Hãy chia sẻ trải nghiệm của bạn.',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đánh giá của bạn',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32.sp,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 8.h),
              Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTextSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhận xét chi tiết',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _reviewController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Hãy chia sẻ trải nghiệm của bạn về sản phẩm...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${_reviewController.text.length}/500 ký tự',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thẻ đánh giá',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Text(
            'Chọn các thẻ phù hợp với trải nghiệm của bạn',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousOption() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _isAnonymous,
            onChanged: (value) {
              setState(() {
                _isAnonymous = value ?? false;
              });
            },
            activeColor: AppColors.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đánh giá ẩn danh',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Đánh giá của bạn sẽ được hiển thị mà không có tên người dùng',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Gửi đánh giá',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Tệ';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Tuyệt vời';
      default:
        return '';
    }
  }

  void _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập nhận xét'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16.w),
            Text('Đang gửi đánh giá...'),
          ],
        ),
      ),
    );

    try {
      final auth = ref.read(authProvider);
      final user = auth.user;
      if (user == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần đăng nhập để đánh giá'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userName = auth.user?.name ?? user.email;
      final userAvatar = auth.user?.avatar ?? '';

      // update form provider state
      ref.read(reviewFormProvider.notifier).updateRating(_rating);
      ref
          .read(reviewFormProvider.notifier)
          .updateComment(_reviewController.text);

      await ref
          .read(reviewFormProvider.notifier)
          .submitReview(
            productId: widget.productId,
            userId: user.uid,
            userName: _isAnonymous ? 'Ẩn danh' : userName,
            userAvatar: _isAnonymous ? '' : userAvatar,
            orderId: GoRouterState.of(context).uri.queryParameters['orderId'],
          );

      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close review page

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn đã đánh giá sản phẩm!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi đánh giá: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
