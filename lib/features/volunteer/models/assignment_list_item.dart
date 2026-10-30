import '../contracts/event_summary.dart';
import '../contracts/volunteer_assignment.dart';

/// View-model joining an assignment with its event for display. [event] is
/// null when the event could not be loaded; the UI must handle that.
class AssignmentListItem {
  const AssignmentListItem({required this.assignment, this.event});

  final VolunteerAssignment assignment;
  final EventSummary? event;

  String get id => assignment.id;
}
