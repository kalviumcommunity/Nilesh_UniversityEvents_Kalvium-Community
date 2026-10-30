import 'package:flutter/material.dart';

import '../app/app_colors.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.dark = false,
  });

  final String value;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      decoration: BoxDecoration(
        color: dark ? AppColors.navyCard : AppColors.greySoft,
        borderRadius: BorderRadius.circular(16),
        border: dark ? Border.all(color: AppColors.navyBorder) : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: dark ? Colors.white : AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: dark ? Colors.white60 : AppColors.muted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
