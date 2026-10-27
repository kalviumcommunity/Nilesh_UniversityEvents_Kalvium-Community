import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../ui/screen_header.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    final items = <(IconData, String, String)>[
      (Icons.insert_chart_outlined, 'Reports', Routes.reports),
      (Icons.notifications_none, 'Notifications', Routes.notifications),
      (Icons.settings_outlined, 'Settings', Routes.settings),
    ];
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'More'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final item in items)
                  InkWell(
                    onTap: () => nav.pushNamed(item.$3),
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
        ],
      ),
    );
  }
}
