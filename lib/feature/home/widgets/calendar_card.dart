import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/feature/home/widgets/star_animation.dart';
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
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor(context)),
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

        final dayWidget = _CalendarDay(
          key: isToday ? AnimationKeys.todayCalendarKey : null,
          day: day,
          count: count,
          isToday: isToday,
          isFuture: isFuture,
          onTap: () => _showDayDetail(context, date, count),
        );

        if (isToday) {
          return ListenableBuilder(
            listenable: CalendarWaveAnimation(),
            builder: (context, child) {
              return WaveEffect(
                animate: CalendarWaveAnimation().isAnimating,
                child: dayWidget,
              );
            },
          );
        }

        return dayWidget;
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

  void _showDayDetail(BuildContext context, DateTime date, int count) {
    final dateStr = DateFormat('M月d日', 'zh_CN').format(date);
    final provider = Provider.of<PoopProvider>(context, listen: false);

    // Get records for this specific day
    final dayRecords = provider.records.where((r) {
      return r.startTime.year == date.year &&
          r.startTime.month == date.month &&
          r.startTime.day == date.day;
    }).toList();

    // Sort by time (newest first)
    dayRecords.sort((a, b) => b.startTime.compareTo(a.startTime));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count 次',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Records list (scrollable)
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: dayRecords.length,
                      itemBuilder: (context, index) {
                        final record = dayRecords[index];
                        final timeStr = DateFormat(
                          'HH:mm',
                        ).format(record.startTime);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.dividerColor(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Type badge
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${record.bristolScale.typeNumber}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      timeStr,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${record.durationText} · ${record.amount.label}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final int count;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  const _CalendarDay({
    super.key,
    required this.day,
    required this.count,
    required this.isToday,
    required this.isFuture,
    this.onTap,
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

    return GestureDetector(
      onTap: count > 0 && !isFuture ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
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
      ),
    );
  }
}
