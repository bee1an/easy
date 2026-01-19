import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/theme/heatmap_colors.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:easy/core/utils/date_utils.dart';
import 'package:easy/core/widget/glassmorphism_card.dart';
import 'package:easy/feature/home/widgets/record_dialog.dart';
import 'package:intl/intl.dart';

/// Poop Detail Page - Module detail view with calendar heatmap
///
/// Contains:
/// - Monthly calendar heatmap (migrated from home)
/// - Day detail bottom sheet (with edit/delete)
/// - Quick stats summary
class PoopDetailPage extends StatefulWidget {
  const PoopDetailPage({super.key});

  @override
  State<PoopDetailPage> createState() => _PoopDetailPageState();
}

class _PoopDetailPageState extends State<PoopDetailPage> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now().firstDayOfMonth;
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('排便记录'),
        actions: [
          IconButton(
            onPressed: () => AppRouter.push(context, AppRouter.stats),
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: '统计分析',
          ),
        ],
      ),
      body: Consumer<PoopProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<Map<DateTime, int>>(
            future: provider.getDailyCounts(),
            builder: (context, snapshot) {
              final dailyCounts = snapshot.data ?? {};

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Quick Stats
                  _buildQuickStats(context, provider),

                  const SizedBox(height: 24),

                  // Calendar Heatmap
                  _buildCalendarCard(context, dailyCounts, provider),

                  const SizedBox(height: 24),

                  // Legend
                  _buildLegend(context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, PoopProvider provider) {
    final todayCount = provider.getTodayCount();
    final streak = provider.getStreak();
    final totalRecords = provider.records.length;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      backgroundOpacity: 0.8,
      child: Row(
        children: [
          _StatItem(
            icon: Icons.today_rounded,
            label: '今日',
            value: '$todayCount',
            color: AppTheme.primary,
          ),
          _buildDivider(context),
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            label: '连续',
            value: '$streak',
            color: AppTheme.accent,
          ),
          _buildDivider(context),
          _StatItem(
            icon: Icons.history_rounded,
            label: '总计',
            value: '$totalRecords',
            color: AppTheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.borderColor(context),
    );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    Map<DateTime, int> dailyCounts,
    PoopProvider provider,
  ) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      backgroundOpacity: 0.8,
      child: Column(
        children: [
          // Month Navigation
          _buildMonthNav(context),

          const SizedBox(height: 16),

          // Weekday Headers
          _buildWeekdayHeaders(context),

          const SizedBox(height: 8),

          // Calendar Grid
          _buildCalendarGrid(context, dailyCounts, provider),
        ],
      ),
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
            backgroundColor: AppTheme.dividerColor(context),
            foregroundColor: AppTheme.textSecondaryColor(context),
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
                : AppTheme.dividerColor(context),
            foregroundColor: isCurrentMonth
                ? AppTheme.textMutedColor(context)
                : AppTheme.textSecondaryColor(context),
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
    PoopProvider provider,
  ) {
    final firstWeekday = _currentMonth.weekdayIndex;
    final totalDays = _currentMonth.daysInMonth;
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

        if (dayOffset < 0 || dayOffset >= totalDays) {
          return const SizedBox();
        }

        final day = dayOffset + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final count = dailyCounts[date.dateOnly] ?? 0;
        final isToday = date.isToday;
        final isFuture = date.isFutureDay;

        return _CalendarDay(
          day: day,
          count: count,
          isToday: isToday,
          isFuture: isFuture,
          onTap: () => _showDayDetail(context, date, provider),
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
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: HeatmapColors.getColor(context, i),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('多', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _showDayDetail(
    BuildContext context,
    DateTime date,
    PoopProvider provider,
  ) {
    final dateStr = DateFormat('M月d日', 'zh_CN').format(date);

    // Get records for this specific day
    final dayRecords = provider.records.where((r) {
      return r.startTime.dateOnly.isSameDay(date.dateOnly);
    }).toList();

    if (dayRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dateStr 暂无记录'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Sort by time (newest first)
    dayRecords.sort((a, b) => b.startTime.compareTo(a.startTime));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
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
                          '${dayRecords.length} 次',
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
                          child: Material(
                            color: AppTheme.dividerColor(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => _showRecordOptions(
                                context,
                                sheetContext,
                                record,
                                provider,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
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
                                        child: record.bristolScale.isCustom
                                            ? Icon(
                                                Icons.edit_rounded,
                                                size: 18,
                                                color: AppTheme.primary,
                                              )
                                            : Text(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            timeStr,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${record.durationText} · ${record.amountDisplayText} · ${record.colorDisplayText}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.more_vert_rounded,
                                      color: AppTheme.textMutedColor(context),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  void _showRecordOptions(
    BuildContext context,
    BuildContext sheetContext,
    dynamic record,
    PoopProvider provider,
  ) {
    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppTheme.cardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (optionContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(optionContext);
                Navigator.pop(sheetContext);
                _showEditDialog(context, record, provider);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: AppTheme.error),
              title: Text('删除', style: TextStyle(color: AppTheme.error)),
              onTap: () {
                Navigator.pop(optionContext);
                _confirmDelete(sheetContext, record, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    dynamic record,
    PoopProvider provider,
  ) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => RecordDialog(
        timerProvider: timerProvider,
        initialRecord: record,
        onUpdate: (updatedRecord) {
          provider.updateRecord(updatedRecord);
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext sheetContext,
    dynamic record,
    PoopProvider provider,
  ) {
    showDialog(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(sheetContext);
              provider.deleteRecord(record.id);
            },
            child: Text('删除', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
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
    required this.day,
    required this.count,
    required this.isToday,
    required this.isFuture,
    this.onTap,
  });

  Color _getColor(BuildContext context) {
    if (isFuture) return HeatmapColors.getFutureColor(context);
    return HeatmapColors.getColor(context, count);
  }

  Color _getTextColor(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    if (isFuture) {
      return AppTheme.textMutedColor(context);
    }

    if (count >= 2) {
      return Colors.white;
    }

    return isDark ? AppTheme.textPrimaryColor(context) : AppTheme.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: count > 0 && !isFuture ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _getColor(context),
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
          boxShadow: count > 0 && !isFuture
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: _getTextColor(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
