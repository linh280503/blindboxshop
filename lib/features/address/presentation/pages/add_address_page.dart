import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/di/address_providers.dart';
import '../providers/address_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddAddressPage extends ConsumerStatefulWidget {
  final AddressModel? initialAddress;

  const AddAddressPage({super.key, this.initialAddress});

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize with existing address if editing
    if (widget.initialAddress != null) {
      final address = widget.initialAddress!;
      _nameController.text = address.name;
      _phoneController.text = address.phone;
      _addressController.text = address.address;
      _noteController.text = address.note ?? '';
      _cityController.text = address.city;
      _districtController.text = address.district;
      _wardController.text = address.ward;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(authProvider).user?.uid ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn cần đăng nhập để lưu địa chỉ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final now = DateTime.now();

    if (widget.initialAddress == null) {
      // Create new address
      final repo = ref.read(addressRepositoryProvider);
      final existingAddresses = await repo.getUserAddresses(uid);
      final shouldBeDefault = existingAddresses.isEmpty;

      final address = AddressModel(
        id: '',
        userId: uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        ward: _wardController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isDefault: shouldBeDefault,
        createdAt: now,
        updatedAt: now,
      );

      final success = await ref
          .read(addressProvider.notifier)
          .createAddress(address);

      if (success && mounted) {
        // Provider đã hiển thị thông báo thành công qua NotificationService
        context.pop();
      }
      // Nếu thất bại, provider đã hiển thị thông báo lỗi
    } else {
      // Update existing address
      final existing = widget.initialAddress!;
      final updated = existing.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        ward: _wardController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isDefault: existing.isDefault,
        updatedAt: now,
      );

      final success = await ref
          .read(addressProvider.notifier)
          .updateAddress(updated);

      if (success && mounted) {
        // Provider đã hiển thị thông báo thành công qua NotificationService
        context.pop();
      }
      // Nếu thất bại, provider đã hiển thị thông báo lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm địa chỉ',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    _buildSectionTitle('Họ và tên'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Nhập họ và tên',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Phone Field
                    _buildSectionTitle('Số điện thoại'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: _phoneController,
                      hintText: 'Nhập số điện thoại',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value.trim())) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // City Input
                    _buildSectionTitle('Tỉnh/Thành phố'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: _cityController,
                      hintText: 'Ví dụ: TP. Hồ Chí Minh',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập Tỉnh/Thành phố';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // District Input
                    _buildSectionTitle('Quận/Huyện'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: _districtController,
                      hintText: 'Ví dụ: Quận 1',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập Quận/Huyện';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Ward Input
                    _buildSectionTitle('Phường/Xã'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: _wardController,
                      hintText: 'Ví dụ: Phường Bến Nghé',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập Phường/Xã';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Address Field
                    _buildSectionTitle('Địa chỉ chi tiết'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: _addressController,
                      hintText: 'Số nhà, tên đường, tòa nhà...',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập địa chỉ chi tiết';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Note Field
                    _buildSectionTitle('Ghi chú (tùy chọn)'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: _noteController,
                      hintText: 'Hướng dẫn giao hàng...',
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Lưu địa chỉ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      style: TextStyle(fontSize: 14.sp),
    );
  }
}
