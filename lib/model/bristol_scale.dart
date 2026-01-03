/// Bristol Stool Scale (布里斯托大便分类法)
///
/// A medical classification for stool forms, with 7 standard types + custom
enum BristolScale {
  type1,
  type2,
  type3,
  type4,
  type5,
  type6,
  type7,
  custom;

  /// Type number (1-7, 0 for custom)
  int get typeNumber => this == custom ? 0 : index + 1;

  /// Whether this is a custom type
  bool get isCustom => this == custom;

  /// Description
  String get description {
    switch (this) {
      case BristolScale.type1:
        return '坚硬的块状，像坚果，很难排出';
      case BristolScale.type2:
        return '香肠状，但凹凸不平';
      case BristolScale.type3:
        return '香肠状，表面有裂纹';
      case BristolScale.type4:
        return '像香肠或蛇，光滑柔软';
      case BristolScale.type5:
        return '柔软的块状，边缘清晰';
      case BristolScale.type6:
        return '蓬松的糊状，边缘破碎';
      case BristolScale.type7:
        return '完全液体，无固体块';
      case BristolScale.custom:
        return '自定义类型';
    }
  }

  /// Short description
  String get shortDescription {
    switch (this) {
      case BristolScale.type1:
        return '严重便秘';
      case BristolScale.type2:
        return '轻度便秘';
      case BristolScale.type3:
        return '正常偏干';
      case BristolScale.type4:
        return '正常';
      case BristolScale.type5:
        return '正常偏稀';
      case BristolScale.type6:
        return '轻度腹泻';
      case BristolScale.type7:
        return '严重腹泻';
      case BristolScale.custom:
        return '自定义';
    }
  }

  /// Display label
  String get label => isCustom ? '自定义' : 'Type $typeNumber - $shortDescription';
}
