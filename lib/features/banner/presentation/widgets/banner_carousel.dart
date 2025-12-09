import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/banner_provider.dart';

class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  void _onBannerTap(String? linkType, String? linkValue) {
    if (linkType == null || linkValue == null) return;

    switch (linkType) {
      case 'product':
        context.go('/product/$linkValue');
        break;
      case 'category':
        context.go('/products?category=${Uri.encodeComponent(linkValue)}');
        break;
      case 'external':
        break;
    }
  }

  ImageProvider _getBannerImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else {
      throw Exception('Invalid image URL: $imageUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(activeBannersProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            height: 200.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'Không có banner nào',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
            ),
          );
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: banners.length,
                itemBuilder: (context, index, realIndex) {
                  final banner = banners[index];
                  return GestureDetector(
                    onTap: () =>
                        _onBannerTap(banner.linkType, banner.linkValue),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          image: _getBannerImage(banner.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Content
                            Positioned(
                              left: 20.w,
                              bottom: 20.h,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banner.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    banner.subtitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 200.h,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: banners.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _carouselController.animateToPage(entry.key),
                    child: Container(
                      width: _currentIndex == entry.key ? 24.w : 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: _currentIndex == entry.key
                            ? AppColors.primary
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'Lỗi tải banner: $error',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}
