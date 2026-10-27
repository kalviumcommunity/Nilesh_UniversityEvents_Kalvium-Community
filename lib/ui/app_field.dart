import 'package:flutter/material.dart';

import '../app/app_colors.dart';

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.hint,
    this.icon,
    this.controller,
    this.obscure = false,
    this.dark = false,
    this.maxLines = 1,
    this.keyboardType,
    this.fillColor,
  });

  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final bool obscure;
  final bool dark;
  final int maxLines;
  final TextInputType? keyboardType;

  /// When set, the field is a borderless filled box (e.g. text areas).
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = dark ? AppColors.navyBorder : AppColors.line;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              fillColor != null ? BorderSide.none : BorderSide(color: c),
        );

    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: dark ? Colors.white : AppColors.ink,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: dark ? Colors.white54 : AppColors.muted,
          fontSize: 16,
        ),
        prefixIcon: icon == null
            ? null
            : Icon(icon,
                size: 22, color: dark ? Colors.white70 : AppColors.muted),
        filled: true,
        fillColor: fillColor ?? (dark ? AppColors.navyCard : Colors.white),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: border(borderColor),
        enabledBorder: border(borderColor),
        focusedBorder: border(dark ? AppColors.periwinkle : AppColors.blue),
      ),
    );
  }
}
