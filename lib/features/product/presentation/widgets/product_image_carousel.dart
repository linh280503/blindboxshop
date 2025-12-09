import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final int selectedIndex;
  final Function(int) onImageSelected;

  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.onImageSelected,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      color: AppColors.white,
      child: Column(
        children: [
          // Main Image
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                widget.onImageSelected(index);
              },
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(20.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary,
                            size: 80.sp,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Thumbnail Images
          if (widget.images.length > 1)
            Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  final isSelected = widget.selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lightGrey,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.r),
                        child: Image.network(
                          widget.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceVariant,
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.textSecondary,
                                size: 20.sp,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Page Indicator
          if (widget.images.length > 1)
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  return Container(
                    width: widget.selectedIndex == entry.key ? 24.w : 8.w,
                    height: 8.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: widget.selectedIndex == entry.key
                          ? AppColors.primary
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
