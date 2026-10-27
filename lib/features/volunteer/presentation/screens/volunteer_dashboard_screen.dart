import 'package:flutter/material.dart';

import '../../contracts/assignment_repository.dart';
import '../../contracts/event_lookup.dart';
import '../../models/assignment_list_item.dart';
import '../../models/assignment_summary.dart';
import '../../state/dashboard_controller.dart';
import '../widgets/assignment_card.dart';
import '../widgets/dashboard_message_view.dart';
import '../widgets/dashboard_summary.dart';

/// Volunteer dashboard. It receives its dependencies; it does not read
/// auth or create repositories itself, so Aman's providers can supply them.
///
/// [onOpenAssignment] is the navigation hook: the host app (router) decides
/// where to go. When null, cards are not tappable.
class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({
    super.key,
    required this.assignments,
    required this.events,
    required this.volunteerUid,
    required this.volunteerName,
    this.onOpenAssignment,
  });

  final AssignmentRepository assignments;
  final EventLookup events;
  final String volunteerUid;
  final String volunteerName;
  final void Function(AssignmentListItem item)? onOpenAssignment;

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(
      assignments: widget.assignments,
      events: widget.events,
      volunteerUid: widget.volunteerUid,
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Assignments')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => switch (_controller.state) {
          DashboardLoading() =>
            const Center(child: CircularProgressIndicator()),
          DashboardEmpty() => const DashboardMessageView(
              icon: Icons.assignment_outlined,
              title: 'No assignments yet',
              message: 'When an organiser assigns you to an event, '
                  'it will show up here.',
            ),
          DashboardError(:final message) => DashboardMessageView(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              message: message,
              actionLabel: 'Retry',
              onAction: _controller.load,
            ),
          DashboardLoaded(:final items, :final summary) => _AssignmentList(
              items: items,
              summary: summary,
              volunteerName: widget.volunteerName,
              onOpen: widget.onOpenAssignment,
            ),
        },
      ),
    );
  }
}

class _AssignmentList extends StatelessWidget {
  const _AssignmentList({
    required this.items,
    required this.summary,
    required this.volunteerName,
    required this.onOpen,
  });

  final List<AssignmentListItem> items;
  final AssignmentSummary summary;
  final String volunteerName;
  final void Function(AssignmentListItem item)? onOpen;

  @override
  Widget build(BuildContext context) {
    final open = onOpen;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DashboardSummary(
              volunteerName: volunteerName,
              summary: summary,
            ),
          );
        }
        final item = items[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AssignmentCard(
            item: item,
            onTap: open == null ? null : () => open(item),
          ),
        );
      },
    );
  }
}
