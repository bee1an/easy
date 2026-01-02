/// 布里斯托大便分类法 (Bristol Stool Scale)
///
/// 一种医学上用于分类大便形态的量表，分为 7 个级别
enum BristolScale {
  type1,
  type2,
  type3,
  type4,
  type5,
  type6,
  type7;

  /// 类型编号
  int get typeNumber => index + 1;

  /// 描述
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
    }
  }

  /// 简短描述
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
    }
  }

  /// 显示文本
  String get label => 'Type $typeNumber - $shortDescription';
}
