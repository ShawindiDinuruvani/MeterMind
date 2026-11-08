import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_header.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

const Color _profileBackground = Color(0xFFF4F5F0);
const Color _profileInk = Color(0xFF17201D);
const Color _profileMuted = Color(0xFF65716A);
const Color _profileBorder = Color(0xFFDDE3DA);
const Color _profilePale = Color(0xFFEEF1E8);
const Color _profileYellow = Color(0xFFFFF3D7);

class ProfilePage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkTheme;

  const ProfilePage({
    super.key,
    this.onToggleTheme,
    this.isDarkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _profileBackground,
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
                        color: _profileMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your workspace.',
                      style: TextStyle(
                        color: _profileInk,
                        fontSize: 30,
                        height: 1.12,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 11),
                    const Text(
                      'Personal account',
                      style: TextStyle(fontSize: 14, color: _profileMuted),
                    ),
                    const SizedBox(height: 20),
                    const _ProfileDetailsCard(),
                    const SizedBox(height: 17),
                    _ProfileActionButton(
                      label: 'Notifications',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _ProfileActionButton(
                      label: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              onToggleTheme: onToggleTheme ?? () {},
                              isDarkTheme: isDarkTheme,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _ProfileActionButton(
                      label: 'Help & support',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _ProfileActionButton(
                      label: 'Sign out',
                      onPressed: () => _confirmSignOut(context),
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

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Sign out?',
          style: TextStyle(color: _profileInk, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Do you want to sign out of your MeterMind account?',
          style: TextStyle(color: _profileMuted, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthService.instance.signOut();
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
            style: ElevatedButton.styleFrom(
              backgroundColor: _profileYellow,
              foregroundColor: _profileInk,
              elevation: 0,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = (user?.name.isNotEmpty == true) ? user!.name : 'Tharusha Wakwella';
    final meterId = (user?.meterId?.isNotEmpty == true) ? user!.meterId! : 'MM-04218';
    final area = (user?.area?.isNotEmpty == true) ? user!.area! : 'Homagama';
    final email = (user?.email.isNotEmpty == true) ? user!.email : 'demo@example.com';

    String initials = 'TW';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: _profileBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _profilePale,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: _profileInk,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _profileInk,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customer · $meterId',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: _profileMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          const Divider(height: 1, color: _profileBorder),
          _ProfileInfoRow(label: 'Area', value: area),
          _ProfileInfoRow(label: 'Contact', value: email),
          _ProfileInfoRow(
            label: 'Address',
            value: user?.area != null ? 'Temple Road, $area' : '24 Temple Road',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: _profileMuted, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: _profileInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: _profileBorder),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _profileInk,
          backgroundColor: Colors.white,
          side: const BorderSide(color: _profileBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
