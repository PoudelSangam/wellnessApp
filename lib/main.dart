import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/activity/providers/activity_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/stats/providers/stats_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(const FlutterSecureStorage()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ActivityProvider>(
          create: (_) => ActivityProvider(),
          update: (_, auth, previous) =>
              previous ?? ActivityProvider()..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(),
          update: (_, auth, previous) =>
              previous ?? ProfileProvider()..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (_) => DashboardProvider(),
          update: (_, auth, previous) =>
              previous ?? DashboardProvider()..updateAuth(auth),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Wellness App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router(authProvider),
          );
        },
      ),
    );
  }
}
