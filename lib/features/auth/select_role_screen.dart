import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_role.dart';
import '../../app/routes.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void pick(AppRole role) =>
        Navigator.of(context).pushNamed(Routes.allSet, arguments: role);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left, size: 32),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 28),
              const Text(
                'I am a...',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Choose your role to continue',
                style: TextStyle(color: AppColors.muted, fontSize: 17),
              ),
              const SizedBox(height: 28),
              _RoleCard(
                title: 'Student',
                subtitle: 'Join events, volunteer',
                icon: Icons.person,
                tint: const Color(0xFFE8EDFB),
                iconBg: const Color(0xFFD9E2FA),
                iconColor: AppColors.blue,
                onTap: () => pick(AppRole.student),
              ),
              _RoleCard(
                title: 'Club Coordinator',
                subtitle: 'Manage your club',
                icon: Icons.groups,
                tint: const Color(0xFFE9EEF2),
                iconBg: const Color(0xFFDDF0E6),
                iconColor: AppColors.green,
                onTap: () => pick(AppRole.coordinator),
              ),
              _RoleCard(
                title: 'Faculty / Admin',
                subtitle: 'Oversee and support',
                icon: Icons.apartment,
                tint: const Color(0xFFF7F1EA),
                iconBg: const Color(0xFFFBE6D1),
                iconColor: AppColors.orange,
                onTap: () => pick(AppRole.admin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: tint,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppColors.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
