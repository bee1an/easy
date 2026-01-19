import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/feature/home/home_page.dart';
import 'package:easy/feature/profile/profile_page.dart';

/// Main App Shell with Bottom Navigation
///
/// Two tabs:
/// - Home (首页)
/// - Profile (我的)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomePage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    // Load records when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PoopProvider>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.borderColor(context), width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.surface,
          indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: _currentIndex == 0
                    ? AppTheme.primary
                    : AppTheme.textMutedColor(context),
              ),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
              label: '首页',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: _currentIndex == 1
                    ? AppTheme.primary
                    : AppTheme.textMutedColor(context),
              ),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
