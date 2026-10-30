import 'package:university_events/features/volunteer/contracts/event_summary.dart';
import 'package:university_events/features/volunteer/contracts/volunteer_assignment.dart';
import 'package:university_events/features/volunteer/models/assignment_status.dart';

const kUid = 'vol-1';
const kOtherUid = 'vol-2';

final robotics = EventSummary(
  id: 'e-robotics',
  title: 'Annual Robotics Showcase',
  startTime: DateTime(2026, 11, 5, 15, 5),
  endTime: DateTime(2026, 11, 5, 18),
  venueName: 'Main Auditorium',
  description:
      'Student robotics teams present live demos of this year\'s projects.',
);

final workshop = EventSummary(
  id: 'e-flutter',
  title: 'Intro to Flutter Workshop',
  startTime: DateTime(2026, 11, 20, 10),
  endTime: DateTime(2026, 11, 20, 12),
  venueName: 'Lab 3',
);

final careerFair = EventSummary(
  id: 'e-career',
  title: 'Campus Career Fair',
  startTime: DateTime(2026, 12, 2, 9),
  endTime: DateTime(2026, 12, 2, 16),
  venueName: 'Sports Hall',
);

VolunteerAssignment assignment({
  required String id,
  required String eventId,
  required AssignmentStatus status,
  String volunteerUid = kUid,
  String role = 'Registration Desk',
  DateTime? assignedAt,
  DateTime? respondedAt,
}) =>
    VolunteerAssignment(
      id: id,
      eventId: eventId,
      volunteerUid: volunteerUid,
      role: role,
      status: status,
      assignedAt: assignedAt,
      respondedAt: respondedAt,
    );
