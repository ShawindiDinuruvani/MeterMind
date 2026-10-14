import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_bottom_nav.dart';
import 'features/home/home_page.dart';
import 'features/insights/insights_page.dart';

void main() => runApp(const MeterMindApp());

class MeterMindApp extends StatelessWidget {
  const MeterMindApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MeterMind',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    home: const MainShell(),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static final List<Widget> _pages = [
    const HomePage(),
    const InsightsPage(),
  ];

  void _onTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _currentIndex, children: _pages),
    bottomNavigationBar: AppBottomNav(
      currentIndex: _currentIndex,
      onTap: _onTap,
    ),
  );
}