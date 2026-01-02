import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/model/poop_record.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:intl/intl.dart';

/// History Page - Record List
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('历史记录'),
      ),
      body: Consumer<PoopProvider>(
        builder: (context, provider, child) {
          final records = provider.records;

          if (records.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[records.length - 1 - index];
              return _RecordItem(
                record: record,
                onDelete: () => provider.deleteRecord(record.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            '暂无记录',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Text('开始记录你的健康数据吧', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RecordItem extends StatelessWidget {
  final PoopRecord record;
  final VoidCallback onDelete;

  const _RecordItem({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('M月d日 HH:mm', 'zh_CN').format(record.startTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // Type indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${record.bristolScale.typeNumber}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      text: record.durationText,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.water_drop_outlined,
                      text: record.amount.label,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: Icon(Icons.delete_outline_rounded, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
            child: Text('删除', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
