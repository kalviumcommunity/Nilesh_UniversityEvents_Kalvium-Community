import 'package:flutter/material.dart';

import '../../models/assignment_status.dart';

class AssignmentStatusChip extends StatelessWidget {
  const AssignmentStatusChip({super.key, required this.status});

  final AssignmentStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      AssignmentStatus.assigned => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      AssignmentStatus.confirmed => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      AssignmentStatus.declined => (
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
