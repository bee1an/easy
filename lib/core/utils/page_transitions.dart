import 'package:flutter/material.dart';
import 'package:easy/core/utils/animations.dart';

/// Enhanced page transitions with smooth curves and Hero support
///
/// Provides:
/// - Slide transitions with spring curves
/// - Fade transitions for modal pages
/// - Hero animation support
/// - Shared element transitions

/// Slide from right page route with spring curve
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlidePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: SpringCurve.gentle,
            reverseCurve: Curves.easeInCubic,
          );

          final secondaryCurved = CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeInOut,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.3, 0.0),
              ).animate(secondaryCurved),
              child: child,
            ),
          );
        },
      );
}

/// Fade page route for modal-style pages
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
    : super(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(opacity: curvedAnimation, child: child);
        },
      );
}

/// Scale page route for dialog-like pages
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
    : super(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: SpringCurve.snappy,
            reverseCurve: Curves.easeInCubic,
          );

          return ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          );
        },
      );
}

/// Slide up page route for bottom sheet-like pages
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool fullscreen;

  SlideUpPageRoute({required this.page, this.fullscreen = true})
    : super(
        opaque: fullscreen,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: SpringCurve.gentle,
            reverseCurve: Curves.easeInCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
      );
}

/// Hero page route that enables hero animations between routes
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final String heroTag;

  HeroPageRoute({required this.page, required this.heroTag})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: SpringCurve.gentle,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5),
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      );
}

/// Hero widget wrapper for shared element transitions
class SharedElementHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool enabled;

  const SharedElementHero({
    super.key,
    required this.tag,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Hero(
      tag: tag,
      flightShuttleBuilder:
          (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: SpringCurve.gentle,
            );

            return AnimatedBuilder(
              animation: curvedAnimation,
              builder: (context, _) {
                return Material(
                  color: Colors.transparent,
                  child: toHeroContext.widget,
                );
              },
            );
          },
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

/// Extension for easy navigation with custom transitions
extension NavigatorExtensions on NavigatorState {
  /// Navigate with slide transition
  Future<T?> pushSlide<T>(Widget page) {
    return push<T>(SlidePageRoute(page: page));
  }

  /// Navigate with fade transition
  Future<T?> pushFade<T>(Widget page) {
    return push<T>(FadePageRoute(page: page));
  }

  /// Navigate with scale transition
  Future<T?> pushScale<T>(Widget page) {
    return push<T>(ScalePageRoute(page: page));
  }

  /// Navigate with slide up transition
  Future<T?> pushSlideUp<T>(Widget page, {bool fullscreen = true}) {
    return push<T>(SlideUpPageRoute(page: page, fullscreen: fullscreen));
  }

  /// Navigate with hero transition
  Future<T?> pushHero<T>(Widget page, String heroTag) {
    return push<T>(HeroPageRoute(page: page, heroTag: heroTag));
  }
}
