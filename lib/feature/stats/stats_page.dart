import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/service/cloud_sync_service.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:easy/core/widget/glassmorphism_card.dart';
import 'package:intl/intl.dart';

/// Statistics Page - Detailed data analysis with charts
///
/// Supports viewing data in different time dimensions:
/// - Week
/// - Month
/// - Year
///
/// Can view own data or a friend's data (if userId is provided)
class StatsPage extends StatefulWidget {
  /// If provided, view this user's stats instead of own
  final String? userId;

  /// Display name for the user (shown in title)
  final String? userDisplayName;

  const StatsPage({super.key, this.userId, this.userDisplayName});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  _TimeRange _selectedRange = _TimeRange.week;

  // For viewing friend's data
  List<PoopRecord> _friendRecords = [];
  bool _isLoadingFriend = false;

  bool get _isViewingFriend => widget.userId != null;

  @override
  void initState() {
    super.initState();
    if (_isViewingFriend) {
      _loadFriendRecords();
    }
  }

  Future<void> _loadFriendRecords() async {
    setState(() => _isLoadingFriend = true);

    final records = await CloudSyncService.instance.fetchRecords(
      userId: widget.userId,
    );

    if (mounted) {
      setState(() {
        _friendRecords = records;
        _isLoadingFriend = false;
      });
    }
  }

