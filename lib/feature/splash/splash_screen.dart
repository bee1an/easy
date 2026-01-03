import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy/core/utils/greeting.dart';

/// Splash Screen with Greeting Animation
class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _splashController;
  late AnimationController _moveController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignmentAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeOutBgAnimation;

  bool _showHome = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();

    // Splash animation (fade in + scale)
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Move animation (center to top-left)
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _alignmentAnimation =
        AlignmentTween(
          begin: Alignment.center,
          end: const Alignment(-0.85, -0.75),
        ).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
        );

    _sizeAnimation = Tween<double>(begin: 42.0, end: 32.0).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );

    _fadeOutBgAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _moveController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    debugPrint('Splash: Animation started');
    // Start splash fade in
    _splashController.forward();

    // Wait for splash to complete
    await Future.delayed(const Duration(milliseconds: 1500));
    debugPrint('Splash: Showing home content');

    // Show home content behind
    if (mounted) setState(() => _showHome = true);

    // Start move animation
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _moveController.forward();

    // Wait for move to complete
    await Future.delayed(const Duration(milliseconds: 700));
    debugPrint('Splash: Animation complete');
    if (mounted) setState(() => _animationComplete = true);
  }

  @override
  void dispose() {
    _splashController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          // Home content (appears after splash)
          if (_showHome)
            Positioned.fill(
              child: Opacity(
                opacity: _animationComplete ? 1.0 : 0.0,
                child: widget.child,
              ),
            ),

          // Splash overlay
          if (!_animationComplete)
            AnimatedBuilder(
              animation: Listenable.merge([_splashController, _moveController]),
              builder: (context, child) {
                return Stack(
                  children: [
                    // Background
                    Positioned.fill(
                      child: Opacity(
                        opacity: _fadeOutBgAnimation.value,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),

                    // Animated greeting
                    Align(
                      alignment: _alignmentAnimation.value,
                      child: Opacity(
                        opacity: _fadeInAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _buildGreetingText(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGreetingText() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF10B981), Color(0xFF06B6D4), Color(0xFF6366F1)],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        getGreeting(),
        style: GoogleFonts.zhiMangXing(
          fontSize: _sizeAnimation.value,
          fontWeight: FontWeight.w400,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
