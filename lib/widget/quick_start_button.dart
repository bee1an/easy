import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/widget/record_form_dialog.dart';

/// 快速开始按钮 - Duolingo 3D 风格
class QuickStartButton extends StatefulWidget {
  const QuickStartButton({super.key});

  @override
  State<QuickStartButton> createState() => _QuickStartButtonState();
}

class _QuickStartButtonState extends State<QuickStartButton>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final isRunning = timerProvider.isRunning;
        final isPressed = _isPressed;

        return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
            _handleTap(context, timerProvider);
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 280,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isRunning
                        ? const Color(0xFFFF4B4B) // 停止红色
                        : const Color(0xFF58CC02), // 开始绿色
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      // 主阴影
                      BoxShadow(
                        color: isRunning
                            ? const Color(0xFFE00000)
                            : const Color(0xFF58A700),
                        offset: Offset(0, isPressed ? 2 : 4),
                        blurRadius: 0,
                      ),
                      // 顶部高光边框
                      BoxShadow(
                        color: isRunning
                            ? const Color(0xFFFF7B7B)
                            : const Color(0xFF89E219),
                        offset: const Offset(0, -2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isRunning
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isRunning ? '停止' : '开始记录',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (isRunning) ...[
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              timerProvider.elapsedText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, TimerProvider timerProvider) {
    if (timerProvider.isRunning) {
      timerProvider.stopTimer();
      _showRecordForm(context, timerProvider);
    } else {
      timerProvider.startTimer();
    }
  }

  void _showRecordForm(BuildContext context, TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (context) => RecordFormDialog(
        timerProvider: timerProvider,
      ),
    );
  }
}
