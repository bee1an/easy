import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:easy/model/poop_record.dart';

/// Service to synchronize data with iOS Home Screen Widget
class WidgetService {
  static const String _groupId = 'group.com.bee1an.easy';
  static const String _iosWidgetName = 'EasyWidget';

  /// Update widget data
  static Future<void> updateWidgetData(List<PoopRecord> records) async {
    debugPrint(
      'WidgetService: updateWidgetData called with ${records.length} records',
    );
    try {
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // Filter records for the current month
      final monthlyRecords = records.where(
        (r) =>
            r.startTime.month == currentMonth &&
            r.startTime.year == currentYear,
      );

      // Create a map of day -> count
      final dailyCounts = <String, int>{};
      for (final record in monthlyRecords) {
        final day = record.startTime.day.toString();
        dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      }

      // Convert to a simple JSON string for the widget
      final data = {
        'month': currentMonth,
        'year': currentYear,
        'counts': dailyCounts,
        'lastUpdated': now.millisecondsSinceEpoch,
      };

      debugPrint('WidgetService: Widget data: $data');

      // Save to shared container
      await HomeWidget.setAppGroupId(_groupId);
      await HomeWidget.saveWidgetData('monthly_stats', jsonEncode(data));

      // Notify the widget to update
      final result = await HomeWidget.updateWidget(iOSName: _iosWidgetName);
      debugPrint('WidgetService: Update result: $result');
    } catch (e) {
      debugPrint('WidgetService: Error updating widget data: $e');
    }
  }

  /// Update timer status for widget
  static Future<void> updateTimerStatus(
    bool isRunning,
    String elapsedText,
  ) async {
    try {
      await HomeWidget.setAppGroupId(_groupId);
      await HomeWidget.saveWidgetData('is_running', isRunning);
      await HomeWidget.saveWidgetData('elapsed_text', elapsedText);

      await HomeWidget.updateWidget(iOSName: _iosWidgetName);
    } catch (e) {
      debugPrint('WidgetService: Error updating timer status: $e');
    }
  }
}
