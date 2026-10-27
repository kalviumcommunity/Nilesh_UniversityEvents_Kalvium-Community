import 'package:flutter/material.dart';

import '../../models/assignment_status.dart';
import '../format.dart';

/// Explains the current status in a sentence and shows the assigned /
/// responded times when known.
class AssignmentStatusNotice extends StatelessWidget {
  const AssignmentStatusNotice({
    super.key,
    required this.status,
    this.assignedAt,
    this.respondedAt,
  });

  final AssignmentStatus status;
  final DateTime? assignedAt;
  final DateTime? respondedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (background, foreground, message) = switch (status) {
      AssignmentStatus.assigned => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          'This assignment is waiting for your response.',
        ),
      AssignmentStatus.confirmed => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          'You confirmed this assignment. Thank you for volunteering!',
        ),
      AssignmentStatus.declined => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          'You declined this assignment.',
        ),
    };

    final style = theme.textTheme.bodySmall?.copyWith(color: foreground);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
          if (assignedAt != null) ...[
            const SizedBox(height: 6),
            Text('Assigned: ${formatEventDateTime(assignedAt!)}', style: style),
          ],
          if (respondedAt != null) ...[
            const SizedBox(height: 2),
            Text('Responded: ${formatEventDateTime(respondedAt!)}',
                style: style),
          ],
        ],
      ),
    );
  }
}
