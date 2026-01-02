import 'package:flutter/foundation.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/service/storage_service.dart';

/// 排便记录状态管理
class PoopProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<PoopRecord> _records = [];
  bool _isLoading = false;

  /// 所有记录（按时间倒序）
  List<PoopRecord> get records => _records;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 加载记录
  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    _records = await _storageService.getRecords();

    _isLoading = false;
    notifyListeners();
  }

  /// 添加记录
  Future<void> addRecord(PoopRecord record) async {
    await _storageService.addRecord(record);
    _records.insert(0, record);
    notifyListeners();
  }

  /// 更新记录
  Future<void> updateRecord(PoopRecord record) async {
    await _storageService.updateRecord(record);
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _records[index] = record;
      notifyListeners();
    }
  }

  /// 删除记录
  Future<void> deleteRecord(String id) async {
    await _storageService.deleteRecord(id);
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// 按日期获取记录数量
  Future<Map<DateTime, int>> getDailyCounts() async {
    final Map<DateTime, int> result = {};
    for (final record in _records) {
      final date = DateTime(
        record.startTime.year,
        record.startTime.month,
        record.startTime.day,
      );
      result[date] = (result[date] ?? 0) + 1;
    }
    return result;
  }

  /// 清空所有记录
  Future<void> clearAll() async {
    await _storageService.clearAllRecords();
    _records.clear();
    notifyListeners();
  }

  /// 导出数据
  Future<String> exportData() async {
    return await _storageService.exportToJson();
  }

  /// 获取今日记录
  List<PoopRecord> getTodayRecords() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _records.where((r) {
      final date = DateTime(r.startTime.year, r.startTime.month, r.startTime.day);
      return date.isAtSameMomentAs(today);
    }).toList();
  }

  /// 获取今日次数
  int getTodayCount() {
    return getTodayRecords().length;
  }

  /// 获取本周次数
  int getWeekCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

    return _records.where((r) {
      return !r.startTime.isBefore(startOfDay);
    }).length;
  }

  /// 获取本月次数
  int getMonthCount() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return _records.where((r) {
      return !r.startTime.isBefore(monthStart);
    }).length;
  }

  /// 计算连续记录天数（连胜）
  int getStreak() {
    if (_records.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 获取所有有记录的日期
    final Set<DateTime> dates = {};
    for (final record in _records) {
      final date = DateTime(
        record.startTime.year,
        record.startTime.month,
        record.startTime.day,
      );
      dates.add(date);
    }

    // 如果今天没有记录，从昨天开始算
    DateTime currentDate = dates.contains(today) ? today : today.subtract(const Duration(days: 1));

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
    final List<DateTime> dates = [];
    for (final record in _records) {
      final date = DateTime(
        record.startTime.year,
        record.startTime.month,
        record.startTime.day,
      );
      if (!dates.contains(date)) {
        dates.add(date);
      }
    }
    dates.sort();

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
