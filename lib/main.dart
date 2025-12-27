import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/router/router_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe publishable key (test mode) - từ Stripe Dashboard
  Stripe.publishableKey = 'pk_test_51Sj0w27cZ62tbjde72kWtziqG9qoZLqIc1kNdkabPHQVxeZURwN90CauwgzbqmJme60tjGXp0vE0V4BB7VnEXEkR00JSwEZTGC';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
        );
      },
    );
  }
}
