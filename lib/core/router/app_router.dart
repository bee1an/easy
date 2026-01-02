import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy/feature/home/home_page.dart';
import 'package:easy/feature/history/history_page.dart';
import 'package:easy/feature/settings/settings_page.dart';
import 'package:easy/feature/splash/splash_screen.dart';

/// App Router Configuration
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const SplashScreen(child: HomePage()), isRoot: true);
      case history:
        return _buildRoute(const HistoryPage());
      case AppRouter.settings:
        return _buildRoute(const SettingsPage());
      default:
        return _buildRoute(const HomePage());
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
  static Future<T?> push<T>(BuildContext context, String routeName) {
    return Navigator.of(context).pushNamed<T>(routeName);
  }

  /// Pop current route
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}
