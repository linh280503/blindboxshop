import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/banner_model.dart';
import '../providers/banner_provider.dart';

class AdminBannerDialog extends ConsumerStatefulWidget {
  final BannerModel? banner;
  // We need to pass the provider to invalidate it, or we can just use the one from the page if we can access it.
  // Since the provider is static in the page state, we might need to expose it or just pass a callback.
  // However, looking at the original code, it invalidates `_BannerManagementPageState.allBannersProvider`.
  // To keep it clean, we'll just use the repository/notifier to update, and let the parent handle refresh if needed,
  // or we can invalidate the general provider if it's global.
  // Actually, the provider is `_BannerManagementPageState.allBannersProvider` which is private to the file.
  // I will need to make it public or move it to a shared location.
  // For now, I will assume I can invalidate the repository or just return true on success.

  const AdminBannerDialog({super.key, this.banner});

  @override
  ConsumerState<AdminBannerDialog> createState() => _AdminBannerDialogState();
}

class _AdminBannerDialogState extends ConsumerState<AdminBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _imageController = TextEditingController();
  final _linkValueController = TextEditingController();
  String _linkType = 'product';

  // For image preview
  String _previewImage = '';

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      _titleController.text = widget.banner!.title;
      _subtitleController.text = widget.banner!.subtitle;
      _imageController.text = widget.banner!.image;
      _linkType = widget.banner!.linkType ?? 'product';
      _linkValueController.text = widget.banner!.linkValue ?? '';
      _previewImage = widget.banner!.image;
    }
    _imageController.addListener(() {
      setState(() {
        _previewImage = _imageController.text;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageController.dispose();
    _linkValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: Colors.white,
      child: Container(
        width: 600.w,
        constraints: BoxConstraints(maxWidth: 600.w, maxHeight: 0.85.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePreview(),
                      SizedBox(height: 24.h),
                      _buildSectionTitle('Thông tin Banner'),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Tiêu đề',
                        icon: Icons.title,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Vui lòng nhập tiêu đề' : null,
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _subtitleController,
                        label: 'Mô tả',
                        icon: Icons.description_outlined,
                        maxLines: 2,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Vui lòng nhập mô tả' : null,
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _imageController,
                        label: 'URL hình ảnh',
                        icon: Icons.image_outlined,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Vui lòng nhập URL' : null,
                      ),
                      SizedBox(height: 24.h),
                      _buildSectionTitle('Liên kết'),
                      SizedBox(height: 12.h),
                      _buildDropdown(),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _linkValueController,
                        label: _linkType == 'external'
                            ? 'Đường dẫn (URL)'
                            : 'ID tham chiếu',
                        icon: _linkType == 'external' ? Icons.link : Icons.tag,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Vui lòng nhập giá trị' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.banner == null ? 'Thêm Banner' : 'Chỉnh sửa Banner',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 150.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: _previewImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                _previewImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: Colors.grey[400],
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Không thể tải ảnh',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: Colors.grey[400],
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Xem trước hình ảnh',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _linkType,
      decoration: InputDecoration(
        labelText: 'Loại liên kết',
        prefixIcon: Icon(
          Icons.category_outlined,
          color: Colors.grey[500],
          size: 20.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [
        DropdownMenuItem(value: 'product', child: Text('Sản phẩm')),
        DropdownMenuItem(value: 'category', child: Text('Danh mục')),
        DropdownMenuItem(value: 'external', child: Text('Liên kết ngoài')),
      ],
      onChanged: (value) {
        setState(() {
          _linkType = value!;
        });
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveBanner,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.banner == null ? 'Thêm' : 'Cập nhật',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBanner() async {
    if (_formKey.currentState!.validate()) {
      final banner = BannerModel(
        id: widget.banner?.id ?? '',
        title: _titleController.text,
        subtitle: _subtitleController.text,
        image: _imageController.text,
        linkType: _linkType,
        linkValue: _linkValueController.text,
        isActive: widget.banner?.isActive ?? true,
        order: widget.banner?.order ?? 0,
        createdAt: widget.banner?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        if (widget.banner == null) {
          await ref.read(bannerNotifierProvider.notifier).addBanner(banner);
        } else {
          await ref.read(bannerNotifierProvider.notifier).updateBanner(banner);
        }

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        // Handle error if needed, though notifier might handle it
      }
    }
  }
}
