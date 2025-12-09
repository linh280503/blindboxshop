import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final bool requireAuth;
  final bool requireAdmin;
  final String? redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAuth = false,
    this.requireAdmin = false,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check authentication requirement
    if (requireAuth && authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check admin requirement
    if (requireAdmin) {
      final role = authState.user?.role ?? 'customer';
      if (role != 'admin') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    if (authState.user != null &&
        (GoRouterState.of(context).uri.path == '/login' ||
            GoRouterState.of(context).uri.path == '/register')) {
      final role = authState.user?.role ?? 'customer';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(role == 'admin' ? '/admin' : '/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
