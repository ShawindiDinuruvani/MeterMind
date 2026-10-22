import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reader_model.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/common_widgets.dart';

class DailyProgressScreen extends StatelessWidget {
  const DailyProgressScreen({super.key});

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
        title: const Text('Daily progress'),
      ),
      body: StreamBuilder<ReaderModel>(
        stream: firebaseService.streamReaderProfile(),
        builder: (context, snapshot) {
          final reader = snapshot.data ??
              ReaderModel(
                id: 'MR001',
                name: 'Nimal Perera',
                employeeCode: 'MR001',
                area: 'Homagama',
                email: 'nimal.perera@metermind.lk',
                assignedCount: 40,
                completedCount: 28,
                pendingCount: 12,
              );

          final percent = reader.assignedCount > 0
              ? (reader.completedCount / reader.assignedCount).clamp(0.0, 1.0)
              : 0.7;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowHeader(
                  eyebrow: 'FIELD WORKSPACE',
                  title: 'A productive day.',
                  subtitle: 'Homagama route · 04 Oct 2026',
                ),

                // Hero Glass Card
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        '${(percent * 100).round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'of today’s route completed',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.glassSub,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FractionallySizedBox(
                          widthFactor: percent,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Metrics Breakdown Card
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _ProgressMetricRow(
                        label: 'Assigned meters',
                        value: '${reader.assignedCount}',
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                      const RuleDivider(),
                      _ProgressMetricRow(
                        label: 'Completed',
                        value: '${reader.completedCount}',
                        textColor: textColor,
                        mutedColor: mutedColor,
                        isEmphasized: true,
                        valueColor: AppColors.green,
                      ),
                      const RuleDivider(),
                      _ProgressMetricRow(
                        label: 'Pending',
                        value: '${reader.pendingCount}',
                        textColor: textColor,
                        mutedColor: mutedColor,
                        isEmphasized: true,
                        valueColor: AppColors.amber,
                      ),
                      const RuleDivider(),
                      _ProgressMetricRow(
                        label: 'Average pace',
                        value: '3.4 min / meter',
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                      const RuleDivider(),
                      _ProgressMetricRow(
                        label: 'Estimated completion',
                        value: '16:45 today',
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue reading'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;
  final bool isEmphasized;
  final Color? valueColor;

  const _ProgressMetricRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
    this.isEmphasized = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: mutedColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isEmphasized ? 16 : 14,
            fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? textColor,
          ),
        ),
      ],
    );
  }
}
