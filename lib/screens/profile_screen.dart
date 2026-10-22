import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reader_model.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const ProfileScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return StreamBuilder<ReaderModel>(
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

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowHeader(
                  eyebrow: 'FIELD WORKSPACE',
                  title: 'Your workspace.',
                  subtitle: 'Field officer profile',
                ),

                // Profile Card
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
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF354138) : const Color(0xFFEFF1E9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                'NP',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reader.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${reader.employeeCode} · Field Officer',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const RuleDivider(),
                      _ProfileRow(label: 'Area', value: reader.area, textColor: textColor, mutedColor: mutedColor),
                      const RuleDivider(),
                      _ProfileRow(label: 'Contact', value: reader.email, textColor: textColor, mutedColor: mutedColor),
                      const RuleDivider(),
                      _ProfileRow(
                        label: 'Work statistics',
                        value: '${reader.completedCount} / ${reader.assignedCount} today',
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                      const RuleDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cloud Backend', style: GoogleFonts.inter(fontSize: 13.5, color: mutedColor)),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                firebaseService.isUsingLocalFallback ? 'Local Offline Mode' : 'Firebase Connected',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                  child: const Text('Notifications'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          onToggleTheme: onToggleTheme,
                          isDarkTheme: isDarkTheme,
                        ),
                      ),
                    );
                  },
                  child: const Text('Settings'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SupportScreen()),
                    );
                  },
                  child: const Text('Help & support'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: Color(0xFFE8D0D0)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                        title: Text(
                          'Sign out of MeterMind?',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                        ),
                        content: Text(
                          'Are you sure you want to end your field session for today?',
                          style: GoogleFonts.inter(fontSize: 13.5, color: mutedColor),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(100, 42),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              Navigator.pop(dialogCtx);
                              try {
                                await FirebaseAuth.instance.signOut();
                              } catch (_) {}

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(
                                      onToggleTheme: onToggleTheme,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text('Sign out'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;

  const _ProfileRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13.5, color: mutedColor)),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
      ],
    );
  }
}
