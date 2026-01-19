import 'package:flutter/material.dart';
import 'package:easy/feature/home/widgets/module_shortcuts.dart';
import 'package:easy/feature/home/widgets/weekly_report_card.dart';

/// Home Page - Premium Minimal Design
///
/// Central hub with:
/// - Quick action buttons for each health module
/// - Weekly report showing trends
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Module Shortcuts
                  const ModuleShortcuts(),

                  const SizedBox(height: 28),

                  // Weekly Report
                  const WeeklyReportCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
