import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../data/mock_data.dart';
import 'image_placeholder.dart';

/// Thumbnail + title + muted detail lines (+ optional action on the right
/// below the text). Used by Explore, My Events, Manage Events, Home.
class EventRowCard extends StatelessWidget {
  const EventRowCard({
    super.key,
    required this.event,
    required this.lines,
    required this.onTap,
    this.action,
    this.dark = false,
  });

  final MockEvent event;
  final List<String> lines;
  final VoidCallback onTap;
  final Widget? action;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagePlaceholder(
              colors: event.colors,
              width: 78,
              height: 78,
              radius: 14,
              icon: Icons.image_outlined,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: dark ? Colors.white : AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        line,
                        style: TextStyle(
                          color: dark ? Colors.white60 : AppColors.muted,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  if (action != null)
                    Align(alignment: Alignment.centerRight, child: action),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
