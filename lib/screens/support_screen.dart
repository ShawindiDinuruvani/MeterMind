import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _msgController = TextEditingController();
  bool _isSending = false;

  void _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your issue or question.')),
      );
      return;
    }

    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() => _isSending = false);
      _msgController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Request sent to Homagama Area Operations Depot.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

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
        title: const Text('Help & support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowHeader(
              eyebrow: 'FIELD WORKSPACE',
              title: 'We’re here to help.',
              subtitle: 'Find a clear next step.',
            ),

            // FAQs
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
                  _FaqItem(
                    q: 'Why does the app block lower readings?',
                    a: 'Cumulative readings must always be equal or greater than the last recorded inspection. If a meter was physically swapped or rolled over, contact the area supervisor.',
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  const RuleDivider(),
                  _FaqItem(
                    q: 'Can the AI OCR camera read both digital and analog dials?',
                    a: 'Yes, MeterMind AI has been trained on Sri Lankan CEB and LECO single-phase and three-phase meters with 7-segment digital LCDs and cyclometer dials.',
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  const RuleDivider(),
                  _FaqItem(
                    q: 'What if there is no 4G cellular signal on site?',
                    a: 'MeterMind automatically switches to local offline storage. When you regain cellular signal or return to the depot, readings sync automatically to Firebase.',
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Text(
              'How can we help?',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _msgController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your issue or meter observation...',
              ),
            ),

            const SizedBox(height: 16),
            if (_isSending)
              const Center(child: CircularProgressIndicator(color: AppColors.yellow))
            else
              ElevatedButton(
                onPressed: _send,
                child: const Text('Send Support Request'),
              ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String q;
  final String a;
  final Color textColor;
  final Color mutedColor;

  const _FaqItem({
    required this.q,
    required this.a,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q,
          style: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          a,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: mutedColor,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
