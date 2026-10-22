import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/nav_item.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<NavItem> items = [
    NavItem('home', 'Home', Icons.home_outlined),
    NavItem('insights', 'Insights', Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      decoration: BoxDecoration(
        color: lightSurface,
        border: Border(top: BorderSide(color: lightLine)),
      ),
      padding: const EdgeInsets.fromLTRB(5, 9, 5, 12),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final active = currentIndex == index;
          return Expanded(
            child: Semantics(
              selected: active,
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
                  decoration: BoxDecoration(
                    color: active ? energyYellow.withAlpha(48) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 22, color: active ? energyInk : lightMuted),
                      const SizedBox(height: 5),
                      Text(
                        item.label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? energyInk : lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}