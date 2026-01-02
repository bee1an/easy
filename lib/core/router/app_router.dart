import 'package:flutter/material.dart';
import 'package:easy/feature/home/home_page.dart';
import 'package:easy/feature/history/history_page.dart';
import 'package:easy/feature/settings/settings_page.dart';

/// App Router Configuration
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const HomePage());
      case history:
        return _buildRoute(const HistoryPage());
      case AppRouter.settings:
        return _buildRoute(const SettingsPage());
      default:
        return _buildRoute(const HomePage());
    }
  }

  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
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
