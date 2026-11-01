import 'package:flutter/material.dart';

import '../../contracts/assignment_repository.dart';
import '../../contracts/event_lookup.dart';
import '../../models/assignment_list_item.dart';
import '../../state/assignment_details_controller.dart';
import '../format.dart';
import '../widgets/assignment_status_chip.dart';
import '../widgets/assignment_status_notice.dart';
import '../widgets/dashboard_message_view.dart';
import '../widgets/detail_row.dart';
import '../widgets/respond_buttons.dart';

/// Details of one assignment, loaded by id so a router can open it from a
/// path parameter alone. Navigation is the host's job: push this screen
/// from the dashboard's `onOpenAssignment`; the AppBar back button pops it.
///
/// [onConfirm] / [onDecline] are placeholders for Step 4 and are not wired
/// to any response logic yet.
class VolunteerAssignmentDetailsScreen extends StatefulWidget {
  const VolunteerAssignmentDetailsScreen({
    super.key,
    required this.assignments,
    required this.events,
    required this.volunteerUid,
    required this.assignmentId,
    this.onConfirm,
    this.onDecline,
  });

  final AssignmentRepository assignments;
  final EventLookup events;
  final String volunteerUid;
  final String assignmentId;
  final VoidCallback? onConfirm;
  final VoidCallback? onDecline;

  @override
  State<VolunteerAssignmentDetailsScreen> createState() =>
      _VolunteerAssignmentDetailsScreenState();
}

class _VolunteerAssignmentDetailsScreenState
    extends State<VolunteerAssignmentDetailsScreen> {
  late final AssignmentDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AssignmentDetailsController(
      assignments: widget.assignments,
      events: widget.events,
      volunteerUid: widget.volunteerUid,
      assignmentId: widget.assignmentId,
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
      appBar: AppBar(title: const Text('Assignment Details')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => switch (_controller.state) {
          DetailsLoading() => const Center(child: CircularProgressIndicator()),
          DetailsNotFound() => const DashboardMessageView(
              icon: Icons.search_off_outlined,
              title: 'Assignment not found',
              message:
                  'It may have been removed, or it is not assigned to you.',
            ),
          DetailsError(:final message) => DashboardMessageView(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              message: message,
              actionLabel: 'Retry',
              onAction: _controller.load,
            ),
          DetailsLoaded(:final item) => _DetailsBody(
              item: item,
              onConfirm: widget.onConfirm,
              onDecline: widget.onDecline,
            ),
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.item,
    required this.onConfirm,
    required this.onDecline,
  });

  final AssignmentListItem item;
  final VoidCallback? onConfirm;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignment = item.assignment;
    final event = item.event;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          event?.title ?? 'Event unavailable',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: AssignmentStatusChip(status: assignment.status),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event != null) ...[
                  DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: formatEventDate(event.startTime),
                  ),
                  DetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Time',
                    value: formatEventTimeRange(event.startTime, event.endTime),
                  ),
                  DetailRow(
                    icon: Icons.place_outlined,
                    label: 'Venue',
                    value: event.venueName,
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Event details are not available right now.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ),
                DetailRow(
                  icon: Icons.badge_outlined,
                  label: 'Your role',
                  value: assignment.role,
                ),
              ],
            ),
          ),
        ),
        if (event != null) ...[
          const SizedBox(height: 16),
          Text('About this event', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            event.description.isEmpty
                ? 'No description provided.'
                : event.description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 16),
        AssignmentStatusNotice(
          status: assignment.status,
          assignedAt: assignment.assignedAt,
          respondedAt: assignment.respondedAt,
        ),
        if (assignment.status.canRespond) ...[
          const SizedBox(height: 16),
          RespondButtons(onConfirm: onConfirm, onDecline: onDecline),
        ],
      ],
    );
  }
}
