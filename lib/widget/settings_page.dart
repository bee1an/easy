import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';

/// 设置页面 - Duolingo 风格
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _todayController;
  late AnimationController _weekController;
  late AnimationController _monthController;

  @override
  void initState() {
    super.initState();
    _todayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _weekController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _monthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 延迟启动数字滚动动画
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _todayController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _weekController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _monthController.forward();
      }
    });
  }

  @override
  void dispose() {
    _todayController.dispose();
    _weekController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PoopProvider>(
      builder: (context, provider, child) {
        final todayCount = provider.getTodayCount();
        final weekCount = provider.getWeekCount();
        final monthCount = provider.getMonthCount();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '设置',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 统计卡片 - 数字滚动动画
              _StatsCards(
                todayCount: todayCount,
                weekCount: weekCount,
                monthCount: monthCount,
                todayController: _todayController,
                weekController: _weekController,
                monthController: _monthController,
              ),

              const SizedBox(height: 24),

              // 数据管理
              _SectionCard(
                title: '数据管理',
                icon: Icons.storage_rounded,
                children: [
                  _SettingTile(
                    icon: Icons.download_rounded,
                    title: '导出数据',
                    subtitle: '将记录导出为 JSON 格式',
                    onTap: () => _exportData(context, provider),
                  ),
                  _SettingTile(
                    icon: Icons.delete_forever_rounded,
                    title: '清空数据',
                    subtitle: '删除所有记录（不可恢复）',
                    onTap: () => _confirmClearAll(context, provider),
                    isDestructive: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 关于
              _SectionCard(
                title: '关于',
                icon: Icons.info_rounded,
                children: [
                  _SettingTile(
                    icon: Icons.apps_rounded,
                    title: '应用版本',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _exportData(BuildContext context, PoopProvider provider) async {
    try {
      final json = await provider.exportData();
      final formattedJson =
          const JsonEncoder.withIndent('  ').convert(jsonDecode(json));

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => _ExportDialog(data: formattedJson),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败：$e'),
            backgroundColor: const Color(0xFFFF4B4B),
          ),
        );
      }
    }
  }

  void _confirmClearAll(BuildContext context, PoopProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '确认清空',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('确定要删除所有记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              '取消',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearAll();
              if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('所有数据已清空'),
                      ],
                    ),
                    backgroundColor: Color(0xFF58CC02),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF4B4B)),
            child: const Text(
              '确认删除',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// 统计卡片 - Duolingo 风格 + 数字滚动
class _StatsCards extends StatelessWidget {
  final int todayCount;
  final int weekCount;
  final int monthCount;
  final AnimationController todayController;
  final AnimationController weekController;
  final AnimationController monthController;

  const _StatsCards({
    required this.todayCount,
    required this.weekCount,
    required this.monthCount,
    required this.todayController,
    required this.weekController,
    required this.monthController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnimatedStatCard(
            label: '今日',
            count: todayCount,
            controller: todayController,
            color: const Color(0xFF58CC02),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnimatedStatCard(
            label: '本周',
            count: weekCount,
            controller: weekController,
            color: const Color(0xFF1CB0F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnimatedStatCard(
            label: '本月',
            count: monthCount,
            controller: monthController,
            color: const Color(0xFFFF9600),
          ),
        ),
      ],
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final String label;
  final int count;
  final AnimationController controller;
  final Color color;

  const _AnimatedStatCard({
    required this.label,
    required this.count,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animatedValue = controller.value * count;
        final displayValue = animatedValue.ceil().clamp(0, count);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                displayValue.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 分组卡片 - Duolingo 风格
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF58CC02),
                size: 22,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF3C3C3C),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            dense: true,
          ),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          ...children,
        ],
      ),
    );
  }
}

/// 设置项 - Duolingo 风格
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive
        ? const Color(0xFFFF4B4B)
        : const Color(0xFF3C3C3C);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive
                  ? const Color(0xFFFFE6E6)
                  : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 13,
            ),
          ),
          trailing: onTap != null
              ? const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFE5E5E5),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
      ),
    );
  }
}

/// 导出对话框 - Duolingo 风格
class _ExportDialog extends StatelessWidget {
  final String data;

  const _ExportDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
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
                    Icons.code_rounded,
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
                        '导出数据',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                      const Text(
                        'JSON 格式',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 数据内容
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    data,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFF3C3C3C),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 关闭按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '关闭',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
