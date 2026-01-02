import 'package:flutter/material.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/model/bristol_scale.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/feature/home/widgets/star_animation.dart';

/// Record Dialog - Premium Minimal Style
class RecordDialog extends StatefulWidget {
  final TimerProvider timerProvider;

  const RecordDialog({super.key, required this.timerProvider});

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  BristolScale _selectedScale = BristolScale.type4;
  PoopAmount _selectedAmount = PoopAmount.medium;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    // Save record
    widget.timerProvider.saveRecord(
      bristolScale: _selectedScale,
      amount: _selectedAmount,
    );

    // Close dialog first
    Navigator.of(context).pop();

    // Trigger star animation after dialog closes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        StarFlyAnimation.trigger(context);
      }
    });
  }

  void _cancel() {
    widget.timerProvider.cancelTimer();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                  Text('记录详情', style: Theme.of(context).textTheme.titleLarge),
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
                      widget.timerProvider.elapsedText,
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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
                        onChanged: (scale) =>
                            setState(() => _selectedScale = scale),
                      ),

                      const SizedBox(height: 20),

                      // Amount
                      Text('量', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      _AmountSelector(
                        selected: _selectedAmount,
                        onChanged: (amount) =>
                            setState(() => _selectedAmount = amount),
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

/// Bristol Scale Selector
class _BristolSelector extends StatelessWidget {
  final BristolScale selected;
  final ValueChanged<BristolScale> onChanged;

  const _BristolSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: BristolScale.values.map((scale) {
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
      }).toList(),
    );
  }
}

/// Amount Selector
class _AmountSelector extends StatelessWidget {
  final PoopAmount selected;
  final ValueChanged<PoopAmount> onChanged;

  const _AmountSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PoopAmount.values.asMap().entries.map((entry) {
        final index = entry.key;
        final amount = entry.value;
        final isSelected = amount == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(amount),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  amount.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
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
