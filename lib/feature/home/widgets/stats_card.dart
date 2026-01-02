import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/core/theme/app_theme.dart';

/// Stats Card - Compact Statistics Display
class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PoopProvider>(
      builder: (context, provider, child) {
        final streak = provider.getStreak();
        final monthCount = provider.getMonthCount();
        final todayCount = provider.getTodayCount();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: streak,
                  label: '连续天数',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppTheme.accent,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppTheme.dividerColor(context),
              ),
              Expanded(
                child: _StatItem(
                  value: todayCount,
                  label: '今日',
                  icon: Icons.today_rounded,
                  iconColor: AppTheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppTheme.dividerColor(context),
              ),
              Expanded(
                child: _StatItem(
                  value: monthCount,
                  label: '本月',
                  icon: Icons.calendar_month_rounded,
                  iconColor: AppTheme.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
