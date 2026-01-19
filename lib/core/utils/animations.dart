import 'dart:math';
import 'package:flutter/material.dart';

/// Animation utilities and curves for micro-interactions
///
/// Provides spring curves and animation helpers for:
/// - Button press feedback
/// - Card hover effects
/// - Dialog transitions
/// - Page transitions

/// Enhanced spring curve with configurable parameters
class SpringCurve extends Curve {
  final double damping;
  final double stiffness;
  final double mass;

  const SpringCurve({
    this.damping = 20.0,
    this.stiffness = 180.0,
    this.mass = 1.0,
  });

  @override
  double transformInternal(double t) {
    // Damped harmonic oscillator approximation
    final omega = sqrt(stiffness / mass);
    final zeta = damping / (2 * sqrt(stiffness * mass));

    if (zeta < 1) {
      // Underdamped (oscillates)
      final omegaD = omega * sqrt(1 - zeta * zeta);
      return 1 - exp(-zeta * omega * t) * cos(omegaD * t);
    } else {
      // Critically damped or overdamped
      return 1 - (1 + omega * t) * exp(-omega * t);
    }
  }

  /// Preset: Gentle bounce for buttons
  static const gentle = SpringCurve(damping: 15, stiffness: 150);

  /// Preset: Snappy for quick interactions
  static const snappy = SpringCurve(damping: 25, stiffness: 300);

  /// Preset: Bouncy for playful elements
  static const bouncy = SpringCurve(damping: 10, stiffness: 200);
}

/// Slide-up animation for dialogs and bottom sheets
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlideUpRoute({required this.child})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: SpringCurve.gentle,
            reverseCurve: Curves.easeInCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.6),
                ),
              ),
              child: child,
            ),
          );
        },
      );
}

/// Scale animation for dialog appearance
class ScaleDialogRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  ScaleDialogRoute({required this.child})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: SpringCurve.snappy,
            reverseCurve: Curves.easeInCubic,
          );

          return ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      );
}

/// Mixin for adding press animation to widgets
mixin PressAnimationMixin<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;
  bool get isPressed => _isPressed;

  @protected
  void initPressAnimation({
    double scaleDown = 0.96,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    _pressController = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1.0, end: scaleDown).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @protected
  void disposePressAnimation() {
    _pressController.dispose();
  }

  Animation<double> get scaleAnimation => _scaleAnimation;

  void handlePressDown() {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void handlePressUp() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void handlePressCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }
}

/// Animated card wrapper with hover/press effects
class AnimatedPressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  final BorderRadius? borderRadius;

  const AnimatedPressCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.98,
    this.duration = const Duration(milliseconds: 100),
    this.borderRadius,
  });

  @override
  State<AnimatedPressCard> createState() => _AnimatedPressCardState();
}

class _AnimatedPressCardState extends State<AnimatedPressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: widget.child,
      ),
    );
  }
}

/// Staggered animation helper for list items
class StaggeredListAnimation {
  final int itemCount;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;

  const StaggeredListAnimation({
    required this.itemCount,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  /// Get the animation for a specific index
  Animation<double> getAnimation(AnimationController controller, int index) {
    final startDelay = staggerDelay.inMilliseconds * index;
    final totalDuration =
        staggerDelay.inMilliseconds * (itemCount - 1) +
        itemDuration.inMilliseconds;

    final start = startDelay / totalDuration;
    final end = (startDelay + itemDuration.inMilliseconds) / totalDuration;

    return CurvedAnimation(
      parent: controller,
      curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: curve),
    );
  }
}

/// Shimmer effect for loading states
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        widget.baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor =
        widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
