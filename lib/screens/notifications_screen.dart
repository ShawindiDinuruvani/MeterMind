import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowHeader(
              eyebrow: 'FIELD WORKSPACE',
              title: 'Worth your attention.',
              subtitle: 'Today · Homagama Route',
            ),

            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NotificationItem(
                    title: '12 pending readings',
                    description: 'Continue your Homagama route before 17:00.',
                    actionLabel: 'View assignments →',
                    textColor: textColor,
                    mutedColor: mutedColor,
                    onTapAction: () => Navigator.pop(context),
                  ),
                  const RuleDivider(),
                  _NotificationItem(
                    title: 'Route assigned',
                    description: '40 meters scheduled for today by Homagama Area Supervisor.',
                    actionLabel: 'Open route →',
                    textColor: textColor,
                    mutedColor: mutedColor,
                    onTapAction: () => Navigator.pop(context),
                  ),
                  const RuleDivider(),
                  _NotificationItem(
                    title: 'AI Anomaly Model Updated',
                    description: 'Seasonal monsoon domestic baseline updated (+8% expected ceiling).',
                    actionLabel: 'Learn more →',
                    textColor: textColor,
                    mutedColor: mutedColor,
                    onTapAction: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onTapAction;

  const _NotificationItem({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.textColor,
    required this.mutedColor,
    required this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTapAction,
          child: Text(
            actionLabel,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.amber,
            ),
          ),
        ),
      ],
    );
  }
}
