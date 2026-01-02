import 'package:flutter/material.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/model/bristol_scale.dart';

/// 记录表单对话框 - Duolingo 风格
class RecordFormDialog extends StatefulWidget {
  final TimerProvider timerProvider;

  const RecordFormDialog({
    super.key,
    required this.timerProvider,
  });

  @override
  State<RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<RecordFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _colorController = TextEditingController();
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  BristolScale _selectedBristolScale = BristolScale.type4;
  PoopAmount _selectedAmount = PoopAmount.medium;

  @override
  void initState() {
    super.initState();

    // 创建弹性进入动画
    _dialogController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogController,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogController,
        curve: Curves.easeOut,
      ),
    );

    // 启动动画
    _dialogController.forward();
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 验证通过，保存记录
      final colorText = _colorController.text.trim();
      widget.timerProvider.saveRecord(
        color: colorText.isEmpty ? null : colorText,
        bristolScale: _selectedBristolScale,
        amount: _selectedAmount,
      );
      Navigator.of(context).pop();

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('记录已保存！')),
            ],
          ),
          backgroundColor: const Color(0xFF58CC02),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancel() {
    widget.timerProvider.cancelTimer();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF58CC02),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_note_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '记录详情',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF3C3C3C),
                                  ),
                                ),
                                Text(
                                  '本次时长：${widget.timerProvider.elapsedText}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF777777),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 排便颜色（可选）
                      Text(
                        '颜色（可选）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _colorController,
                        decoration: InputDecoration(
                          hintText: '例如：黄褐色、棕色等',
                          prefixIcon: Icon(Icons.palette_outlined),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final trimmed = value.trim();
                            if (trimmed.length > 20) {
                              return '颜色描述不能超过20个字符';
                            }
                            final hasInvalidChars =
                                RegExp(r'[^\u4e00-\u9fa5a-zA-Z0-9\s]')
                                    .hasMatch(trimmed);
                            if (hasInvalidChars) {
                              return '只能输入中文、英文或数字';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // 布里斯托分级
                      Text(
                        '干稀程度',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BristolScaleSelector(
                        selectedScale: _selectedBristolScale,
                        onChanged: (scale) =>
                            setState(() => _selectedBristolScale = scale),
                      ),

                      const SizedBox(height: 20),

                      // 排便量
                      Text(
                        '排便量',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AmountSelector(
                        selectedAmount: _selectedAmount,
                        onChanged: (amount) =>
                            setState(() => _selectedAmount = amount),
                      ),

                      const SizedBox(height: 24),

                      // 操作按钮
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _cancel,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                '取消',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _build3DButton(
                              onPressed: _submit,
                              text: '保存记录',
                              color: const Color(0xFF58CC02),
                              shadowColor: const Color(0xFF58A700),
                              highlightColor: const Color(0xFF89E219),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建 3D 按钮
  Widget _build3DButton({
    required VoidCallback onPressed,
    required String text,
    required Color color,
    required Color shadowColor,
    required Color highlightColor,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      onTapUp: (_) {
        setState(() {});
        onPressed();
      },
      onTapCancel: () => setState(() {}),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            BoxShadow(
              color: highlightColor,
              offset: const Offset(0, -2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// 布里斯托分级选择器 - Duolingo 风格
class _BristolScaleSelector extends StatelessWidget {
  final BristolScale selectedScale;
  final ValueChanged<BristolScale> onChanged;

  const _BristolScaleSelector({
    required this.selectedScale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BristolScale.values.map((scale) {
        final isSelected = selectedScale == scale;
        return InkWell(
          onTap: () => onChanged(scale),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF58CC02)
                  : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF58CC02)
                    : const Color(0xFFE5E5E5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type ${scale.typeNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF3C3C3C),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scale.shortDescription,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white70
                        : const Color(0xFF777777),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 排便量选择器 - Duolingo 风格
class _AmountSelector extends StatelessWidget {
  final PoopAmount selectedAmount;
  final ValueChanged<PoopAmount> onChanged;

  const _AmountSelector({
    required this.selectedAmount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PoopAmount.values.map((amount) {
        final isSelected = selectedAmount == amount;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: amount != PoopAmount.large ? 8 : 0,
            ),
            child: InkWell(
              onTap: () => onChanged(amount),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1CB0F6)
                      : const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1CB0F6)
                        : const Color(0xFFE5E5E5),
                    width: 2,
                  ),
                ),
                child: Text(
                  amount.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF3C3C3C),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
