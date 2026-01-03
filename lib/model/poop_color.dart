/// Poop color options
enum PoopColor {
  normal,
  custom;

  /// Whether this is a custom color
  bool get isCustom => this == custom;

  /// Display label
  String get label {
    switch (this) {
      case PoopColor.normal:
        return '正常';
      case PoopColor.custom:
        return '自定义';
    }
  }
}
