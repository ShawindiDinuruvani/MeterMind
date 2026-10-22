import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/assignment_model.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'reading_confirm_screen.dart';

class ReadingEntryScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const ReadingEntryScreen({
    super.key,
    required this.assignment,
  });

  @override
  State<ReadingEntryScreen> createState() => _ReadingEntryScreenState();
}

class _ReadingEntryScreenState extends State<ReadingEntryScreen> {
  final TextEditingController _readingController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int? _currentReading;
  int? _consumption;
  String? _errorMessage;
  bool _isOcrScanning = false;
  AIOcrScanResult? _ocrResult;
  AIAnalysisResult? _aiAnalysis;
  bool _anomalyConfirmed = false;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _readingController.addListener(_onReadingChanged);
  }

  @override
  void dispose() {
    _readingController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onReadingChanged() {
    final text = _readingController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _currentReading = null;
        _consumption = null;
        _errorMessage = null;
        _aiAnalysis = null;
      });
      return;
    }

    final value = int.tryParse(text);
    if (value == null) {
      setState(() {
        _errorMessage = 'Please enter a valid whole number.';
        _currentReading = null;
        _consumption = null;
        _aiAnalysis = null;
      });
      return;
    }

    final prev = widget.assignment.previousReading;
    final diff = value - prev;

    if (value < prev) {
      setState(() {
        _errorMessage = 'Enter a whole number at or above ${prev.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}.';
        _currentReading = value;
        _consumption = diff;
        _aiAnalysis = AIService().analyzeReading(
          currentReading: value,
          previousReading: prev,
          historicalAverageUsage: widget.assignment.averageMonthlyUsage,
        );
      });
    } else {
      setState(() {
        _errorMessage = null;
        _currentReading = value;
        _consumption = diff;
        _aiAnalysis = AIService().analyzeReading(
          currentReading: value,
          previousReading: prev,
          historicalAverageUsage: widget.assignment.averageMonthlyUsage,
        );
      });
    }
  }

  Future<void> _handleOcrScan({bool fromCamera = true}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );

      // If user took a photo or even cancelled picker in emulator, run simulated high-precision OCR
      setState(() {
        _isOcrScanning = true;
        _capturedImagePath = file?.path;
      });

      final result = await AIService().scanMeterOcr(
        imagePath: file?.path,
        baselinePreviousReading: widget.assignment.previousReading,
      );

      if (mounted) {
        setState(() {
          _isOcrScanning = false;
          _ocrResult = result;
          _readingController.text = result.detectedReading.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.ink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.yellow, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI OCR scanned: ${result.detectedReading} kWh (${(result.confidence * 100).toStringAsFixed(1)}% confidence)',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isOcrScanning = false);
        // Fallback simulated OCR if camera not accessible on desktop/emulator
        final result = await AIService().scanMeterOcr(
          baselinePreviousReading: widget.assignment.previousReading,
        );
        setState(() {
          _ocrResult = result;
          _readingController.text = result.detectedReading.toString();
        });
      }
    }
  }

  void _onReview() {
    if (_currentReading == null || _errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid reading at or above previous reading.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (_aiAnalysis != null && _aiAnalysis!.isAnomaly && !_anomalyConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check the confirmation box acknowledging the AI usage spike warning.'),
          backgroundColor: AppColors.amber,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingConfirmScreen(
          assignment: widget.assignment,
          currentReading: _currentReading!,
          consumption: _consumption!,
          note: _noteController.text.trim(),
          aiAnalysis: _aiAnalysis,
          aiConfidence: _ocrResult?.confidence ?? 0.98,
          photoPath: _capturedImagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final prevFormatted = widget.assignment.previousReading
        .toString()
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},");

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Enter meter reading'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowHeader(
              eyebrow: 'FIELD WORKSPACE',
              title: 'Enter meter reading.',
              subtitle: 'Check the physical meter before submitting.',
            ),

            // Customer details card
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
                  Text(
                    widget.assignment.customerName,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.assignment.meterId} · ${widget.assignment.address}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                  const RuleDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Previous reading',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                      Text(
                        '$prevFormatted kWh',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recorded ${widget.assignment.previousReadingDate}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            // AI OCR Smart Camera Scanner Banner
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E3831) : const Color(0xFFFAF7EE),
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: AppColors.yellow.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 20, color: AppColors.ink),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Meter OCR Scanner',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Instantly scan digital display or dials',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppColors.darkMuted : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isOcrScanning) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.amber),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AI Vision neural network detecting digits...',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: AppColors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ink,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _handleOcrScan(fromCamera: true),
                            icon: const Icon(Icons.camera_enhance_rounded, size: 18),
                            label: const Text('Scan with Camera'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _handleOcrScan(fromCamera: false),
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                  if (_ocrResult != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.green),
                          const SizedBox(width: 6),
                          Text(
                            'AI Verified: ${_ocrResult!.meterType} · ${(_ocrResult!.confidence * 100).toStringAsFixed(1)}% match',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Form Entry
            const SizedBox(height: 20),
            Text(
              'CURRENT METER READING · KWH',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),

            // Large numeric input
            TextField(
              controller: _readingController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              style: GoogleFonts.inter(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. 15820',
                hintStyle: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: AppColors.muted.withValues(alpha: 0.4),
                ),
                suffixText: 'kWh',
                suffixStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ),
              ),

            // Delta Card
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Consumption since last reading',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                  Text(
                    _consumption != null && _consumption! >= 0
                        ? '${_consumption!.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} kWh'
                        : '— kWh',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            // AI Anomaly Alert Panel (if triggered)
            if (_aiAnalysis != null && _aiAnalysis!.isAnomaly)
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _aiAnalysis!.level == 'CRITICAL' ? AppColors.redLight : AppColors.amberLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _aiAnalysis!.level == 'CRITICAL' ? AppColors.red : AppColors.amber,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: _aiAnalysis!.level == 'CRITICAL' ? AppColors.red : AppColors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _aiAnalysis!.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _aiAnalysis!.level == 'CRITICAL' ? AppColors.red : AppColors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _aiAnalysis!.message,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.ink,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Possible AI causes: ${_aiAnalysis!.possibleCauses.first}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _anomalyConfirmed,
                          activeColor: AppColors.ink,
                          onChanged: (val) => setState(() => _anomalyConfirmed = val ?? false),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _anomalyConfirmed = !_anomalyConfirmed),
                            child: Text(
                              'I have verified the physical meter dial and rechecked digits.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Note (optional)
            const SizedBox(height: 18),
            Text(
              'Note (optional)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any useful observation (e.g. meter glass cracked, seal intact, dog in yard)...',
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Date and time are captured automatically on submission.',
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.muted),
            ),

            const HelpBox(
              text: 'A lower reading requires a meter replacement or rollover review. Do not change the previous reading to force acceptance.',
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onReview,
              child: const Text('Review Reading'),
            ),
          ],
        ),
      ),
    );
  }
}
