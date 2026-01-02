import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/feature/home/widgets/record_dialog.dart';

/// Quick Action Button - Floating Action Button
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final isRunning = timerProvider.isRunning;

        return GestureDetector(
          onTap: () => _handleTap(context, timerProvider),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isRunning ? 24 : 32),
            decoration: BoxDecoration(
              color: isRunning ? AppTheme.error : AppTheme.primary,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: (isRunning ? AppTheme.error : AppTheme.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRunning ? Icons.stop_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isRunning ? timerProvider.elapsedText : '记录',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, TimerProvider timerProvider) {
    if (timerProvider.isRunning) {
      timerProvider.stopTimer();
      showDialog(
        context: context,
        builder: (context) => RecordDialog(timerProvider: timerProvider),
      );
    } else {
      timerProvider.startTimer();
    }
  }
}
