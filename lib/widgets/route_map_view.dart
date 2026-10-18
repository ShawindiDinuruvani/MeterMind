import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class RouteMapView extends StatelessWidget {
  final String selectedArea;
  final Function(String area, String meterId) onSelectStop;

  const RouteMapView({
    super.key,
    required this.selectedArea,
    required this.onSelectStop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 250,
          margin: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE6EADD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Custom Painted Vector Street Map
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapPainter(),
                ),
              ),

              // Homagama Stop 1 Pin (Selected/Pending)
              Positioned(
                left: 145,
                top: 75,
                child: _MapPin(
                  label: '1',
                  isSelected: selectedArea == 'Homagama',
                  statusColor: AppColors.red,
                  onTap: () => onSelectStop('Homagama', 'MM-04218'),
                ),
              ),

              // Pitipana Stop 2 Pin (Pending)
              Positioned(
                left: 235,
                top: 125,
                child: _MapPin(
                  label: '2',
                  isSelected: selectedArea == 'Pitipana',
                  statusColor: AppColors.amber,
                  onTap: () => onSelectStop('Pitipana', 'MM-02816'),
                ),
              ),

              // Makumbura Stop 3 Pin (Completed)
              Positioned(
                left: 55,
                top: 145,
                child: _MapPin(
                  label: '✓',
                  isSelected: selectedArea == 'Makumbura',
                  statusColor: AppColors.green,
                  onTap: () => onSelectStop('Makumbura', 'MM-01825'),
                ),
              ),

              // Map bottom note
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation_outlined, size: 14, color: Color(0xFF445046)),
                      const SizedBox(width: 6),
                      Text(
                        'Illustrative map · Tap stops to inspect meters',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: const Color(0xFF445046),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Map Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendItem(color: AppColors.red, label: 'Selected / Priority'),
              _LegendItem(color: AppColors.amber, label: 'Pending reading'),
              _LegendItem(color: AppColors.green, label: 'Completed'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color statusColor;
  final VoidCallback onTap;

  const _MapPin({
    required this.label,
    required this.isSelected,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 48 : 42,
        height: isSelected ? 48 : 42,
        decoration: BoxDecoration(
          color: statusColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.35 : 0.2),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: label == '✓' ? 18 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    final bgPaint = Paint()..color = const Color(0xFFE6EADD);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Green district zones
    final zonePaint = Paint()..color = const Color(0xFFCBD8B6);
    final r1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(25, 145, 55, 38),
      const Radius.circular(9),
    );
    canvas.drawRRect(r1, zonePaint);

    final r2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(210, 15, 75, 52),
      const Radius.circular(12),
    );
    canvas.drawRRect(r2, zonePaint);

    // Major road lines (white base + border)
    final roadBase = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadBorder = Paint()
      ..color = const Color(0xFFC9D0BD)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final roads = [
      [Offset(0, 25), Offset(size.width, 200)],
      [Offset(65, 0), Offset(250, size.height)],
      [Offset(0, 195), Offset(size.width, 30)],
      [Offset(0, 105), Offset(size.width, 110)],
    ];

    for (var r in roads) {
      canvas.drawLine(r[0], r[1], roadBase);
      canvas.drawLine(r[0], r[1], roadBorder);
    }

    // Place labels
    final textPainter1 = TextPainter(
      text: TextSpan(
        text: 'Homagama',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5A6655),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter1.paint(canvas, const Offset(14, 20));

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: 'Pitipana',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5A6655),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter2.paint(canvas, Offset(size.width - 70, size.height - 40));

    final textPainter3 = TextPainter(
      text: TextSpan(
        text: 'Makumbura',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF5A6655),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter3.paint(canvas, const Offset(35, 125));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
