import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/model/poop_color.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/model/bristol_scale.dart';
import 'package:easy/core/widget/widget_service.dart';
import 'package:easy/core/utils/duration_utils.dart';
import 'package:uuid/uuid.dart';

import 'package:easy/service/notification_service.dart';

/// 计时器状态管理
class TimerProvider with ChangeNotifier {
  final PoopProvider _poopProvider;
  static final _uuid = Uuid();

  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _notifiedLongTimer = false;

  TimerProvider(this._poopProvider);

  /// 是否正在计时
  bool get isRunning => _startTime != null;

  /// 开始时间
  DateTime? get startTime => _startTime;

  /// 已过时间
  Duration get elapsed => _elapsed;

  /// 格式化的时间显示
  String get elapsedText => _elapsed.toDisplayString();

  /// 开始计时
  void startTimer() {
    _startTime = DateTime.now();
    _elapsed = Duration.zero;
    _notifiedLongTimer = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();

      // Notify if timer > 30 minutes
      if (_elapsed.inMinutes >= 30 && !_notifiedLongTimer) {
        _notifiedLongTimer = true;
        NotificationService().showNotification(
          title: '时间过长请注意',
          body: '你已经记录超过 30 分钟了，请注意身体健康。',
        );
      }

      // Update widget every 10 seconds
      if (_elapsed.inSeconds % 10 == 0) {
        WidgetService.updateTimerStatus(true, elapsedText);
      }
    });
    notifyListeners();

    // Immediate update
    WidgetService.updateTimerStatus(true, elapsedText);
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

    // Sync with widget
    WidgetService.updateTimerStatus(isRunning, elapsedText);
  }

  /// 保存记录
  Future<void> saveRecord({
    DateTime? startTime,
    DateTime? endTime,
    bool endTracking = false,
    PoopColor poopColor = PoopColor.normal,
    String? customColor,
    required BristolScale bristolScale,
    String? customType,
    required PoopAmount amount,
    String? customAmount,
  }) async {
    final start = startTime ?? _startTime;
    if (start == null) return;

    final end = endTime ?? DateTime.now();
    final record = PoopRecord(
      id: _generateId(),
      startTime: start,
      endTime: end,
      poopColor: poopColor,
      customColor: customColor,
      bristolScale: bristolScale,
      customType: customType,
      amount: amount,
      customAmount: customAmount,
    );

    await _poopProvider.addRecord(record);

    // 重置计时器
    if (endTracking) {
      _stopAndResetTimer();
    }
  }

  void _stopAndResetTimer() {
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _elapsed = Duration.zero;
    _notifiedLongTimer = false;
    notifyListeners();

    // Sync with widget
    WidgetService.updateTimerStatus(isRunning, elapsedText);
  }

  /// 生成唯一 ID（使用 UUID v4）
  String _generateId() {
    return _uuid.v4();
  }
}
