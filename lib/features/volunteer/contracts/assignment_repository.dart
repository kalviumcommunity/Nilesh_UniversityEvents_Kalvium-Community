import 'volunteer_assignment.dart';

/// What the volunteer module needs from the assignment data layer.
/// Aman's Firestore-backed repository should implement (or be adapted to)
/// this. Step 4 will add `respond`.
abstract class AssignmentRepository {
  /// Real-time list of assignments for [volunteerUid]. The implementation
  /// must only ever return that volunteer's assignments (and Security Rules
  /// must enforce it). Errors are emitted as [AssignmentFailure].
  Stream<List<VolunteerAssignment>> watchMyAssignments(String volunteerUid);

  /// Real-time single assignment; emits null when it does not exist.
  /// Errors (including permission denied for someone else's assignment)
  /// are emitted as [AssignmentFailure].
  Stream<VolunteerAssignment?> watchAssignment(String assignmentId);
}
