import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:intl/intl.dart';

/// Calendar Heatmap - Duolingo Style
class Heatmap extends StatelessWidget {
  const Heatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PoopProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF58CC02)),
          );
        }

        return FutureBuilder<Map<DateTime, int>>(
          future: provider.getDailyCounts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF58CC02)),
              );
            }

            final dailyCounts = snapshot.data!;
            return _CalendarHeatmap(dailyCounts: dailyCounts);
          },
        );
      },
    );
  }
}

class _CalendarHeatmap extends StatefulWidget {
  final Map<DateTime, int> dailyCounts;

  const _CalendarHeatmap({required this.dailyCounts});

  @override
  State<_CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<_CalendarHeatmap> {
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
    // Don't allow navigating to future months
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1, 1))) {
      setState(() {
        _currentMonth = nextMonth;
      });
    }
  }

  Color _getColorForCount(int count) {
    if (count == 0) return const Color(0xFFE5E5E5);

    const baseColor = Color(0xFF58CC02);
    switch (count) {
      case 1:
        return baseColor.withValues(alpha: 0.3);
      case 2:
        return baseColor.withValues(alpha: 0.5);
      case 3:
        return baseColor.withValues(alpha: 0.7);
      default:
        return baseColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '记录日历',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF58CC02),
                ),
              ),
              Text(
                DateFormat('yyyy年M月', 'zh_CN').format(_currentMonth),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF58CC02),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekday headers
          Row(
            children: ['一', '二', '三', '四', '五', '六', '日']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF777777),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          _buildCalendarGrid(now),

          const SizedBox(height: 16),

          // Legend
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime now) {
    // Get first day of month
    final firstDayOfMonth = _currentMonth;
    // Get last day of month
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );

    // Calculate offset for first day (Monday = 0, Sunday = 6)
    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;

    // Total cells needed
    final totalDays = lastDayOfMonth.day;
    final totalCells = ((firstWeekday + totalDays) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - firstWeekday;

        // Empty cell for days before month starts or after month ends
        if (dayOffset < 0 || dayOffset >= totalDays) {
          return const SizedBox();
        }

        final day = dayOffset + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final dateKey = DateTime(date.year, date.month, date.day);
        final count = widget.dailyCounts[dateKey] ?? 0;

        // Check if this is today
        final isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        // Check if date is in future
        final isFuture = date.isAfter(now);

        return _CalendarDay(
          day: day,
          count: count,
          color: isFuture ? const Color(0xFFF0F0F0) : _getColorForCount(count),
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
        Text(
          '少',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF777777),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        _LegendDot(color: const Color(0xFFE5E5E5)),
        const SizedBox(width: 4),
        _LegendDot(color: const Color(0xFF58CC02).withValues(alpha: 0.3)),
        const SizedBox(width: 4),
        _LegendDot(color: const Color(0xFF58CC02).withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        _LegendDot(color: const Color(0xFF58CC02).withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        _LegendDot(color: const Color(0xFF58CC02)),
        const SizedBox(width: 8),
        Text(
          '多',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF777777),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Calendar day cell
class _CalendarDay extends StatelessWidget {
  final int day;
  final int count;
  final Color color;
  final bool isToday;
  final bool isFuture;

  const _CalendarDay({
    required this.day,
    required this.count,
    required this.color,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isFuture ? '' : '$count 次',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: const Color(0xFF58CC02), width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: isFuture
                  ? const Color(0xFFCCCCCC)
                  : (count > 0 ? Colors.white : const Color(0xFF777777)),
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Legend dot
class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