  String get _pageTitle {
    if (_isViewingFriend && widget.userDisplayName != null) {
      return '${widget.userDisplayName} 的统计';
    }
    return '统计分析';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(_pageTitle),
      ),
      body: _isViewingFriend
          ? _buildFriendContent()
          : Consumer<PoopProvider>(
              builder: (context, provider, child) {
                return _buildContent(provider.records);
              },
            ),
    );
  }

  Widget _buildFriendContent() {
    if (_isLoadingFriend) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildContent(_friendRecords);
  }

  Widget _buildContent(List<PoopRecord> records) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Time range selector
        _buildTimeRangeSelector(context),

        const SizedBox(height: 24),

        // Summary stats
        _buildSummaryStats(context, records),

        const SizedBox(height: 24),

        // Trend chart
        _buildTrendChart(context, records),

        const SizedBox(height: 24),

        // Distribution stats
        _buildDistributionStats(context, records),
      ],
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return Row(
      children: _TimeRange.values.map((range) {
        final isSelected = range == _selectedRange;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRange = range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: range != _TimeRange.values.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.dividerColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  range.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textSecondaryColor(context),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryStats(BuildContext context, List<PoopRecord> records) {
    final stats = _calculateStats(records);

    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      backgroundOpacity: 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_selectedRange.label}统计',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatItem(
                label: '总次数',
                value: '${stats.totalCount}',
                color: AppTheme.primary,
              ),
              _StatItem(
                label: '日均',
                value: stats.avgPerDay.toStringAsFixed(1),
                color: AppTheme.secondary,
              ),
              _StatItem(
                label: '最高日',
                value: '${stats.maxDayCount}',
                color: AppTheme.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(
                label: '当前连续',
                value: '${_getStreak(records)}',
                color: AppTheme.success,
              ),
              _StatItem(
                label: '最长连续',
                value: '${_getLongestStreak(records)}',
                color: AppTheme.warning,
              ),
              _StatItem(
                label: '记录天数',
                value: '${stats.recordDays}',
                color: AppTheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context, List<PoopRecord> records) {
    final chartData = _getChartData(records);
    final hasData = chartData.any((d) => d.count > 0);

    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = hasData
        ? (chartData.map((d) => d.count).reduce((a, b) => a > b ? a : b) + 1)
              .toDouble()
        : 5.0;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      backgroundOpacity: 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('趋势图', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: hasData
                ? LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppTheme.dividerColor(context),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _getXInterval(chartData.length),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < chartData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    chartData[index].label,
                                    style: TextStyle(
                                      fontSize: 10,
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
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value == value.roundToDouble()) {
                                return Text(
                                  '${value.toInt()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textMutedColor(context),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              e.value.count.toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: AppTheme.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primary.withValues(alpha: 0.3),
                                AppTheme.primary.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.cardColor(context),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final data = chartData[spot.x.toInt()];
                              return LineTooltipItem(
                                '${data.fullLabel}\n',
                                TextStyle(
                                  color: AppTheme.textPrimaryColor(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${data.count} 次',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      '暂无数据',
                      style: TextStyle(color: AppTheme.textMutedColor(context)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionStats(
    BuildContext context,
    List<PoopRecord> records,
  ) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Calculate Bristol scale distribution
    final bristolCounts = <int, int>{};
    for (final record in records) {
      final type = record.bristolScale.typeNumber;
      if (type > 0) {
        // Skip custom type (typeNumber == 0)
        bristolCounts[type] = (bristolCounts[type] ?? 0) + 1;
      }
    }

    if (bristolCounts.isEmpty) return const SizedBox.shrink();

    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      backgroundOpacity: 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('类型分布', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(7, (index) {
            final type = index + 1;
            final count = bristolCounts[type] ?? 0;
            final total = bristolCounts.values.reduce((a, b) => a + b);
            final percentage = total > 0 ? count / total : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Type $type',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor(context),
                        ),
                      ),
                      Text(
                        '$count 次 (${(percentage * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(
                          color: AppTheme.textMutedColor(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppTheme.dividerColor(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getBristolColor(type),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getBristolColor(int type) {
    // Color gradient from constipation (1-2) to diarrhea (6-7)
    // Type 3-4 is ideal (green)
    switch (type) {
      case 1:
      case 2:
        return const Color(0xFFF59E0B); // Amber - constipation
      case 3:
      case 4:
        return AppTheme.primary; // Green - ideal
      case 5:
        return const Color(0xFF6366F1); // Indigo - soft
      case 6:
      case 7:
        return const Color(0xFFEF4444); // Red - loose
      default:
        return AppTheme.textMuted;
    }
  }

  _Stats _calculateStats(List<PoopRecord> records) {
    final now = DateTime.now();
    final DateTime startDate;

    switch (_selectedRange) {
      case _TimeRange.week:
        startDate = now.subtract(const Duration(days: 7));
      case _TimeRange.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
      case _TimeRange.year:
        startDate = DateTime(now.year - 1, now.month, now.day);
    }

    final filtered = records
        .where((r) => r.startTime.isAfter(startDate))
        .toList();

    // Count records per day
    final dailyCounts = <DateTime, int>{};
    for (final record in filtered) {
      final date = DateTime(
        record.startTime.year,
        record.startTime.month,
        record.startTime.day,
      );
      dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
    }

    final days = now.difference(startDate).inDays;
    final totalCount = filtered.length;
    final avgPerDay = days > 0 ? totalCount / days : 0.0;
    final maxDayCount = dailyCounts.isEmpty
        ? 0
        : dailyCounts.values.reduce((a, b) => a > b ? a : b);
    final recordDays = dailyCounts.length;

    return _Stats(
      totalCount: totalCount,
      avgPerDay: avgPerDay,
      maxDayCount: maxDayCount,
      recordDays: recordDays,
    );
  }

  List<_ChartData> _getChartData(List<PoopRecord> records) {
    final now = DateTime.now();
    final result = <_ChartData>[];

    switch (_selectedRange) {
      case _TimeRange.week:
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final count = _getRecordCountForDate(records, date);
          result.add(
            _ChartData(
              date: date,
              count: count,
              label: DateFormat('E', 'zh_CN').format(date).substring(1),
              fullLabel: DateFormat('M/d').format(date),
            ),
          );
        }
      case _TimeRange.month:
        for (int i = 29; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final count = _getRecordCountForDate(records, date);
          result.add(
            _ChartData(
              date: date,
              count: count,
              label: date.day.toString(),
              fullLabel: DateFormat('M/d').format(date),
            ),
          );
        }
      case _TimeRange.year:
        for (int i = 11; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i);
          int count = 0;
          final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
          for (int d = 1; d <= daysInMonth; d++) {
            count += _getRecordCountForDate(
              records,
              DateTime(month.year, month.month, d),
            );
          }
          result.add(
            _ChartData(
              date: month,
              count: count,
              label: '${month.month}月',
              fullLabel: DateFormat('yyyy年M月').format(month),
            ),
          );
        }
    }

    return result;
  }

  /// Get record count for a specific date
  int _getRecordCountForDate(List<PoopRecord> records, DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return records.where((r) {
      final recordDate = DateTime(
        r.startTime.year,
        r.startTime.month,
        r.startTime.day,
      );
      return recordDate == targetDate;
    }).length;
  }

  /// Calculate streak (consecutive days with records)
  int _getStreak(List<PoopRecord> records) {
    if (records.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final Set<DateTime> dates = {};
    for (final record in records) {
      dates.add(
        DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        ),
      );
    }

    DateTime currentDate = dates.contains(todayDate)
        ? todayDate
        : todayDate.subtract(const Duration(days: 1));

    int streak = 0;
    while (dates.contains(currentDate)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Get longest streak
  int _getLongestStreak(List<PoopRecord> records) {
    if (records.isEmpty) return 0;

    final Set<DateTime> dateSet = {};
    for (final record in records) {
      dateSet.add(
        DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        ),
      );
    }
    final dates = dateSet.toList()..sort();

    if (dates.isEmpty) return 0;

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  double _getXInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 15) return 2;
    if (dataLength <= 30) return 5;
    return 1;
  }
}

enum _TimeRange {
  week('周'),
  month('月'),
  year('年');

  final String label;
  const _TimeRange(this.label);
}

class _Stats {
  final int totalCount;
  final double avgPerDay;
  final int maxDayCount;
  final int recordDays;

  _Stats({
    required this.totalCount,
    required this.avgPerDay,
    required this.maxDayCount,
    required this.recordDays,
  });
}

class _ChartData {
  final DateTime date;
  final int count;
  final String label;
  final String fullLabel;

  _ChartData({
    required this.date,
    required this.count,
    required this.label,
    required this.fullLabel,
  });
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
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
