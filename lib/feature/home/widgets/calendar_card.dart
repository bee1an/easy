import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Calendar Card - Monthly Heatmap Calendar
class CalendarCard extends StatefulWidget {
  const CalendarCard({super.key});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1, 1))) {
      setState(() {
        _currentMonth = nextMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PoopProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<DateTime, int>>(
          future: provider.getDailyCounts(),
          builder: (context, snapshot) {
            final dailyCounts = snapshot.data ?? {};

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Calendar Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      // Month Navigation
                      _buildMonthNav(context),

                      const SizedBox(height: 16),

                      // Weekday Headers
                      _buildWeekdayHeaders(context),

                      const SizedBox(height: 8),

                      // Calendar Grid
                      _buildCalendarGrid(context, dailyCounts),

                      const SizedBox(height: 16),

                      // Legend
                      _buildLegend(context),
                    ],
                  ),
                ),

                // Stitch - lying on top right
                Positioned(
                  top: -40,
                  right: 10,
                  child: Image.asset(
                    'assets/images/stitch.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMonthNav(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth =
        _currentMonth.year == now.year && _currentMonth.month == now.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.divider,
            foregroundColor: AppTheme.textSecondary,
          ),
        ),
        Text(
          DateFormat('yyyy年M月', 'zh_CN').format(_currentMonth),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          onPressed: isCurrentMonth ? null : _nextMonth,
          icon: const Icon(Icons.chevron_right_rounded),
          style: IconButton.styleFrom(
            backgroundColor: isCurrentMonth
                ? Colors.transparent
                : AppTheme.divider,
            foregroundColor: isCurrentMonth
                ? AppTheme.textMuted
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: weekdays
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    Map<DateTime, int> dailyCounts,
  ) {
    final now = DateTime.now();
    final firstDayOfMonth = _currentMonth;
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;
    final totalDays = lastDayOfMonth.day;
    final totalCells = ((firstWeekday + totalDays) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - firstWeekday;

        if (dayOffset < 0 || dayOffset >= totalDays) {
          return const SizedBox();
        }

        final day = dayOffset + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final dateKey = DateTime(date.year, date.month, date.day);
        final count = dailyCounts[dateKey] ?? 0;
        final isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
        final isFuture = date.isAfter(now);

        return _CalendarDay(
          day: day,
          count: count,
          isToday: isToday,
          isFuture: isFuture,
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('少', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        ...List.generate(
          5,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _getColorForLevel(i),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('多', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Color _getColorForLevel(int level) {
    switch (level) {
      case 0:
        return AppTheme.divider;
      case 1:
        return AppTheme.primary.withValues(alpha: 0.25);
      case 2:
        return AppTheme.primary.withValues(alpha: 0.5);
      case 3:
        return AppTheme.primary.withValues(alpha: 0.75);
      default:
        return AppTheme.primary;
    }
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final int count;
  final bool isToday;
  final bool isFuture;

  const _CalendarDay({
    required this.day,
    required this.count,
    required this.isToday,
    required this.isFuture,
  });

  Color _getColor() {
    if (isFuture) return AppTheme.divider.withValues(alpha: 0.5);
    if (count == 0) return AppTheme.divider;

    switch (count) {
      case 1:
        return AppTheme.primary.withValues(alpha: 0.25);
      case 2:
        return AppTheme.primary.withValues(alpha: 0.5);
      case 3:
        return AppTheme.primary.withValues(alpha: 0.75);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final textColor = count > 1 ? Colors.white : AppTheme.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: isToday ? Border.all(color: AppTheme.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isFuture ? AppTheme.textMuted : textColor,
          ),
        ),
      ),
    );
  }
}
