import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/provider/theme_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';

/// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('设置'),
      ),
      body: Consumer<PoopProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Stats
              _buildStatsCard(context, provider),

              const SizedBox(height: 24),

              // Data Section
              _buildSectionTitle(context, '数据管理'),
              const SizedBox(height: 12),
              _buildSettingTile(
                context,
                icon: Icons.upload_rounded,
                title: '导出数据',
                subtitle: '复制 JSON 格式数据',
                onTap: () => _exportData(context, provider),
              ),
              const SizedBox(height: 8),
              _buildSettingTile(
                context,
                icon: Icons.delete_forever_rounded,
                title: '清除所有数据',
                subtitle: '此操作不可恢复',
                isDestructive: true,
                onTap: () => _confirmClearAll(context, provider),
              ),

              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionTitle(context, '外观'),
              const SizedBox(height: 12),
              _buildThemeToggle(context),

              const SizedBox(height: 24),

              // About
              _buildSectionTitle(context, '关于'),
              const SizedBox(height: 12),
              _buildSettingTile(
                context,
                icon: Icons.info_outline_rounded,
                title: 'Easy',
                subtitle: '版本 1.0.0',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, PoopProvider provider) {
    final totalRecords = provider.records.length;
    final streak = provider.getStreak();
    final longestStreak = provider.getLongestStreak();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('统计概览', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatItem(value: '$totalRecords', label: '总记录'),
              _StatItem(value: '$streak', label: '当前连续'),
              _StatItem(value: '$longestStreak', label: '最长连续'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(color: AppTheme.textMutedColor(context)),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkBorder
                  : AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                themeProvider.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('深色模式', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      themeProvider.isDark ? '已开启' : '已关闭',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeTrackColor: AppTheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppTheme.error
        : AppTheme.textPrimaryColor(context);

    return Material(
      color: AppTheme.cardColor(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMutedColor(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportData(BuildContext context, PoopProvider provider) {
    final data = provider.records.map((r) => r.toJson()).toList();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    Clipboard.setData(ClipboardData(text: jsonStr));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制 ${provider.records.length} 条记录'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmClearAll(BuildContext context, PoopProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('此操作将删除所有记录，且无法恢复。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已清除所有数据'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('清除', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
