import 'package:easy/model/bristol_scale.dart';
import 'package:easy/model/poop_color.dart';

/// 排便记录数据模型
class PoopRecord {
  /// 唯一标识
  final String id;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 颜色选项
  final PoopColor poopColor;

  /// 自定义颜色描述（当 poopColor == custom 时使用）
  final String? customColor;

  /// 布里斯托分级 (1-7 or custom)
  final BristolScale bristolScale;

  /// 自定义类型描述（当 bristolScale == custom 时使用）
  final String? customType;

  /// 排便量
  final PoopAmount amount;

  /// 自定义量描述（当 amount == custom 时使用）
  final String? customAmount;

  PoopRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.poopColor = PoopColor.normal,
    this.customColor,
    required this.bristolScale,
    this.customType,
    required this.amount,
    this.customAmount,
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

  /// 获取类型显示文本
  String get typeDisplayText {
    if (bristolScale.isCustom && customType != null && customType!.isNotEmpty) {
      return customType!;
    }
    return bristolScale.shortDescription;
  }

  /// 获取量显示文本
  String get amountDisplayText {
    if (amount.isCustom && customAmount != null && customAmount!.isNotEmpty) {
      return customAmount!;
    }
    return amount.label;
  }

  /// 获取颜色显示文本
  String get colorDisplayText {
    if (poopColor.isCustom && customColor != null && customColor!.isNotEmpty) {
      return customColor!;
    }
    return poopColor.label;
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'poopColor': poopColor.index,
      'customColor': customColor,
      'bristolScale': bristolScale.index,
      'customType': customType,
      'amount': amount.index,
      'customAmount': customAmount,
    };
  }

  /// 从 JSON 转换
  factory PoopRecord.fromJson(Map<String, dynamic> json) {
    return PoopRecord(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      poopColor: json['poopColor'] != null
          ? PoopColor.values[json['poopColor'] as int]
          : PoopColor.normal,
      customColor: json['customColor'] as String?,
      bristolScale: BristolScale.values[json['bristolScale'] as int],
      customType: json['customType'] as String?,
      amount: PoopAmount.values[json['amount'] as int],
      customAmount: json['customAmount'] as String?,
    );
  }

  /// 创建副本
  PoopRecord copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    PoopColor? poopColor,
    String? customColor,
    BristolScale? bristolScale,
    String? customType,
    PoopAmount? amount,
    String? customAmount,
  }) {
    return PoopRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      poopColor: poopColor ?? this.poopColor,
      customColor: customColor ?? this.customColor,
      bristolScale: bristolScale ?? this.bristolScale,
      customType: customType ?? this.customType,
      amount: amount ?? this.amount,
      customAmount: customAmount ?? this.customAmount,
    );
  }
}

/// 排便量枚举
enum PoopAmount {
  small,
  normal,
  large,
  custom;

  /// Whether this is a custom amount
  bool get isCustom => this == custom;

  /// 显示文本
  String get label {
    switch (this) {
      case PoopAmount.small:
        return '少量';
      case PoopAmount.normal:
        return '正常';
      case PoopAmount.large:
        return '大量';
      case PoopAmount.custom:
        return '自定义';
    }
  }
}
