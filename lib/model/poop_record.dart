import 'package:easy/model/bristol_scale.dart';

/// 排便记录数据模型
class PoopRecord {
  /// 唯一标识
  final String id;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 排便颜色（文字描述，可选）
  final String? color;

  /// 布里斯托分级 (1-7)
  final BristolScale bristolScale;

  /// 排便量
  final PoopAmount amount;

  PoopRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.color,
    required this.bristolScale,
    required this.amount,
  });

  /// 时长（分钟）
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// 时长（格式化字符串）
  String get durationText {
    final minutes = durationMinutes;
    if (minutes < 60) {
      return '$minutes分钟';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '$hours小时$mins分钟' : '$hours小时';
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color,
      'bristolScale': bristolScale.index,
      'amount': amount.index,
    };
  }

  /// 从 JSON 转换
  factory PoopRecord.fromJson(Map<String, dynamic> json) {
    return PoopRecord(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      color: json['color'] as String?,
      bristolScale: BristolScale.values[json['bristolScale'] as int],
      amount: PoopAmount.values[json['amount'] as int],
    );
  }

  /// 创建副本
  PoopRecord copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    String? color,
    BristolScale? bristolScale,
    PoopAmount? amount,
  }) {
    return PoopRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      bristolScale: bristolScale ?? this.bristolScale,
      amount: amount ?? this.amount,
    );
  }
}

/// 排便量枚举
enum PoopAmount {
  small,
  medium,
  large;

  /// 显示文本
  String get label {
    switch (this) {
      case PoopAmount.small:
        return '少量';
      case PoopAmount.medium:
        return '中量';
      case PoopAmount.large:
        return '大量';
    }
  }
}
