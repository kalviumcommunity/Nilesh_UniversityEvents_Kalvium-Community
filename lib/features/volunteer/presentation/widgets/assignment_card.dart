import 'package:flutter/material.dart';

import '../../models/assignment_list_item.dart';
import '../format.dart';
import 'assignment_status_chip.dart';

/// One assignment in the dashboard list. Tappable only when [onTap] is set.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({super.key, required this.item, this.onTap});

  final AssignmentListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = item.event;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event?.title ?? 'Event unavailable',
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AssignmentStatusChip(status: item.assignment.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${item.assignment.role}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (event != null) ...[
                _InfoRow(
                  icon: Icons.schedule_outlined,
                  text: formatEventDateTime(event.startTime),
                ),
                const SizedBox(height: 4),
                _InfoRow(icon: Icons.place_outlined, text: event.venueName),
              ] else
                Text(
                  'Event details are not available right now.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}
