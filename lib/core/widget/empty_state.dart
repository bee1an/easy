import 'package:flutter/material.dart';
import 'package:easy/core/theme/app_theme.dart';

/// Empty State Widget - Friendly guidance with illustration
///
/// Provides a visually appealing empty state with:
/// - Illustration or icon
/// - Title and description
/// - Optional action button
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;

  const EmptyState({
    super.key,
    this.icon,
    this.imagePath,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.iconSize = 80,
    this.iconColor,
  });

  /// Empty state for no records
  factory EmptyState.noRecords({
    String title = '暂无记录',
    String description = '点击下方按钮开始记录',
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: Icons.inbox_rounded,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// Empty state for no data
  factory EmptyState.noData({
    String title = '暂无数据',
    String description = '数据将在这里显示',
  }) {
    return EmptyState(
      icon: Icons.analytics_outlined,
      title: title,
      description: description,
    );
  }

  /// Empty state for search with no results
  factory EmptyState.noResults({
    String title = '未找到结果',
    String description = '尝试调整搜索条件',
  }) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: title,
      description: description,
    );
  }

  /// Empty state for loading error
  factory EmptyState.error({
    String title = '加载失败',
    String description = '请检查网络后重试',
    String? actionText,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: title,
      description: description,
      actionText: actionText ?? '重试',
      onAction: onRetry,
      iconColor: AppTheme.error,
    );
  }

  /// Empty state for first time users
  factory EmptyState.welcome({
    required String moduleName,
    required VoidCallback onStart,
  }) {
    return EmptyState(
      icon: Icons.celebration_rounded,
      title: '欢迎使用$moduleName',
      description: '开始记录你的健康数据吧',
      actionText: '开始记录',
      onAction: onStart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration / Icon
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: iconSize,
                height: iconSize,
                color: isDark ? Colors.white70 : null,
              )
            else if (icon != null)
              Container(
                width: iconSize + 40,
                height: iconSize + 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: (iconColor ?? AppTheme.primary).withValues(alpha: 0.6),
                ),
              ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMutedColor(context),
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor ?? AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact empty state for inline use (e.g., in lists)
class EmptyStateCompact extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? iconColor;

  const EmptyStateCompact({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? AppTheme.textMutedColor(context),
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
