import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum ChipType {
  normal, // green
  warn,   // amber
  danger, // red
  info,   // blue
}

class StatusChip extends StatelessWidget {
  final String label;
  final ChipType type;

  const StatusChip({
    super.key,
    required this.label,
    this.type = ChipType.normal,
  });

  factory StatusChip.fromStatus(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('pending') || lower.contains('review') || lower.contains('warn')) {
      return StatusChip(label: status, type: ChipType.warn);
    } else if (lower.contains('danger') || lower.contains('alert') || lower.contains('anomaly')) {
      return StatusChip(label: status, type: ChipType.danger);
    } else if (lower.contains('submitted') || lower.contains('info') || lower.contains('progress')) {
      return StatusChip(label: status, type: ChipType.info);
    }
    return StatusChip(label: status, type: ChipType.normal);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (type) {
      case ChipType.warn:
        bg = AppColors.amberLight;
        text = AppColors.amber;
        break;
      case ChipType.danger:
        bg = AppColors.redLight;
        text = AppColors.red;
        break;
      case ChipType.info:
        bg = AppColors.blueLight;
        text = AppColors.blue;
        break;
      case ChipType.normal:
        bg = AppColors.greenLight;
        text = AppColors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
