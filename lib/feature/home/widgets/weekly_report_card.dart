import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/widget/glassmorphism_card.dart';
import 'package:intl/intl.dart';

/// Weekly Report Card - Shows last 7 days trend chart only
class WeeklyReportCard extends StatelessWidget {
  const WeeklyReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PoopProvider>(
      builder: (context, provider, child) {
        final weekData = _getWeekData(provider);
        final hasData = weekData.any((d) => d.count > 0);

        return GlassmorphismCard(
          padding: const EdgeInsets.all(16),
          backgroundOpacity: 0.8,
          child: SizedBox(
            height: 160,
            child: hasData
                ? _buildChart(context, weekData)
                : _buildEmptyState(context),
          ),
        );
      },
    );
  }

  Widget _buildChart(BuildContext context, List<_DayData> weekData) {
    final isDark = AppTheme.isDark(context);
    final maxY =
        (weekData.map((d) => d.count).reduce((a, b) => a > b ? a : b) + 1)
            .toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.cardColor(context),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = weekData[group.x.toInt()];
              return BarTooltipItem(
                '${day.label}\n',
                TextStyle(
                  color: AppTheme.textPrimaryColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '${day.count} 次',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < weekData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weekData[index].shortLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMutedColor(context),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.dividerColor(context),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: weekData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final isToday =
              data.date.day == DateTime.now().day &&
              data.date.month == DateTime.now().month &&
              data.date.year == DateTime.now().year;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.count.toDouble(),
                color: isToday
                    ? AppTheme.primary
                    : AppTheme.primary.withValues(alpha: 0.5),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 40,
            color: AppTheme.textMutedColor(context),
          ),
          const SizedBox(height: 8),
          Text(
            '暂无记录',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }

  List<_DayData> _getWeekData(PoopProvider provider) {
    final now = DateTime.now();
    final result = <_DayData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final count = provider.getRecordCountForDate(date);
      result.add(
        _DayData(
          date: date,
          count: count,
          label: DateFormat('M/d').format(date),
          shortLabel: DateFormat('E', 'zh_CN').format(date).substring(1),
        ),
      );
    }

    return result;
  }
}

class _DayData {
  final DateTime date;
  final int count;
  final String label;
  final String shortLabel;

  _DayData({
    required this.date,
    required this.count,
    required this.label,
    required this.shortLabel,
  });
}
