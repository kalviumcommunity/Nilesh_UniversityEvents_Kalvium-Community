import 'package:flutter/material.dart';

import '../app/app_colors.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    required this.hint,
    this.dark = false,
    this.onChanged,
  });

  final String hint;
  final bool dark;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style:
          TextStyle(color: dark ? Colors.white : AppColors.ink, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: dark ? Colors.white54 : AppColors.muted),
        prefixIcon:
            Icon(Icons.search, color: dark ? Colors.white70 : AppColors.muted),
        filled: true,
        fillColor: dark ? AppColors.navyCard : AppColors.greySoft,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: dark
              ? const BorderSide(color: AppColors.navyBorder)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: dark
              ? const BorderSide(color: AppColors.navyBorder)
              : BorderSide.none,
        ),
      ),
    );
  }
}
