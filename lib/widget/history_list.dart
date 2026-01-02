import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/model/poop_record.dart';
import 'package:intl/intl.dart';

/// 历史记录列表 - Duolingo 风格
class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PoopProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF58CC02),
            ),
          );
        }

        if (provider.records.isEmpty) {
          return const _EmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            _buildHeader(context),

            // 记录列表
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.records.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final record = provider.records[index];
                return _RecordCard(
                  key: ValueKey(record.id),
                  record: record,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1CB0F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '历史记录',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 48,
                color: Color(0xFFE5E5E5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '暂无记录',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF3C3C3C),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击上方按钮开始记录',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF777777),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 记录卡片 - Duolingo 风格
class _RecordCard extends StatefulWidget {
  final PoopRecord record;

  const _RecordCard({super.key, required this.record});

  @override
  State<_RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<_RecordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: Dismissible(
              key: ValueKey(widget.record.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                await context.read<PoopProvider>().deleteRecord(widget.record.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text('记录已删除'),
                        ],
                      ),
                      backgroundColor: Color(0xFFFF4B4B),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4B4B),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              child: GestureDetector(
                onLongPress: () => _showQuickActions(context),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E5E5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF58CC02).withValues(
                            alpha: _isHovered ? 0.15 : 0.08),
                        blurRadius: _isHovered ? 20 : 12,
                        offset: Offset(0, _isHovered ? 6 : 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showDetails(context, widget.record),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 顶部栏：日期和时间
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatDate(widget.record.startTime),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3C3C3C),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F7F7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: Color(0xFF777777),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatTime(widget.record.startTime),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 时长
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF58CC02),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.timer_outlined,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.record.durationText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3C3C3C),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 分级和量
                            Row(
                              children: [
                                _buildInfoChip(
                                  label:
                                      'T${widget.record.bristolScale.typeNumber}',
                                  icon: Icons.grain_rounded,
                                  color: const Color(0xFF1CB0F6),
                                ),
                                const SizedBox(width: 10),
                                _buildInfoChip(
                                  label: widget.record.amount.label,
                                  icon: Icons.crop_square_rounded,
                                  color: const Color(0xFF58CC02),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, PoopRecord record) {
    showDialog(
      context: context,
      builder: (context) => _RecordDetailDialog(record: record),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.visibility_rounded,
                    color: Color(0xFF1CB0F6)),
                title: const Text(
                  '查看详情',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDetails(context, widget.record);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded,
                    color: Color(0xFFFF4B4B)),
                title: const Text(
                  '删除记录',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '确认删除',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('确定要删除这条记录吗？此操作不可恢复。'),
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
              await context
                  .read<PoopProvider>()
                  .deleteRecord(widget.record.id);
              if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('记录已删除'),
                      ],
                    ),
                    backgroundColor: Color(0xFFFF4B4B),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFFFF4B4B)),
            child: const Text(
              '删除',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) return '今天';
    if (recordDate == today.subtract(const Duration(days: 1))) return '昨天';
    return DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}

/// 记录详情对话框 - Duolingo 风格
class _RecordDetailDialog extends StatelessWidget {
  final PoopRecord record;

  const _RecordDetailDialog({required this.record});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
                    color: const Color(0xFF1CB0F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_rounded,
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
                        '记录详情',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                      Text(
                        DateFormat('yyyy年M月d日 HH:mm').format(record.startTime),
                        style: const TextStyle(
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

            const SizedBox(height: 24),

            // 详情
            _DetailRow(
              label: '开始时间',
              value: DateFormat('HH:mm:ss').format(record.startTime),
            ),
            const SizedBox(height: 14),
            _DetailRow(
              label: '结束时间',
              value: DateFormat('HH:mm:ss').format(record.endTime),
            ),
            const SizedBox(height: 14),
            _DetailRow(
              label: '时长',
              value: record.durationText,
            ),
            const SizedBox(height: 14),
            _DetailRow(
              label: '布里斯托',
              value:
                  'T${record.bristolScale.typeNumber} - ${record.bristolScale.shortDescription}',
            ),
            const SizedBox(height: 14),
            _DetailRow(
              label: '排便量',
              value: record.amount.label,
            ),
            if (record.color != null) ...[
              const SizedBox(height: 14),
              _DetailRow(
                label: '颜色',
                value: record.color!,
              ),
            ],

            const SizedBox(height: 24),

            // 删除按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text(
                  '删除记录',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: const Color(0xFFFF4B4B),
                  side:
                      const BorderSide(color: Color(0xFFFF4B4B), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '确认删除',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('确定要删除这条记录吗？此操作不可恢复。'),
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
              await context.read<PoopProvider>().deleteRecord(record.id);
              if (context.mounted) {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('记录已删除'),
                      ],
                    ),
                    backgroundColor: Color(0xFFFF4B4B),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFFFF4B4B)),
            child: const Text(
              '删除',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C3C3C),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
