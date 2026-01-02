import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy/model/poop_record.dart';

/// 本地存储服务 - 使用 SharedPreferences（带缓存优化）
class StorageService {
  static const String _key = 'poop_records';

  SharedPreferences? _cachedPrefs;
  List<PoopRecord>? _cachedRecords;
  bool _isDirty = true;

  /// 获取 SharedPreferences 实例（带缓存）
  Future<SharedPreferences> _getPrefs() async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }

  /// 读取所有记录（带缓存）
  Future<List<PoopRecord>> getRecords() async {
    // 如果缓存有效且未修改，直接返回缓存
    if (!_isDirty && _cachedRecords != null) {
      return List.from(_cachedRecords!);
    }

    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        _cachedRecords = [];
        _isDirty = false;
        return [];
      }

      final List<dynamic> json = jsonDecode(jsonString);
      _cachedRecords = json
          .map((e) => PoopRecord.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      _isDirty = false;

      return List.from(_cachedRecords!);
    } catch (e) {
      // 发生错误时返回空列表或缓存
      return _cachedRecords ?? [];
    }
  }

  /// 保存记录列表（写入并更新缓存）
  Future<void> saveRecords(List<PoopRecord> records) async {
    final prefs = await _getPrefs();
    final json = jsonEncode(records.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);

    // 更新缓存
    _cachedRecords = List.from(records)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    _isDirty = false;
  }

  /// 添加记录（优化版：直接更新缓存）
  Future<void> addRecord(PoopRecord record) async {
    // 确保缓存已加载
    final records = await getRecords();

    // 更新缓存
    records.insert(0, record);

    // 异步保存，不阻塞
    _saveInBackground(records);
  }

  /// 更新记录（优化版：直接更新缓存）
  Future<void> updateRecord(PoopRecord record) async {
    final records = await getRecords();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      records[index] = record;
      _saveInBackground(records);
    }
  }

  /// 删除记录（优化版：直接更新缓存）
  Future<void> deleteRecord(String id) async {
    final records = await getRecords();
    records.removeWhere((r) => r.id == id);
    _saveInBackground(records);
  }

  /// 后台保存（不阻塞）
  Future<void> _saveInBackground(List<PoopRecord> records) async {
    try {
      final prefs = await _getPrefs();
      final json = jsonEncode(records.map((e) => e.toJson()).toList());
      await prefs.setString(_key, json);

      // 标记缓存有效
      _cachedRecords = List.from(records);
      _isDirty = false;
    } catch (e) {
      // 保存失败，标记为需要重新加载
      _isDirty = true;
    }
  }

  /// 按日期获取记录
  Future<Map<DateTime, List<PoopRecord>>> getRecordsByDate() async {
    final records = await getRecords();
    final Map<DateTime, List<PoopRecord>> result = {};

    for (final record in records) {
      final date = DateTime(
        record.startTime.year,
        record.startTime.month,
        record.startTime.day,
      );
      result.putIfAbsent(date, () => []).add(record);
    }

    return result;
  }

  /// 获取某一天的记录数量
  Future<int> getRecordCountForDate(DateTime date) async {
    final recordsByDate = await getRecordsByDate();
    final key = DateTime(date.year, date.month, date.day);
    return recordsByDate[key]?.length ?? 0;
  }

  /// 获取指定日期范围内的记录
  Future<List<PoopRecord>> getRecordsInRange(DateTime start, DateTime end) async {
    final records = await getRecords();
    return records.where((r) {
      final date = DateTime(r.startTime.year, r.startTime.month, r.startTime.day);
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList();
  }

  /// 导出为 JSON 字符串
  Future<String> exportToJson() async {
    final records = await getRecords();
    return jsonEncode(records.map((e) => e.toJson()).toList());
  }

  /// 清空所有记录
  Future<void> clearAllRecords() async {
    await saveRecords([]);
    _cachedRecords = [];
    _isDirty = false;
  }

  /// 强制刷新缓存（用于外部数据变更后）
  void invalidateCache() {
    _isDirty = true;
  }
}
