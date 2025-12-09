// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/banner_model.dart';
import '../../data/mappers/banner_mapper.dart';
import '../../data/di/banner_providers.dart';
import '../providers/banner_provider.dart';
import '../widgets/admin_banner_dialog.dart';

class BannerManagementPage extends ConsumerStatefulWidget {
  const BannerManagementPage({super.key});

  @override
  ConsumerState<BannerManagementPage> createState() =>
      _BannerManagementPageState();
}

class _BannerManagementPageState extends ConsumerState<BannerManagementPage> {
  static final allBannersProvider =
      FutureProvider.autoDispose<List<BannerModel>>((ref) async {
        final repo = ref.watch(bannerRepositoryProvider);
        final entities = await repo.getBanners(orderBy: 'order');
        return BannerMapper.toModelList(entities);
      });
  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(allBannersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Banner'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _showAddBannerDialog();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: bannersAsync.when(
        data: (banners) {
          if (banners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 64.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Chưa có banner nào',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Nhấn + để thêm banner mới',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _buildBannerCard(context, ref, banner);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                'Lỗi tải banner: $error',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBannerDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AdminBannerDialog(),
    );
    if (result == true) {
      ref.invalidate(allBannersProvider);
    }
  }

  // edit/delete handled inline in card to avoid overflow
}

Widget _buildBannerCard(
  BuildContext context,
  WidgetRef ref,
  BannerModel banner,
) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                banner.image,
                width: 84.w,
                height: 84.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 84.w,
                    height: 84.w,
                    color: AppColors.lightGrey,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image,
                      color: AppColors.textSecondary,
                      size: 28.sp,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              banner.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Actions stacked vertically to avoid overflow
                      Column(
                        children: [
                          Switch(
                            value: banner.isActive,
                            onChanged: (value) async {
                              await ref
                                  .read(bannerNotifierProvider.notifier)
                                  .updateBanner(
                                    banner.copyWith(
                                      isActive: value,
                                      updatedAt: DateTime.now(),
                                    ),
                                  );
                              ref.invalidate(
                                _BannerManagementPageState.allBannersProvider,
                              );
                            },
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AdminBannerDialog(banner: banner),
                                  );
                                  if (result == true) {
                                    ref.invalidate(
                                      _BannerManagementPageState
                                          .allBannersProvider,
                                    );
                                  }
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(24.w),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(16.w),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.delete_forever,
                                                size: 32.sp,
                                                color: Colors.red,
                                              ),
                                            ),
                                            SizedBox(height: 16.h),
                                            Text(
                                              'Xóa Banner',
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              'Bạn có chắc chắn muốn xóa banner "${banner.title}"?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 24.h),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 12.h,
                                                          ),
                                                      side: BorderSide(
                                                        color:
                                                            Colors.grey[300]!,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Hủy',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      await ref
                                                          .read(
                                                            bannerNotifierProvider
                                                                .notifier,
                                                          )
                                                          .deleteBanner(
                                                            banner.id,
                                                          );
                                                      ref.invalidate(
                                                        _BannerManagementPageState
                                                            .allBannersProvider,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 12.h,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Xóa',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
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
                                child: Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                  size: 18.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          '${banner.linkType}: ${banner.linkValue}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
