import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../order/data/di/order_providers.dart';

final isFirstOrderProvider = FutureProvider.family<bool, String>((
  ref,
  userId,
) async {
  final orderRepo = ref.watch(orderRepositoryProvider);
  final stats = await orderRepo.getUserOrderStats(userId);
  return stats['isFirstOrder'] as bool? ?? true;
});

class FirstOrderDiscountBanner extends ConsumerWidget {
  final VoidCallback? onApplyDiscount;

  const FirstOrderDiscountBanner({super.key, this.onApplyDiscount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final uid = auth.user?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    final isFirstOrderAsync = ref.watch(isFirstOrderProvider(uid));

    return isFirstOrderAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (isFirstOrder) {
        if (!isFirstOrder) {
          return const SizedBox.shrink();
        }

        return _buildBanner(context);
      },
    );
  }

  Widget _buildBanner(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          builder: (context, opacity, _) {
            return Transform.scale(
              scale: scale,
              child: Opacity(opacity: opacity, child: child),
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: onApplyDiscount,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎉 Chào mừng bạn đến với Blind Box Shop!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Đây là đơn hàng đầu tiên của bạn. Sử dụng mã WELCOME10 để được giảm 10%!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
