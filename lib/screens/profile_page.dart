import 'package:flutter/material.dart';

import '../widgets/app_header.dart';

const Color _profileBackground = Color(0xFFF4F5F0);
const Color _profileInk = Color(0xFF17201D);
const Color _profileMuted = Color(0xFF65716A);
const Color _profileBorder = Color(0xFFDDE3DA);
const Color _profilePale = Color(0xFFEEF1E8);
const Color _profileYellow = Color(0xFFFFF3D7);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                      onPressed: () => _showInfoSheet(
                        context,
                        title: 'Notifications',
                        description: 'Notification preferences will be available here. This prototype does not yet send push notifications.',
                        icon: Icons.notifications_none_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProfileActionButton(
                      label: 'Settings',
                      onPressed: () => _showInfoSheet(
                        context,
                        title: 'Settings',
                        description: 'Account preferences and app settings can be managed here in a future version.',
                        icon: Icons.settings_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProfileActionButton(
                      label: 'Help & support',
                      onPressed: () => _showInfoSheet(
                        context,
                        title: 'Help & support',
                        description: 'For this prototype, support messaging is not connected yet. You can add FAQs and contact details here.',
                        icon: Icons.support_agent_rounded,
                      ),
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

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _profileBackground,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _profilePale,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _profileInk, size: 25),
              ),
              const SizedBox(height: 17),
              Text(
                title,
                style: const TextStyle(
                  color: _profileInk,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  color: _profileMuted,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ],
          ),
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
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Demo only: sign-out is not connected to authentication.',
                  ),
                ),
              );
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
                child: const Text(
                  'TW',
                  style: TextStyle(
                    color: _profileInk,
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tharusha Wakwella',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _profileInk,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Customer · MM-04218',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: _profileMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          const Divider(height: 1, color: _profileBorder),
          const _ProfileInfoRow(label: 'Area', value: 'Homagama'),
          const _ProfileInfoRow(label: 'Contact', value: 'demo@example.com'),
          const _ProfileInfoRow(
            label: 'Address',
            value: '24 Temple Road',
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
