import 'package:flutter/cupertino.dart';
import 'package:easy/feature/shell/main_shell.dart';
import 'package:easy/feature/splash/splash_screen.dart';
import 'package:easy/feature/auth/auth_page.dart';
import 'package:easy/feature/auth/forgot_password_page.dart';
import 'package:easy/feature/stats/stats_page.dart';
import 'package:easy/feature/settings/settings_page.dart';
import 'package:easy/feature/poop/poop_detail_page.dart';
import 'package:easy/feature/follow/follow_friends_page.dart';

/// App Router Configuration
///
/// Routes:
/// - /: Main shell with bottom navigation (Home, Profile)
/// - /poop: Poop module detail page
/// - /stats: Statistics page
/// - /settings: Settings page
/// - /auth: Authentication page
/// - /forgot-password: Forgot password page
/// - /follow: Follow friends page
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String poop = '/poop';
  static const String stats = '/stats';
  static const String settings = '/settings';
  static const String auth = '/auth';
  static const String forgotPassword = '/forgot-password';
  static const String follow = '/follow';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return _buildRoute(
          const SplashScreen(child: MainShell()),
          isRoot: true,
        );
      case poop:
        return _buildRoute(const PoopDetailPage());
      case stats:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          StatsPage(
            userId: args?['userId'] as String?,
            userDisplayName: args?['userDisplayName'] as String?,
          ),
        );
      case settings:
        return _buildRoute(const SettingsPage());
      case auth:
        return _buildRoute(const AuthPage());
      case forgotPassword:
        return _buildRoute(const ForgotPasswordPage());
      case follow:
        return _buildRoute(const FollowFriendsPage());
      default:
        return _buildRoute(const MainShell());
    }
  }

  static Route<dynamic> _buildRoute(Widget page, {bool isRoot = false}) {
    if (isRoot) {
      // No swipe back for root page
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
        transitionDuration: Duration.zero,
      );
    }

    // Use CupertinoPageRoute for swipe-back gesture support
    return CupertinoPageRoute(builder: (context) => page);
  }

  /// Navigate to a named route
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Pop current route
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}
