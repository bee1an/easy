import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/provider/theme_provider.dart';
import 'package:easy/provider/auth_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:easy/core/router/deep_link_handler.dart';
import 'package:easy/feature/auth/auth_page.dart';
import 'package:easy/feature/home/home_page.dart';
import 'package:easy/service/notification_service.dart';
import 'package:easy/service/cloud_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');

  // Initialize notifications
  await NotificationService().init();

  // Initialize cloud sync service
  await CloudSyncService.instance.initialize();

  // Initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.initialize();

  // Load data in background
  final poopProvider = PoopProvider();
  poopProvider.loadRecords();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: poopProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TimerProvider(context.read<PoopProvider>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return DeepLinkHandler(
            child: MaterialApp(
              title: 'Easy',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.build(),
              darkTheme: AppTheme.buildDark(),
              themeMode: themeProvider.mode,
              // Use home widget directly to force login check
              home: const _AuthGate(),
              onGenerateRoute: AppRouter.onGenerateRoute,
            ),
          );
        },
      ),
    );
  }
}

/// Gate widget that shows login page or home page based on auth state
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show login page if not logged in
        if (!authProvider.isLoggedIn) {
          return const AuthPage(isInitialLogin: true);
        }
        // Show home page if logged in
        return const HomePage();
      },
    );
  }
}
