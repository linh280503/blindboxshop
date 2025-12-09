import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final authNotifier = container.read(authProvider.notifier);
      final success = await authNotifier.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        final authState = container.read(authProvider);
        final role = authState.user?.role ?? 'customer';
        if (role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      } else {
        // Check if error is due to unverified email
        final authState = container.read(authProvider);
        if (authState.error != null &&
            authState.error!.contains('Email chưa được xác thực')) {
          _showUnverifiedEmailDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error ?? 'Đăng nhập thất bại'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final authState = ProviderScope.containerOf(
          context,
          listen: false,
        ).read(authProvider);
        final errorMessage = authState.error ?? 'Đăng nhập thất bại';

        if (errorMessage.contains('Email chưa được xác thực')) {
          _showUnverifiedEmailDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUnverifiedEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Email chưa được xác thực'),
        content: Text(
          'Vui lòng kiểm tra hộp thư đến và xác thực email của bạn trước khi đăng nhập.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Đóng'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final container = ProviderScope.containerOf(
                context,
                listen: false,
              );
              final authNotifier = container.read(authProvider.notifier);
              await authNotifier.resendVerificationEmail(
                _emailController.text.trim(),
                _passwordController.text,
              );
            },
            child: Text('Gửi lại email'),
          ),
        ],
      ),
    );
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
          'Đăng nhập',
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

                // Logo và Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 40.sp,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Đăng nhập để tiếp tục',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
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

                SizedBox(height: 8.h),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.go('/forgot-password');
                    },
                    child: Text(
                      'Quên mật khẩu?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Login Button
                AuthButton(
                  text: 'Đăng nhập',
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),

                SizedBox(height: 24.h),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.lightGrey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'hoặc',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.lightGrey)),
                  ],
                ),

                SizedBox(height: 24.h),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      child: Text(
                        'Đăng ký ngay',
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
