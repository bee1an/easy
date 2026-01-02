import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/widget/heatmap.dart';
import 'package:easy/widget/quick_start_button.dart';
import 'package:easy/widget/history_list.dart';
import 'package:easy/widget/settings_page.dart';

/// 主页面 - Duolingo 风格
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  String? _errorMessage;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    // 创建进入动画
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 加载数据并启动动画
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataSafely();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  /// 安全加载数据
  Future<void> _loadDataSafely() async {
    try {
      await context.read<PoopProvider>().loadRecords();
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
      // 启动进入动画
      _entranceController.forward();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '数据加载失败：$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 显示错误状态
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFFF4B4B),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '出错了',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ?? '未知错误',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF777777),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadDataSafely,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58CC02),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 正常内容
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 顶部标题栏
              SliverToBoxAdapter(
                child: _buildAppBar(context),
              ),

              // 内容区域
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 连胜统计卡片
                    const SizedBox(height: 16),
                    _buildStreakCard(context),

                    // 快速开始按钮
                    const SizedBox(height: 24),
                    _buildAnimatedSection(
                      child: const QuickStartButton(),
                    ),

                    // 今日提示
                    const SizedBox(height: 24),
                    _buildTodayHint(context),

                    // 热力图
                    const SizedBox(height: 24),
                    const Heatmap(),

                    // 历史记录
                    const SizedBox(height: 24),
                    const HistoryList(),

                    // 设置
                    const SizedBox(height: 24),
                    const SettingsPage(),

                    // 底部留白
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // 标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Easy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3C3C3C),
                  ),
                ),
                Text(
                  '日常记录助手',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),

          // 更多选项
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建连胜统计卡片
  Widget _buildStreakCard(BuildContext context) {
    return Consumer<PoopProvider>(
      builder: (context, provider, child) {
        final streak = provider.getStreak();
        final longestStreak = provider.getLongestStreak();
        final monthCount = provider.getMonthCount();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E5E5),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 当前连胜
              _buildStreakItem(
                icon: Icons.whatshot_rounded,
                iconColor: const Color(0xFFFF9600),
                label: '连续',
                value: streak,
                unit: '天',
              ),

              // 本月记录
              _buildStreakItem(
                icon: Icons.calendar_today_rounded,
                iconColor: const Color(0xFF1CB0F6),
                label: '本月',
                value: monthCount,
                unit: '次',
              ),

              // 最佳记录
              _buildStreakItem(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFB800),
                label: '最佳',
                value: longestStreak,
                unit: '天',
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建统计项
  Widget _buildStreakItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required int value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          '$value$unit',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3C3C3C),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF777777),
          ),
        ),
      ],
    );
  }

  /// 构建今日提示
  Widget _buildTodayHint(BuildContext context) {
    return Consumer<PoopProvider>(
      builder: (context, provider, child) {
        final count = provider.getTodayCount();

        String message;
        Color backgroundColor;
        Color textColor;
        IconData icon;

        if (count == 0) {
          message = '今天还没有记录，点击上方按钮开始吧！';
          backgroundColor = const Color(0xFFFFF7E6);
          textColor = const Color(0xFFFF9600);
          icon = Icons.info_rounded;
        } else if (count <= 2) {
          message = '今天已记录 $count 次，继续保持！';
          backgroundColor = const Color(0xFFE8F5E9);
          textColor = const Color(0xFF58CC02);
          icon = Icons.check_circle_rounded;
        } else {
          message = '今天已记录 $count 次，注意健康哦！';
          backgroundColor = const Color(0xFFFFE6E6);
          textColor = const Color(0xFFFF4B4B);
          icon = Icons.warning_rounded;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: textColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建带动画的区域
  Widget _buildAnimatedSection({required Widget child}) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _entranceController.value)),
          child: Opacity(
            opacity: _entranceController.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
