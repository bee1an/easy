import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/auth_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:easy/core/constants/avatars.dart';
import 'package:easy/feature/profile/avatar_picker.dart';

/// Profile Page - "我的" tab
///
/// Contains:
/// - Account info at top
/// - Statistics entry
/// - Settings entry
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Account Card
            _buildAccountCard(context),

            const SizedBox(height: 24),

            // Statistics Entry
            _buildMenuTile(
              context,
              icon: Icons.insights_rounded,
              title: '统计分析',
              subtitle: '查看详细数据和趋势图表',
              onTap: () => AppRouter.push(context, AppRouter.stats),
            ),

            const SizedBox(height: 12),

            // Settings Entry
            _buildMenuTile(
              context,
              icon: Icons.settings_rounded,
              title: '设置',
              subtitle: '外观、关于',
              onTap: () => AppRouter.push(context, AppRouter.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userEmail = authProvider.userEmail ?? '';
        final avatarId = authProvider.avatarId;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Avatar - tappable to change
              GestureDetector(
                onTap: () => _onAvatarTap(context, authProvider, avatarId),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Image.asset(
                        Avatars.getPath(avatarId),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              userEmail.isNotEmpty
                                  ? userEmail[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Edit indicator
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.cardColor(context),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Email info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('已登录', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onAvatarTap(
    BuildContext context,
    AuthProvider authProvider,
    int currentAvatarId,
  ) async {
    final newAvatarId = await AvatarPicker.show(
      context,
      currentIndex: currentAvatarId,
    );

    if (newAvatarId != null && newAvatarId != currentAvatarId) {
      final success = await authProvider.updateAvatar(newAvatarId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('头像已更新'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
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
}
