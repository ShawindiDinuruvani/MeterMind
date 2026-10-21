import 'package:flutter/material.dart';

const Color _navInk = Color(0xFF17201D);
const Color _navMuted = Color(0xFF65716A);
const Color _navSelected = Color(0xFFFFF3D7);
const Color _navBorder = Color(0xFFDDE3DA);

/// MeterMind's five-item bottom navigation, styled to match the reference UI.
///
/// Use:
/// BottomNavigation(
///   currentIndex: selectedIndex,
///   onTap: (index) => setState(() => selectedIndex = index),
/// )
class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(label: 'Home', icon: Icons.home_outlined),
    _NavItem(label: 'Insights', icon: Icons.view_column_outlined),
    _NavItem(label: 'Outages', icon: Icons.track_changes_outlined),
    _NavItem(label: 'Recommendations', icon: Icons.route_outlined),
    _NavItem(label: 'Profile', icon: Icons.circle_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _navBorder, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(5, 8, 5, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == currentIndex;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: selected ? _navSelected : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onTap(index),
                    child: SizedBox(
                      height: 64,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 27,
                            child: Center(
                              child: Icon(
                                item.icon,
                                size: 20,
                                color: _navInk,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected ? _navInk : _navMuted,
                              fontSize: item.label == 'Recommendations'
                                  ? 9
                                  : 10,
                              height: 1.1,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
