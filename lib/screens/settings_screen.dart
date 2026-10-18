import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const SettingsScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _usageAlerts = true;
  bool _outageUpdates = true;
  bool _assignmentReminders = true;
  bool _offlineCache = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowHeader(
              eyebrow: 'FIELD WORKSPACE',
              title: 'Make it yours.',
              subtitle: 'Preferences for this mobile app',
            ),

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
                  _SwitchRow(
                    label: 'Dark appearance',
                    value: widget.isDarkTheme,
                    onChanged: (val) => widget.onToggleTheme(),
                    textColor: textColor,
                  ),
                  const RuleDivider(),
                  _SwitchRow(
                    label: 'AI Usage spike alerts',
                    value: _usageAlerts,
                    onChanged: (val) => setState(() => _usageAlerts = val),
                    textColor: textColor,
                  ),
                  const RuleDivider(),
                  _SwitchRow(
                    label: 'Nearby outage updates',
                    value: _outageUpdates,
                    onChanged: (val) => setState(() => _outageUpdates = val),
                    textColor: textColor,
                  ),
                  const RuleDivider(),
                  _SwitchRow(
                    label: 'Assignment reminders',
                    value: _assignmentReminders,
                    onChanged: (val) => setState(() => _assignmentReminders = val),
                    textColor: textColor,
                  ),
                  const RuleDivider(),
                  _SwitchRow(
                    label: 'Offline local caching',
                    value: _offlineCache,
                    onChanged: (val) => setState(() => _offlineCache = val),
                    textColor: textColor,
                  ),
                ],
              ),
            ),

            const HelpBox(
              text: 'Settings apply directly to your MeterMind field session. Local caching ensures work continues smoothly in low-signal areas.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: AppColors.yellow,
          activeTrackColor: AppColors.ink,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
