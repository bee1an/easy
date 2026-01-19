import 'package:flutter/foundation.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/service/cloud_sync_service.dart';
import 'package:easy/core/utils/date_utils.dart';

/// 排便记录状态管理（纯云端存储模式）
class PoopProvider with ChangeNotifier {
  final CloudSyncService _cloudSync = CloudSyncService.instance;

  List<PoopRecord> _records = [];
  bool _isLoading = false;

  /// 所有记录（按时间倒序）
  List<PoopRecord> get records => _records;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 从云端加载记录
  Future<void> loadRecords() async {
    if (!_cloudSync.isLoggedIn) {
      _records = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _records = await _cloudSync.fetchRecords();

    _isLoading = false;
    notifyListeners();
  }

  /// 添加记录（直接写入云端）
  Future<bool> addRecord(PoopRecord record) async {
    if (!_cloudSync.isLoggedIn) return false;

    final success = await _cloudSync.syncRecord(record);
    if (success) {
      _records.insert(0, record);
      notifyListeners();
    }
    return success;
  }

  /// 更新记录（直接写入云端）
  Future<bool> updateRecord(PoopRecord record) async {
    if (!_cloudSync.isLoggedIn) return false;

    final success = await _cloudSync.syncRecord(record);
    if (success) {
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record;
        notifyListeners();
      }
    }
    return success;
  }

  /// 删除记录（直接从云端删除）
  Future<bool> deleteRecord(String id) async {
    if (!_cloudSync.isLoggedIn) return false;

    final success = await _cloudSync.deleteRecord(id);
    if (success) {
      _records.removeWhere((r) => r.id == id);
      notifyListeners();
    }
    return success;
  }

  /// 按日期获取记录数量
  Future<Map<DateTime, int>> getDailyCounts() async {
    final Map<DateTime, int> result = {};
    for (final record in _records) {
      final date = record.startTime.dateOnly;
      result[date] = (result[date] ?? 0) + 1;
    }
    return result;
  }

  /// 清空所有记录（需要逐个删除云端记录）
  Future<void> clearAll() async {
    if (!_cloudSync.isLoggedIn) return;

    for (final record in List.from(_records)) {
      await _cloudSync.deleteRecord(record.id);
    }
    _records.clear();
    notifyListeners();
  }

  /// 获取今日记录
  List<PoopRecord> getTodayRecords() {
    final today = DateTime.now().dateOnly;
    return _records
        .where((r) => r.startTime.dateOnly.isSameDay(today))
        .toList();
  }

  /// 获取今日次数
  int getTodayCount() {
    return getTodayRecords().length;
  }

  /// 获取指定日期的记录次数
  int getRecordCountForDate(DateTime date) {
    final targetDate = date.dateOnly;
    return _records
        .where((r) => r.startTime.dateOnly.isSameDay(targetDate))
        .length;
  }

  /// 获取本周次数
  int getWeekCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)).dateOnly;

    return _records.where((r) => !r.startTime.isBefore(weekStart)).length;
  }

  /// 获取本月次数
  int getMonthCount() {
    final monthStart = DateTime.now().firstDayOfMonth;
    return _records.where((r) => !r.startTime.isBefore(monthStart)).length;
  }

  /// 计算连续记录天数（连胜）
  int getStreak() {
    if (_records.isEmpty) return 0;

    final today = DateTime.now().dateOnly;

    // 获取所有有记录的日期
    final Set<DateTime> dates = {};
    for (final record in _records) {
      dates.add(record.startTime.dateOnly);
    }

    // 如果今天没有记录，从昨天开始算
    DateTime currentDate = dates.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    int streak = 0;
    while (dates.contains(currentDate)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// 获取历史最长连续天数
  int getLongestStreak() {
    if (_records.isEmpty) return 0;

    // 获取所有有记录的日期并排序
    final Set<DateTime> dateSet = {};
    for (final record in _records) {
      dateSet.add(record.startTime.dateOnly);
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
}
