import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/model/poop_color.dart';
import 'package:easy/model/bristol_scale.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/feature/home/widgets/star_animation.dart';
import 'package:intl/intl.dart';

/// Record Dialog - Premium Minimal Style
class RecordDialog extends StatefulWidget {
  final TimerProvider timerProvider;
  final PoopRecord? initialRecord;
  final Function(PoopRecord)? onUpdate;

  const RecordDialog({
    super.key,
    required this.timerProvider,
    this.initialRecord,
    this.onUpdate,
  });

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  late BristolScale _selectedScale;
  late PoopAmount _selectedAmount;
  late PoopColor _selectedColor;
  late DateTime _startTime;
  late DateTime _endTime;

  final TextEditingController _customTypeController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _customColorController = TextEditingController();

  bool get _isEditMode => widget.initialRecord != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final record = widget.initialRecord!;
      _selectedScale = record.bristolScale;
      _selectedAmount = record.amount;
      _selectedColor = record.poopColor;
      _startTime = record.startTime;
      _endTime = record.endTime;
      _customTypeController.text = record.customType ?? '';
      _customAmountController.text = record.customAmount ?? '';
      _customColorController.text = record.customColor ?? '';
    } else {
      _selectedScale = BristolScale.type4;
      _selectedAmount = PoopAmount.normal;
      _selectedColor = PoopColor.normal;
      _startTime = widget.timerProvider.startTime ?? DateTime.now();
      _endTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _customTypeController.dispose();
    _customAmountController.dispose();
    _customColorController.dispose();
    super.dispose();
  }

  String get _durationText {
    final diff = _endTime.difference(_startTime);
    final minutes = diff.inMinutes;
    if (minutes < 60) return '$minutes分钟';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '$hours小时$mins分钟' : '$hours小时';
  }

  Future<void> _selectTime(bool isStart) async {
    final now = isStart ? _startTime : _endTime;

    await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: AppTheme.cardColor(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('完成'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: now,
                use24hFormat: true,
                onDateTimeChanged: (newDateTime) {
                  setState(() {
                    if (isStart) {
                      _startTime = newDateTime;
                      // Ensure end time is not before start time
                      if (_endTime.isBefore(_startTime)) {
                        _endTime = _startTime.add(const Duration(minutes: 5));
                      }
                    } else {
                      _endTime = newDateTime;
                      // Ensure start time is not after end time
                      if (_startTime.isAfter(_endTime)) {
                        _startTime = _endTime.subtract(
                          const Duration(minutes: 5),
                        );
                      }
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_isEditMode) {
      final updatedRecord = widget.initialRecord!.copyWith(
        startTime: _startTime,
        endTime: _endTime,
        bristolScale: _selectedScale,
        customType: _selectedScale.isCustom ? _customTypeController.text : null,
        amount: _selectedAmount,
        customAmount: _selectedAmount.isCustom
            ? _customAmountController.text
            : null,
        poopColor: _selectedColor,
        customColor: _selectedColor.isCustom
            ? _customColorController.text
            : null,
      );
      widget.onUpdate?.call(updatedRecord);
    } else {
      widget.timerProvider.saveRecord(
        startTime: _startTime,
        endTime: _endTime,
        endTracking: true,
        bristolScale: _selectedScale,
        customType: _selectedScale.isCustom ? _customTypeController.text : null,
        amount: _selectedAmount,
        customAmount: _selectedAmount.isCustom
            ? _customAmountController.text
            : null,
        poopColor: _selectedColor,
        customColor: _selectedColor.isCustom
            ? _customColorController.text
            : null,
      );
    }

    Navigator.of(context).pop();

    if (!_isEditMode) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          StarFlyAnimation.trigger(context);
        }
      });
    }
  }

  void _cancel() {
    if (!_isEditMode) {
      widget.timerProvider.cancelTimer();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    _isEditMode ? '修改记录' : '记录详情',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _durationText,
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Time Editor
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TimeItem(
                        label: '开始',
                        time: _startTime,
                        onTap: () => _selectTime(true),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.borderColor(context),
                    ),
                    Expanded(
                      child: _TimeItem(
                        label: '结束',
                        time: _endTime,
                        onTap: () => _selectTime(false),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bristol Scale
                      Text('类型', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      _BristolSelector(
                        selected: _selectedScale,
                        customController: _customTypeController,
                        onChanged: (scale) =>
                            setState(() => _selectedScale = scale),
                      ),

                      const SizedBox(height: 20),

                      // Amount
                      Text('量', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      _AmountSelector(
                        selected: _selectedAmount,
                        customController: _customAmountController,
                        onChanged: (amount) =>
                            setState(() => _selectedAmount = amount),
                      ),

                      const SizedBox(height: 20),

                      // Color
                      Text('颜色', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      _ColorSelector(
                        selected: _selectedColor,
                        customController: _customColorController,
                        onChanged: (color) =>
                            setState(() => _selectedColor = color),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _cancel,
                      child: Text(
                        '取消',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      key: AnimationKeys.saveButtonKey,
                      onPressed: _submit,
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeItem extends StatelessWidget {
  final String label;
  final DateTime time;
  final VoidCallback onTap;

  const _TimeItem({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(time),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Bristol Scale Selector
class _BristolSelector extends StatelessWidget {
  final BristolScale selected;
  final TextEditingController customController;
  final ValueChanged<BristolScale> onChanged;

  const _BristolSelector({
    required this.selected,
    required this.customController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Standard types (1-7)
        ...BristolScale.values.where((s) => !s.isCustom).map((scale) {
          final isSelected = scale == selected;
          return GestureDetector(
            onTap: () => onChanged(scale),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppTheme.textMuted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${scale.typeNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      scale.shortDescription,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }),

        // Custom type option
        _buildCustomOption(
          context: context,
          isSelected: selected.isCustom,
          label: '自定义',
          controller: customController,
          hintText: '输入自定义类型',
          onTap: () => onChanged(BristolScale.custom),
        ),
      ],
    );
  }

  Widget _buildCustomOption({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.divider,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.textMuted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isSelected
                  ? TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Amount Selector
class _AmountSelector extends StatelessWidget {
  final PoopAmount selected;
  final TextEditingController customController;
  final ValueChanged<PoopAmount> onChanged;

  const _AmountSelector({
    required this.selected,
    required this.customController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final standardAmounts = PoopAmount.values
        .where((a) => !a.isCustom)
        .toList();

    return Column(
      children: [
        // Standard amounts row
        Row(
          children: standardAmounts.asMap().entries.map((entry) {
            final index = entry.key;
            final amount = entry.value;
            final isSelected = amount == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(amount),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(
                    right: index < standardAmounts.length - 1 ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      amount.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Custom amount option
        _buildCustomRow(
          context: context,
          isSelected: selected.isCustom,
          controller: customController,
          hintText: '输入自定义量',
          onTap: () => onChanged(PoopAmount.custom),
        ),
      ],
    );
  }

  Widget _buildCustomRow({
    required BuildContext context,
    required bool isSelected,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.divider,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.edit_rounded,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isSelected
                  ? TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(
                      '自定义',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Color Selector
class _ColorSelector extends StatelessWidget {
  final PoopColor selected;
  final TextEditingController customController;
  final ValueChanged<PoopColor> onChanged;

  const _ColorSelector({
    required this.selected,
    required this.customController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Normal option
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(PoopColor.normal),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected == PoopColor.normal
                    ? AppTheme.primary
                    : AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '正常',
                  style: TextStyle(
                    color: selected == PoopColor.normal
                        ? Colors.white
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Custom option
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(PoopColor.custom),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: selected.isCustom ? AppTheme.primary : AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: selected.isCustom
                  ? TextField(
                      controller: customController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: '输入颜色',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Center(
                      child: Text(
                        '自定义',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
