import 'package:flutter/material.dart';
import 'package:easy/core/theme/app_theme.dart';

/// Unified heatmap color system
/// Ensures consistency between Flutter app and iOS Widget
class HeatmapColors {
  HeatmapColors._();

  /// Opacity levels for heatmap cells (0-4)
  /// Must match values in EasyWidget.swift
  static const List<double> opacityLevels = [0.0, 0.3, 0.6, 0.85, 1.0];

  /// Get heatmap cell color based on count
  static Color getColor(BuildContext context, int count) {
    if (count <= 0) return AppTheme.dividerColor(context);

    final level = count.clamp(1, 4);
    return AppTheme.primary.withValues(alpha: opacityLevels[level]);
  }

  /// Get heatmap cell color for future dates
  static Color getFutureColor(BuildContext context) {
    return AppTheme.dividerColor(context).withValues(alpha: 0.5);
  }
}
