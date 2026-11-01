import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../ui/app_button.dart';
import '../../ui/screen_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(
              title: 'Settings',
              trailing: Icon(Icons.account_circle_outlined, size: 36),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _Section('Account', [
                    (Icons.person_outline, 'Profile Information'),
                    (Icons.key_outlined, 'Change Password'),
                  ]),
                  _Section('Preferences', [
                    (Icons.notifications_none, 'Notifications'),
                    (Icons.contrast, 'App Theme'),
                    (Icons.info_outline, 'Privacy'),
                  ]),
                  _Section('Support', [
                    (Icons.help_outline, 'Help & Support'),
                    (Icons.feedback_outlined, 'Feedback'),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: AppButton(
                label: 'Log Out',
                style: AppButtonStyle.dangerSoft,
                icon: Icons.logout,
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.signIn,
                  (_) => false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.rows);

  final String title;
  final List<(IconData, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Row(
                    children: [
                      Icon(rows[i].$1, color: AppColors.ink, size: 24),
                      const SizedBox(width: 16),
                      Text(
                        rows[i].$2,
                        style:
                            const TextStyle(color: AppColors.ink, fontSize: 17),
                      ),
                    ],
                  ),
                ),
                if (i != rows.length - 1)
                  const Divider(
                      height: 1,
                      indent: 18,
                      endIndent: 18,
                      color: AppColors.line),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
