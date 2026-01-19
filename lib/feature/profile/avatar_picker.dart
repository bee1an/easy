import 'package:flutter/material.dart';
import 'package:easy/core/constants/avatars.dart';
import 'package:easy/core/theme/app_theme.dart';

/// Avatar picker dialog for selecting preset avatars
class AvatarPicker extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const AvatarPicker({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  /// Show avatar picker dialog
  static Future<int?> show(BuildContext context, {int currentIndex = 0}) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AvatarPicker(
        currentIndex: currentIndex,
        onSelected: (index) => Navigator.of(context).pop(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMutedColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '选择头像',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // Avatar grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: Avatars.count,
                itemBuilder: (context, index) => _AvatarItem(
                  index: index,
                  isSelected: index == currentIndex,
                  onTap: () => onSelected(index),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Single avatar item in the grid
class _AvatarItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarItem({
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.15) : null,
        ),
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          Avatars.getPath(index),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppTheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, size: 40, color: AppTheme.primary),
          ),
        ),
      ),
    );
  }
}
