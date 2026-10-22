import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/assignment_model.dart';
import '../models/reading_model.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'reading_success_screen.dart';

class ReadingConfirmScreen extends StatefulWidget {
  final AssignmentModel assignment;
  final int currentReading;
  final int consumption;
  final String note;
  final AIAnalysisResult? aiAnalysis;
  final double aiConfidence;
  final String? photoPath;

  const ReadingConfirmScreen({
    super.key,
    required this.assignment,
    required this.currentReading,
    required this.consumption,
    required this.note,
    this.aiAnalysis,
    this.aiConfidence = 0.98,
    this.photoPath,
  });

  @override
  State<ReadingConfirmScreen> createState() => _ReadingConfirmScreenState();
}

class _ReadingConfirmScreenState extends State<ReadingConfirmScreen> {
  bool _isSubmitting = false;

  void _submit() async {
    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(now);

    final reading = ReadingModel(
      id: 'READ-${widget.assignment.meterId}-${now.millisecondsSinceEpoch}',
      meterId: widget.assignment.meterId,
      customerName: widget.assignment.customerName,
      readerId: 'MR001',
      readerName: 'Nimal Perera',
      previousReading: widget.assignment.previousReading,
      currentReading: widget.currentReading,
      units: widget.consumption,
      date: formattedDate,
      timestamp: now,
      status: 'Submitted',
      note: widget.note,
      isAnomaly: widget.aiAnalysis?.isAnomaly ?? false,
      anomalyReason: widget.aiAnalysis?.message,
      aiConfidence: widget.aiConfidence,
      photoPath: widget.photoPath,
    );

    final success = await FirebaseService().submitReading(reading);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReadingSuccessScreen(
              reading: reading,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit reading. Saved offline.'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    final prevFormatted = widget.assignment.previousReading
        .toString()
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},");
    final currFormatted = widget.currentReading
        .toString()
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},");
    final diffFormatted = widget.consumption
        .toString()
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},");

    final isLargeIncrease = widget.consumption > 1000;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Check before submitting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EyebrowHeader(
              eyebrow: 'FIELD WORKSPACE',
              title: 'Check before submitting.',
              subtitle: '${widget.assignment.customerName} · ${widget.assignment.meterId}',
            ),

            // Summary Card
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
                  _SummaryRow(
                    label: 'Previous reading',
                    value: '$prevFormatted kWh',
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  const RuleDivider(),
                  _SummaryRow(
                    label: 'Current reading',
                    value: '$currFormatted kWh',
                    textColor: textColor,
                    mutedColor: mutedColor,
                    isEmphasized: true,
                  ),
                  const RuleDivider(),
                  _SummaryRow(
                    label: 'Consumption',
                    value: '$diffFormatted kWh',
                    textColor: textColor,
                    mutedColor: mutedColor,
                    isEmphasized: true,
                  ),
                  if (widget.note.isNotEmpty) ...[
                    const RuleDivider(),
                    _SummaryRow(
                      label: 'Reader note',
                      value: widget.note,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                  ],
                ],
              ),
            ),

            // Large increase alert (from prototype)
            if (isLargeIncrease)
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFC27830), width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Large increase',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This is unusually high ($diffFormatted kWh). Recheck the physical meter before confirming.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.ink,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            // AI Confidence & Location Badge
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E3831) : const Color(0xFFEFF2EB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 20, color: AppColors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Verification & GPS Stamp',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Homagama Route · Lat: ${widget.assignment.latitude}, Lng: ${widget.assignment.longitude}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_isSubmitting)
              const Center(
                child: CircularProgressIndicator(color: AppColors.yellow),
              )
            else ...[
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Reading'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Edit reading'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;
  final bool isEmphasized;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
    this.isEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: mutedColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isEmphasized ? 16 : 14,
            fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
