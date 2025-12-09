import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../data/di/auth_providers.dart';
import '../../../../core/services/notification_service.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Sử dụng AuthRepository thay vì UserService
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.sendPasswordResetEmail(_emailController.text.trim());

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Đã gửi email!'),
          content: Text(
            'Chúng tôi đã gửi một liên kết đặt lại mật khẩu đến email ${_emailController.text.trim()}. Vui lòng kiểm tra hộp thư của bạn.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              child: const Text('Đăng nhập ngay'),
            ),
          ],
        ),
      );
    } catch (e) {
      NotificationService.showError('Gửi yêu cầu thất bại: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),

                // Icon
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.lock_reset_outlined,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Title
                Text(
                  'Quên mật khẩu?',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                Text(
                  'Nhập email của bạn để nhận liên kết đặt lại mật khẩu',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 48.h),

                // Email Field
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Nhập email của bạn',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 32.h),

                // Send Button
                AuthButton(
                  text: 'Gửi liên kết',
                  onPressed: _isLoading ? null : _handleResetPassword,
                  isLoading: _isLoading,
                ),

                SizedBox(height: 24.h),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nhớ mật khẩu? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: Text(
                        'Đăng nhập ngay',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
