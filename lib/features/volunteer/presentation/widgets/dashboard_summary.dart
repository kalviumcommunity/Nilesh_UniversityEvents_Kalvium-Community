import 'package:flutter/material.dart';

import '../../models/assignment_summary.dart';

/// Welcome message plus assignment counts.
class DashboardSummary extends StatelessWidget {
  const DashboardSummary({
    super.key,
    required this.volunteerName,
    required this.summary,
  });

  final String volunteerName;
  final AssignmentSummary summary;

  String get _subtitle {
    final n = summary.assigned;
    if (n == 0) return 'You are all caught up.';
    return n == 1
        ? '1 assignment is waiting for your response.'
        : '$n assignments are waiting for your response.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, $volunteerName', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(_subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CountTile(
                label: 'Awaiting response',
                count: summary.assigned,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CountTile(label: 'Confirmed', count: summary.confirmed),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CountTile(label: 'Declined', count: summary.declined),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text('$count', style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
