import 'assignment_list_item.dart';
import 'assignment_status.dart';

/// Counts shown at the top of the dashboard.
class AssignmentSummary {
  const AssignmentSummary({
    required this.total,
    required this.assigned,
    required this.confirmed,
    required this.declined,
  });

  factory AssignmentSummary.fromItems(Iterable<AssignmentListItem> items) {
    var assigned = 0, confirmed = 0, declined = 0, total = 0;
    for (final item in items) {
      total++;
      switch (item.assignment.status) {
        case AssignmentStatus.assigned:
          assigned++;
        case AssignmentStatus.confirmed:
          confirmed++;
        case AssignmentStatus.declined:
          declined++;
      }
    }
    return AssignmentSummary(
      total: total,
      assigned: assigned,
      confirmed: confirmed,
      declined: declined,
    );
  }

  final int total;
  final int assigned;
  final int confirmed;
  final int declined;
}
