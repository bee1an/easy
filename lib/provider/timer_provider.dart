import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/model/bristol_scale.dart';
import 'package:uuid/uuid.dart';

/// 计时器状态管理
class TimerProvider with ChangeNotifier {
  final PoopProvider _poopProvider;
  static final _uuid = Uuid();

  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  TimerProvider(this._poopProvider);

  /// 是否正在计时
  bool get isRunning => _startTime != null;

  /// 开始时间
  DateTime? get startTime => _startTime;

  /// 已过时间
  Duration get elapsed => _elapsed;

  /// 格式化的时间显示
  String get elapsedText {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 开始计时
  void startTimer() {
    _startTime = DateTime.now();
    _elapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    });
    notifyListeners();
  }

  /// 停止计时
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  /// 取消计时
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _elapsed = Duration.zero;
    notifyListeners();
  }

  /// 保存记录
  Future<void> saveRecord({
    String? color,
    required BristolScale bristolScale,
    required PoopAmount amount,
  }) async {
    if (_startTime == null) return;

    final endTime = DateTime.now();
    final record = PoopRecord(
      id: _generateId(),
      startTime: _startTime!,
      endTime: endTime,
      color: color,
      bristolScale: bristolScale,
      amount: amount,
    );

    await _poopProvider.addRecord(record);

    // 重置计时器
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _elapsed = Duration.zero;
    notifyListeners();
  }

  /// 生成唯一 ID（使用 UUID v4）
  String _generateId() {
    return _uuid.v4();
  }
}
