import 'package:flutter/material.dart';

import '../app/app_colors.dart';

enum AppButtonStyle { ink, blue, periwinkle, white, outlined, dangerSoft }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.ink,
    this.icon,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      AppButtonStyle.ink => (AppColors.ink, Colors.white, Colors.transparent),
      AppButtonStyle.blue => (AppColors.blue, Colors.white, Colors.transparent),
      AppButtonStyle.periwinkle => (
          AppColors.periwinkle,
          AppColors.ink,
          Colors.transparent
        ),
      AppButtonStyle.white => (Colors.white, AppColors.ink, Colors.transparent),
      AppButtonStyle.outlined => (Colors.white, AppColors.ink, AppColors.line),
      AppButtonStyle.dangerSoft => (
          AppColors.dangerSoft,
          AppColors.danger,
          Colors.transparent
        ),
    };
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: border),
    );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: onPressed == null ? bg.withAlpha(150) : bg,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
