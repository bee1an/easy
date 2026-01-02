import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy/core/theme/app_theme.dart';

/// Global keys for animation coordination
class AnimationKeys {
  static final GlobalKey todayCalendarKey = GlobalKey();
  static final GlobalKey saveButtonKey = GlobalKey();
}

/// Star flying animation overlay
class StarFlyAnimation {
  static OverlayEntry? _overlayEntry;

  /// Trigger star animation from source to today's calendar cell
  static void trigger(BuildContext context) {
    // Get source position (save button)
    final sourceBox =
        AnimationKeys.saveButtonKey.currentContext?.findRenderObject()
            as RenderBox?;
    if (sourceBox == null) return;
    final sourcePos = sourceBox.localToGlobal(
      Offset(sourceBox.size.width / 2, sourceBox.size.height / 2),
    );

    // Get target position (today's calendar cell)
    final targetBox =
        AnimationKeys.todayCalendarKey.currentContext?.findRenderObject()
            as RenderBox?;
    if (targetBox == null) return;
    final targetPos = targetBox.localToGlobal(
      Offset(targetBox.size.width / 2, targetBox.size.height / 2),
    );

    // Create and show overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => _FlyingStar(
        startPosition: sourcePos,
        endPosition: targetPos,
        onComplete: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          // Trigger wave animation on calendar
          CalendarWaveAnimation.trigger();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}

/// Flying star widget
class _FlyingStar extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;

  const _FlyingStar({
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<_FlyingStar> createState() => _FlyingStarState();
}

class _FlyingStarState extends State<_FlyingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _progressAnimation.value;

        // Bezier curve path (arc upward)
        final controlPoint = Offset(
          (widget.startPosition.dx + widget.endPosition.dx) / 2,
          min(widget.startPosition.dy, widget.endPosition.dy) - 100,
        );

        final t = progress;
        final x =
            pow(1 - t, 2) * widget.startPosition.dx +
            2 * (1 - t) * t * controlPoint.dx +
            pow(t, 2) * widget.endPosition.dx;
        final y =
            pow(1 - t, 2) * widget.startPosition.dy +
            2 * (1 - t) * t * controlPoint.dy +
            pow(t, 2) * widget.endPosition.dy;

        return Positioned(
          left: x - 12,
          top: y - 12,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFFBBF24), // Amber
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Calendar wave animation state
class CalendarWaveAnimation extends ChangeNotifier {
  static final CalendarWaveAnimation _instance = CalendarWaveAnimation._();
  factory CalendarWaveAnimation() => _instance;
  CalendarWaveAnimation._();

  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;

  static void trigger() {
    _instance._isAnimating = true;
    _instance.notifyListeners();

    Future.delayed(const Duration(milliseconds: 600), () {
      _instance._isAnimating = false;
      _instance.notifyListeners();
    });
  }
}

/// Wave effect widget for calendar cell
class WaveEffect extends StatefulWidget {
  final Widget child;
  final bool animate;

  const WaveEffect({super.key, required this.child, required this.animate});

  @override
  State<WaveEffect> createState() => _WaveEffectState();
}

class _WaveEffectState extends State<WaveEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant WaveEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Wave ripple
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
            );
          },
        ),
        // Original child
        widget.child,
      ],
    );
  }
}
