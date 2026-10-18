import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class EyebrowHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;

  const EyebrowHeader({
    super.key,
    this.eyebrow = 'FIELD WORKSPACE',
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 27,
            letterSpacing: -1,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: textColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: mutedColor,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class MiniCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final VoidCallback? onTap;

  const MiniCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: textColor,
                ),
              ),
              if (sub != null) ...[
                const SizedBox(height: 4),
                Text(
                  sub!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: mutedColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HelpBox extends StatelessWidget {
  final String text;
  final IconData? icon;

  const HelpBox({
    super.key,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF354138) : const Color(0xFFEDF0E6);
    final textCol = isDark ? const Color(0xFFD5E1CF) : const Color(0xFF535E53);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? Icons.info_outline_rounded,
            size: 18,
            color: textCol,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textCol,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RuleDivider extends StatelessWidget {
  final bool isGlass;
  const RuleDivider({super.key, this.isGlass = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final col = isGlass
        ? Colors.white.withValues(alpha: 0.15)
        : (isDark ? AppColors.darkLine : AppColors.line);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      height: 1,
      color: col,
    );
  }
}
