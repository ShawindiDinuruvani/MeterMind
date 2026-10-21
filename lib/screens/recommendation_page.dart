import 'package:flutter/material.dart';

import '../widgets/app_header.dart';

const Color _pageBackground = Color(0xFFF4F5F0);
const Color _ink = Color(0xFF17201D);
const Color _muted = Color(0xFF65716A);
const Color _border = Color(0xFFDDE3DA);
const Color _blue = Color(0xFF246A9B);
const Color _paleBlue = Color(0xFFE8F1F8);
const Color _darkCardStart = Color(0xFF303A33);
const Color _darkCardEnd = Color(0xFF1B2420);

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  bool _actionSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeader(),
                    const SizedBox(height: 29),
                    const Text(
                      'YOUR ENERGY, UNDERSTOOD',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use less.\nKnow why.',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 30,
                        height: 1.12,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 11),
                    const Text(
                      'Personalized energy recommendations',
                      style: TextStyle(fontSize: 14, color: _muted),
                    ),
                    const SizedBox(height: 20),
                    const _NextBestStepCard(),
                    const SizedBox(height: 17),
                    _RecommendationCard(
                      title: 'Review your usage routine',
                      badge: 'Suggested',
                      reason: 'Your next-month range is above your latest measured usage.',
                      action: 'Reduce avoidable air-conditioning or water-heating time.',
                      benefit: 'Using 10% less would save about 31 kWh at this month’s usage level.',
                      buttonText: _actionSaved
                          ? 'Action saved ✓'
                          : 'Save this action',
                      onButtonPressed: _toggleSavedAction,
                      isSaved: _actionSaved,
                    ),
                    const SizedBox(height: 17),
                    _UnexpectedChangesCard(
                      onTap: () => _showMeterMessage(context),
                    ),
                    const SizedBox(height: 17),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF0E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Monthly readings support overall trends. Appliance or evening-usage claims require more detailed data.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _toggleSavedAction() {
    setState(() => _actionSaved = !_actionSaved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _actionSaved
              ? 'Recommendation saved for this session.'
              : 'Recommendation removed from saved actions.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMeterMessage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _pageBackground,
      builder: (sheetContext) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check unexpected changes',
                style: TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Compare your next physical meter reading with previous readings. Check the reading date and units before deciding that usage has changed.',
                style: TextStyle(color: _muted, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'This prototype does not yet connect to a live meter or utility account.',
                style: TextStyle(color: _muted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextBestStepCard extends StatelessWidget {
  const _NextBestStepCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkCardStart, _darkCardEnd],
        ),
        border: Border.all(color: const Color(0xFF465047)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR NEXT BEST STEP',
            style: TextStyle(
              color: Color(0xFFE9E9D8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
            ),
          ),
          SizedBox(height: 17),
          Text(
            'Start with your biggest appliances.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.3,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 13),
          Text(
            'A small reduction in total usage can help lower your estimate.',
            style: TextStyle(
              color: Color(0xE0FFFFFF),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.title,
    required this.badge,
    required this.reason,
    required this.action,
    required this.benefit,
    required this.buttonText,
    required this.onButtonPressed,
    required this.isSaved,
  });

  final String title;
  final String badge;
  final String reason;
  final String action;
  final String benefit;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _paleBlue,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LabeledText(label: 'Reason', text: reason),
          const SizedBox(height: 10),
          _LabeledText(label: 'Action', text: action),
          const SizedBox(height: 10),
          _LabeledText(label: 'Expected benefit', text: benefit),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: onButtonPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                backgroundColor: isSaved
                    ? const Color(0xFFF1F4EC)
                    : Colors.white,
                side: BorderSide(
                  color: isSaved ? const Color(0xFF9CB69D) : _border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledText extends StatelessWidget {
  const _LabeledText({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: _ink, fontSize: 14, height: 1.55),
        children: [
          TextSpan(
            text: '$label · ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}

class _UnexpectedChangesCard extends StatelessWidget {
  const _UnexpectedChangesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check unexpected changes',
            style: TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Compare the next physical reading with your history before assuming a change is caused by an appliance.',
            style: TextStyle(color: _ink, fontSize: 14, height: 1.55),
          ),
          const SizedBox(height: 17),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9A6B00),
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 36),
              alignment: Alignment.centerLeft,
            ),
            child: const Text(
              'View my meter →',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
