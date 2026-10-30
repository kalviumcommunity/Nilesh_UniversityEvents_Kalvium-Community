import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../dev/demo_volunteer_backend.dart';
import '../../ui/avatar_circle.dart';
import '../../ui/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final nav = Navigator.of(context);

    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.event_available_outlined,
        'My Registrations',
        () => nav.pushNamed(Routes.myEvents)
      ),
      (Icons.workspace_premium_outlined, 'My Certificates', () {}),
      (
        Icons.volunteer_activism_outlined,
        'Volunteer Hours',
        () => openVolunteerDemo(context)
      ),
      (
        Icons.settings_outlined,
        'Settings',
        () => nav.pushNamed(Routes.settings)
      ),
      (Icons.help_outline, 'Help & Support', () {}),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.navy),
        Positioned(
          top: top + 150,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Row(
                  children: [
                    Expanded(child: StatTile(value: '12', label: 'Events')),
                    SizedBox(width: 12),
                    Expanded(child: StatTile(value: '36', label: 'Hours')),
                    SizedBox(width: 12),
                    Expanded(
                        child: StatTile(value: '5', label: 'Certificates')),
                  ],
                ),
                const SizedBox(height: 12),
                for (final item in items)
                  InkWell(
                    onTap: item.$3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        children: [
                          Icon(item.$1, color: AppColors.ink, size: 26),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              item.$2,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.ink),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: top + 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const AvatarCircle(initial: 'N', size: 112),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nilesh',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Computer Science',
                style: TextStyle(color: AppColors.muted, fontSize: 17),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
