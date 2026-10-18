import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reading_model.dart';
import '../theme/app_theme.dart';
import 'readings_history_screen.dart';

class ReadingSuccessScreen extends StatelessWidget {
  final ReadingModel reading;

  const ReadingSuccessScreen({
    super.key,
    required this.reading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Big green checkmark circle matching prototype: width: 65px; height: 65px; background: #e2f1e4; color: #237548; border-radius: 50%;
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F1E4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '✓',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reading submitted.',
                style: GoogleFonts.inter(
                  fontSize: 27,
                  letterSpacing: -1,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Successfully recorded to MeterMind Cloud for ${reading.customerName} (${reading.meterId}). Route progress updated.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: mutedColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Detail Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recorded Reading: ',
                      style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                    ),
                    Text(
                      '${reading.currentReading} kWh',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+${reading.units} kWh',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReadingsHistoryScreen(
                        meterId: reading.meterId,
                      ),
                    ),
                  );
                },
                child: const Text('View in Readings History'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
