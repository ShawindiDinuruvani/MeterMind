import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final bool forceShow;

  const AppHeader({
    super.key,
    this.title,
    this.forceShow = false,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    // If inside a tab shell with its own app bar and cannot pop, hide redundant header
    if (!canPop && !forceShow) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (canPop)
            _HeaderButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5C542),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ϟ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202523),
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: Text(
                title ?? 'MeterMind',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202523),
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
          _HeaderButton(
            icon: Icons.notifications_none_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You are all caught up with notifications.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E8E1)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 19, color: const Color(0xFF202523)),
        ),
      ),
    );
  }
}
