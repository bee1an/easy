import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/theme_provider.dart';
import 'package:easy/provider/auth_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:easy/core/constants/build_info.dart';

/// Settings Page
///
/// Contains:
/// - Module management entries (poop, diet, exercise)
/// - Statistics entry
/// - Social area (follow friends) - placeholder
/// - Account status (login/logout)
/// - Appearance (dark mode)
/// - About
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Module Management Section
          _buildSectionTitle(context, '健康模块'),
          const SizedBox(height: 12),
          _buildModuleSection(context),

          const SizedBox(height: 24),

          // Statistics Section
          _buildSectionTitle(context, '数据分析'),
          const SizedBox(height: 12),
          _buildNavigationTile(
            context,
            icon: Icons.bar_chart_rounded,
            title: '统计分析',
            subtitle: '查看趋势和分布数据',
            onTap: () => AppRouter.push(context, AppRouter.stats),
          ),

          const SizedBox(height: 24),

          // Social Section
          _buildSectionTitle(context, '社交'),
          const SizedBox(height: 12),
          _buildNavigationTile(
            context,
            icon: Icons.people_outline_rounded,
            title: '关注好友',
            subtitle: '与好友分享健康数据',
            onTap: () => AppRouter.push(context, AppRouter.follow),
          ),

          const SizedBox(height: 24),

          // Account Section
          _buildSectionTitle(context, '账户'),
          const SizedBox(height: 12),
          _buildAccountTile(context),

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
            subtitle: '版本 1.0.0 · 更新于 $kBuildTime',
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          _buildModuleTile(
            context,
            icon: Icons.spa_rounded,
            iconColor: AppTheme.primary,
            title: '排便记录',
            subtitle: '管理排便健康数据',
            onTap: () => AppRouter.push(context, AppRouter.poop),
            showDivider: true,
          ),
          _buildModuleTile(
            context,
            icon: Icons.restaurant_rounded,
            iconColor: AppTheme.secondary,
            title: '饮食记录',
            subtitle: '即将推出',
            enabled: false,
            showDivider: true,
          ),
          _buildModuleTile(
            context,
            icon: Icons.directions_run_rounded,
            iconColor: AppTheme.accent,
            title: '运动记录',
            subtitle: '即将推出',
            enabled: false,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool enabled = true,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: showDivider
                ? null
                : const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: enabled
                                    ? null
                                    : AppTheme.textMutedColor(context),
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textMutedColor(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (enabled)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMutedColor(context),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 66, color: AppTheme.borderColor(context)),
      ],
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = false,
    String? badgeText,
  }) {
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
              Icon(icon, color: AppTheme.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (showBadge && badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
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

  Widget _buildAccountTile(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoggedIn = authProvider.isLoggedIn;
        final userEmail = authProvider.userEmail;

        if (isLoggedIn) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor(context)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_circle_rounded, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '已登录',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _confirmSignOut(context, authProvider),
                  child: const Text('退出'),
                ),
              ],
            ),
          );
        }

        // Not logged in (should not happen with forced login)
        return _buildSettingTile(
          context,
          icon: Icons.account_circle_outlined,
          title: '登录',
          subtitle: '登录以同步数据',
        );
      },
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('退出后需要重新登录才能使用'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await authProvider.signOut();
            },
            child: const Text('退出'),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textPrimaryColor(context), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
