import 'package:flutter/material.dart';

import '../app/app_colors.dart';

/// Horizontal filter chips: selected = dark pill, others = light grey.
class ChipRow extends StatelessWidget {
  const ChipRow({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.ink : AppColors.greySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
