import 'package:flutter/material.dart';

import '../app/app_colors.dart';

class NavItem {
  const NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.dark = false,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final active = dark ? Colors.white : AppColors.ink;
    final inactive = dark ? Colors.white60 : AppColors.muted;
    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.navy : Colors.white,
        border: Border(
          top: BorderSide(color: dark ? AppColors.navyBorder : AppColors.line),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[i].icon,
                          size: 26,
                          color: i == currentIndex ? active : inactive,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 12,
                            color: i == currentIndex ? active : inactive,
                            fontWeight: i == currentIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
