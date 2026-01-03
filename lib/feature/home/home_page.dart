import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:easy/core/utils/greeting.dart';
import 'package:easy/feature/home/widgets/stats_card.dart';
import 'package:easy/feature/home/widgets/calendar_card.dart';
import 'package:easy/feature/home/widgets/quick_action_button.dart';
import 'package:easy/feature/home/widgets/handwriting_text.dart';

/// Home Page - Premium Minimal Design
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PoopProvider>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header Row
                  Consumer<PoopProvider>(
                    builder: (context, provider, child) {
                      final greeting = getGreeting();
                      final todayCount = provider.getTodayCount();

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CalligraphyText(
                                  key: ValueKey(greeting),
                                  text: greeting,
                                  fontSize: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  todayCount == 0
                                      ? '今日尚未记录'
                                      : '今日已记录 $todayCount 次',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textMutedColor(context),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          _ActionButton(
                            icon: Icons.history_rounded,
                            onTap: () =>
                                AppRouter.push(context, AppRouter.history),
                          ),
                          _ActionButton(
                            icon: Icons.settings_outlined,
                            onTap: () =>
                                AppRouter.push(context, AppRouter.settings),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Stats
                  const StatsCard(),

                  const SizedBox(height: 26),

                  // Calendar
                  const CalendarCard(),
                ]),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: const QuickActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Minimal Action Button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 24, color: AppTheme.textMutedColor(context)),
      ),
    );
  }
}
