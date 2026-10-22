import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reading_model.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/common_widgets.dart';

class ReadingsHistoryScreen extends StatelessWidget {
  final String? meterId;

  const ReadingsHistoryScreen({
    super.key,
    this.meterId,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
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
        title: const Text('Readings history'),
      ),
      body: StreamBuilder<List<ReadingModel>>(
        stream: firebaseService.streamReadings(meterId: meterId),
        builder: (context, snapshot) {
          final readings = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EyebrowHeader(
                  eyebrow: 'FIELD WORKSPACE',
                  title: 'Reading history.',
                  subtitle: meterId != null
                      ? 'Cumulative meter readings · $meterId'
                      : 'All route readings · Homagama',
                ),

                const SizedBox(height: 10),

                if (readings.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(28),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.history_toggle_off_rounded, size: 40, color: AppColors.muted),
                        const SizedBox(height: 12),
                        Text(
                          'No readings yet',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your first verified reading will appear here.',
                          style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                        ),
                      ],
                    ),
                  )
                else
                  ...readings.map((r) {
                    final readingFormatted = r.currentReading
                        .toString()
                        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},");

                    return Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.date,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              StatusChip.fromStatus(r.status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                readingFormatted,
                                style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'kWh',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Consumption: ${r.units} kWh',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reader: ${r.readerName} · ${r.meterId}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: mutedColor,
                            ),
                          ),
                          if (r.note.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF354138) : const Color(0xFFF4F6F2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.sticky_note_2_outlined, size: 14, color: AppColors.muted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      r.note,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontStyle: FontStyle.italic,
                                        color: mutedColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (r.isAnomaly) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.amberLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.amber),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      r.anomalyReason ?? 'AI Flagged Anomaly',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
