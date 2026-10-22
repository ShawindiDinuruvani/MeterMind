import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_assistant_sheet.dart';
import 'reader_home_screen.dart';
import 'assignments_screen.dart';
import 'readings_history_screen.dart';
import 'route_map_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const MainNavigationScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onSelectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkTheme;
    final navBg = isDark ? AppColors.darkCard : Colors.white;
    final borderCol = isDark ? AppColors.darkLine : AppColors.line;

    final pages = [
      ReaderHomeScreen(
        onNavigateToAssignments: () => _onSelectTab(1),
      ),
      const AssignmentsScreen(),
      const ReadingsHistoryScreen(),
      const RouteMapScreen(),
      ProfileScreen(
        onToggleTheme: widget.onToggleTheme,
        isDarkTheme: widget.isDarkTheme,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ϟ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkText : AppColors.ink,
                  letterSpacing: -0.6,
                ),
                children: const [
                  TextSpan(text: 'Meter'),
                  TextSpan(
                    text: 'Mind',
                    style: TextStyle(color: Color(0xFF8C6904)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // AI Copilot Quick Button
          IconButton(
            tooltip: 'Ask MeterMind AI',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(color: borderCol),
                borderRadius: BorderRadius.circular(12),
                color: navBg,
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.amber),
            ),
            onPressed: () => AiAssistantSheet.show(context),
          ),
          // Notifications
          IconButton(
            tooltip: 'Notifications',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderCol),
                    borderRadius: BorderRadius.circular(12),
                    color: navBg,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 18,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: borderCol, width: 1),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 14),
        child: Row(
          children: [
            _buildNavItem(0, '⌂', Icons.home_rounded, 'Home'),
            _buildNavItem(1, '☷', Icons.format_list_bulleted_rounded, 'Assignments'),
            _buildNavItem(2, '↺', Icons.history_rounded, 'Readings'),
            _buildNavItem(3, '◎', Icons.map_outlined, 'Map'),
            _buildNavItem(4, '◯', Icons.person_outline_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String symbol, IconData icon, String label) {
    final isActive = _currentIndex == index;
    final isDark = widget.isDarkTheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onSelectTab(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0x33F5C542) : const Color(0x30F5C542))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? (isDark ? AppColors.yellow : AppColors.ink)
                    : (isDark ? AppColors.darkMuted : AppColors.muted),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive
                      ? (isDark ? AppColors.darkText : AppColors.ink)
                      : (isDark ? AppColors.darkMuted : AppColors.muted),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
