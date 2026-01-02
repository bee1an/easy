import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Calligraphy Text with Stroke Animation
/// Simulates handwriting effect with gradient reveal
class CalligraphyText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Duration duration;
  final Duration startDelay;

  const CalligraphyText({
    super.key,
    required this.text,
    this.fontSize = 28,
    this.duration = const Duration(milliseconds: 800),
    this.startDelay = const Duration(milliseconds: 200),
  });

  @override
  State<CalligraphyText> createState() => _CalligraphyTextState();
}

class _CalligraphyTextState extends State<CalligraphyText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _strokeAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Stroke animation - reveals text from left to right
    _strokeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.85, curve: Curves.easeInOut),
      ),
    );

    // Subtle fade in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    Future.delayed(widget.startDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.reset();
        _controller.forward();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _strokeAnimation.value;
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: ShaderMask(
              shaderCallback: (bounds) {
                // Gradient colors that will be revealed
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Color(0xFF10B981), // Emerald
                    Color(0xFF06B6D4), // Cyan
                    Color(0xFF6366F1), // Indigo
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.01, 1.0),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Text(
          widget.text,
          style: GoogleFonts.zhiMangXing(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w400,
            letterSpacing: 4,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// Alternative: Character by character reveal with calligraphy font
class CalligraphyCharByChar extends StatefulWidget {
  final String text;
  final double fontSize;
  final Duration charDuration;
  final Duration startDelay;

  const CalligraphyCharByChar({
    super.key,
    required this.text,
    this.fontSize = 28,
    this.charDuration = const Duration(milliseconds: 400),
    this.startDelay = const Duration(milliseconds: 300),
  });

  @override
  State<CalligraphyCharByChar> createState() => _CalligraphyCharByCharState();
}

class _CalligraphyCharByCharState extends State<CalligraphyCharByChar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimation();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.text.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      );
    }).toList();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(widget.startDelay);
    if (!mounted) return;

    setState(() => _started = true);

    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) return;
      _controllers[i].forward();
      await Future.delayed(widget.charDuration);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return SizedBox(height: widget.fontSize * 1.3);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.text.length, (index) {
        final char = widget.text[index];

        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: Opacity(
                opacity: _fadeAnimations[index].value.clamp(0.0, 1.0),
                child: Text(
                  char,
                  style: GoogleFonts.maShanZheng(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
