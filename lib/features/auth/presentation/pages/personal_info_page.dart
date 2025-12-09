import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/auth_provider.dart';

class PersonalInfoPage extends ConsumerStatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      _nameController.text = authState.user!.name;
      _emailController.text = authState.user!.email;
      _phoneController.text = authState.user!.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần ảnh đại diện
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.person,
                            size: 60.sp,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              onPressed: () {
                                // Chức năng chọn ảnh
                                NotificationService.showInfo(
                                  'Tính năng đang được phát triển',
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Thay đổi ảnh đại diện',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Các trường form
              _buildTextField(
                controller: _nameController,
                label: 'Họ và tên',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại (tuỳ chọn)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // cho phép để trống
                  }
                  if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              SizedBox(height: 32.h),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Lưu thông tin',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      onTap: onTap,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);

      final success = await authNotifier.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (success) {
        if (mounted) {
          NotificationService.showSuccess('Lưu thông tin thành công!');
        }
      } else {
        if (mounted) {
          NotificationService.showError('Không thể lưu thông tin');
        }
      }
    }
  }
}
