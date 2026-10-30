import '../models/assignment_status.dart';

/// TEMPORARY stand-in for Aman's assignment model. Only the fields this
/// module needs. Replace by mapping his model onto this shape (or swap the
/// import) once his model exists; do not add fields to the schema here.
class VolunteerAssignment {
  const VolunteerAssignment({
    required this.id,
    required this.eventId,
    required this.volunteerUid,
    required this.role,
    required this.status,
    this.assignedAt,
    this.respondedAt,
  });

  final String id;
  final String eventId;
  final String volunteerUid;

  /// The volunteer's duty for the event (e.g. "Registration Desk").
  final String role;
  final AssignmentStatus status;
  final DateTime? assignedAt;
  final DateTime? respondedAt;
}
