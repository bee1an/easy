import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/feature/home/widgets/record_dialog.dart';

/// Module type definition for extensibility
enum HealthModule {
  poop('排便', Icons.wb_sunny_outlined, Color(0xFFF59E0B)), // Amber - primary
  diet('饮食', Icons.restaurant_outlined, Color(0xFFEA580C)), // Orange Red
  exercise('运动', Icons.directions_run_outlined, Color(0xFFFB923C)); // Orange

  final String label;
  final IconData icon;
  final Color color;

  const HealthModule(this.label, this.icon, this.color);
}

/// Module Shortcuts - Quick entry buttons for each health module
class ModuleShortcuts extends StatelessWidget {
  const ModuleShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Poop module - active with timer
        const Expanded(child: _PoopModuleButton()),
        const SizedBox(width: 12),
        // Diet module - coming soon
        Expanded(child: _ComingSoonButton(module: HealthModule.diet)),
        const SizedBox(width: 12),
        // Exercise module - coming soon
        Expanded(child: _ComingSoonButton(module: HealthModule.exercise)),
      ],
    );
  }
}

/// Poop module button with timer functionality
class _PoopModuleButton extends StatefulWidget {
  const _PoopModuleButton();

  @override
  State<_PoopModuleButton> createState() => _PoopModuleButtonState();
}

class _PoopModuleButtonState extends State<_PoopModuleButton>
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
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    final timerProvider = context.read<TimerProvider>();

    if (timerProvider.isRunning) {
      // Stop timer and show record dialog
      showDialog(
        context: context,
        builder: (context) => RecordDialog(timerProvider: timerProvider),
      );
    } else {
      // Start timer
      timerProvider.startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final color = HealthModule.poop.color;

    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final isRunning = timerProvider.isRunning;

        return GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 100,
                  decoration: BoxDecoration(
                    color: isRunning
                        ? color.withValues(alpha: isDark ? 0.3 : 0.15)
                        : color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRunning
                          ? color.withValues(alpha: 0.5)
                          : color.withValues(alpha: 0.3),
                      width: isRunning ? 2 : 1,
                    ),
                    boxShadow: _isPressed
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isRunning) ...[
                        // Show timer when running
                        Text(
                          timerProvider.elapsedText,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '点击结束',
                          style: TextStyle(
                            fontSize: 12,
                            color: color.withValues(alpha: 0.8),
                          ),
                        ),
                      ] else ...[
                        // Show icon and label when idle
                        Icon(HealthModule.poop.icon, color: color, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          HealthModule.poop.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Coming soon button for inactive modules
class _ComingSoonButton extends StatelessWidget {
  final HealthModule module;

  const _ComingSoonButton({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.dividerColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(module.icon, color: AppTheme.textMutedColor(context), size: 28),
          const SizedBox(height: 8),
          Text(
            module.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMutedColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '即将推出',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
