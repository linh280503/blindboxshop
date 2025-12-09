import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Đăng ký trực tiếp
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Đăng ký thành công!'),
            content: Text(
              'Tài khoản của bạn đã được tạo. Vui lòng kiểm tra email để xác thực trước khi đăng nhập.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/login');
                },
                child: Text('Đăng nhập ngay'),
              ),
            ],
          ),
        );
      } else {
        final authState = ref.read(authProvider);
        if (mounted && authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: Text(
          'Đăng ký',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),

                // Title
                Text(
                  'Tạo tài khoản mới',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Điền thông tin để tạo tài khoản',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 32.h),

                // Full Name Field
                AuthTextField(
                  controller: _fullNameController,
                  label: 'Họ và tên',
                  hint: 'Nhập họ và tên của bạn',
                  prefixIcon: Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    if (value.length < 2) {
                      return 'Họ và tên phải có ít nhất 2 ký tự';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

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

                SizedBox(height: 16.h),

                // Phone Field
                AuthTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  hint: 'Nhập số điện thoại của bạn',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Password Field
                AuthTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  hint: 'Nhập mật khẩu của bạn',
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < AppConstants.minPasswordLength) {
                      return 'Mật khẩu phải có ít nhất ${AppConstants.minPasswordLength} ký tự';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Confirm Password Field
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu',
                  hint: 'Nhập lại mật khẩu',
                  obscureText: !_isConfirmPasswordVisible,
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Terms Agreement
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                            children: [
                              const TextSpan(text: 'Tôi đồng ý với '),
                              TextSpan(
                                text: 'Điều khoản sử dụng',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' và '),
                              TextSpan(
                                text: 'Chính sách bảo mật',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // Register Button
                AuthButton(
                  text: 'Đăng ký',
                  onPressed: _isLoading ? null : _handleRegister,
                  isLoading: _isLoading,
                ),

                SizedBox(height: 24.h),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã có tài khoản? ',
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
