import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy/core/theme/app_theme.dart';

/// Glassmorphism Card - A semi-transparent card with blur effect
///
/// Provides a premium glass-like appearance with:
/// - Semi-transparent background
/// - Backdrop blur effect
/// - Soft shadow
/// - Rounded corners
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final VoidCallback? onTap;
  final bool enableShadow;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.blurSigma = 10.0,
    this.backgroundColor,
    this.backgroundOpacity = 0.7,
    this.onTap,
    this.enableShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    // Base colors for glassmorphism effect
    final baseColor =
        backgroundColor ?? (isDark ? AppTheme.darkCard : AppTheme.card);
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.white.withAlpha(80);

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: baseColor.withAlpha((255 * backgroundOpacity).round()),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: enableShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 30 : 10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}

/// Glassmorphism Button - A premium button with glass effect
class GlassmorphismButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final bool isLoading;
  final bool enabled;

  const GlassmorphismButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.gradient,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  State<GlassmorphismButton> createState() => _GlassmorphismButtonState();
}

class _GlassmorphismButtonState extends State<GlassmorphismButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.isLoading) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = (AppTheme.primary.b * 255.0).round() & 0xff;
    final effectiveGradient =
        widget.gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            Color.fromARGB(
              255,
              (AppTheme.primary.r * 255.0).round() & 0xff,
              (AppTheme.primary.g * 255.0).round() & 0xff,
              (primaryBlue + 30).clamp(0, 255),
            ),
          ],
        );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled && !widget.isLoading ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: widget.enabled ? 1.0 : 0.5,
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  gradient: widget.backgroundColor != null
                      ? null
                      : effectiveGradient,
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(_isPressed ? 60 : 40),
                      blurRadius: _isPressed ? 12 : 16,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ],
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Spring animation curve for micro-interactions
class SpringCurve extends Curve {
  final double damping;
  final double stiffness;

  const SpringCurve({this.damping = 20.0, this.stiffness = 180.0});

  @override
  double transformInternal(double t) {
    // Simple approximation of spring dynamics
    final omega = (stiffness / damping);
    return 1 - (1 - t) * (2.71828 * t * omega).clamp(0.0, 1.0);
  }
}
