/// Poop color options
///
/// Provides predefined color options based on medical standards:
/// - Normal (healthy brown)
/// - Black (may indicate bleeding)
/// - Dark brown
/// - Light brown
/// - Yellow
/// - Green
/// - Red (visible blood)
/// - Custom (user-defined)
enum PoopColor {
  normal,
  black,
  darkBrown,
  lightBrown,
  yellow,
  green,
  red,
  custom;

  /// Whether this is a custom color
  bool get isCustom => this == custom;

  /// Display label (Chinese)
  String get label {
    switch (this) {
      case PoopColor.normal:
        return '正常棕色';
      case PoopColor.black:
        return '黑色';
      case PoopColor.darkBrown:
        return '深棕色';
      case PoopColor.lightBrown:
        return '浅棕色';
      case PoopColor.yellow:
        return '黄色';
      case PoopColor.green:
        return '绿色';
      case PoopColor.red:
        return '红色';
      case PoopColor.custom:
        return '自定义';
    }
  }

  /// Short label for compact display
  String get shortLabel {
    switch (this) {
      case PoopColor.normal:
        return '正常';
      case PoopColor.black:
        return '黑';
      case PoopColor.darkBrown:
        return '深棕';
      case PoopColor.lightBrown:
        return '浅棕';
      case PoopColor.yellow:
        return '黄';
      case PoopColor.green:
        return '绿';
      case PoopColor.red:
        return '红';
      case PoopColor.custom:
        return '自定义';
    }
  }

  /// Visual color representation
  int get colorValue {
    switch (this) {
      case PoopColor.normal:
        return 0xFF8B4513; // Saddle brown
      case PoopColor.black:
        return 0xFF1A1A1A;
      case PoopColor.darkBrown:
        return 0xFF5D3A1A;
      case PoopColor.lightBrown:
        return 0xFFB5835A;
      case PoopColor.yellow:
        return 0xFFD4A017;
      case PoopColor.green:
        return 0xFF4A7C4E;
      case PoopColor.red:
        return 0xFFC53030;
      case PoopColor.custom:
        return 0xFF888888;
    }
  }

  /// Medical note for concerning colors
  String? get medicalNote {
    switch (this) {
      case PoopColor.black:
        return '可能含有消化道上部出血';
      case PoopColor.red:
        return '可能含有鲜血';
      default:
        return null;
    }
  }
}
