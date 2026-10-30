import 'package:flutter/material.dart';

import '../features/volunteer/volunteer.dart';

/// DEVELOPMENT PREVIEW ONLY. An in-memory stand-in for Aman's repositories
/// so the volunteer screens can be seen running. Delete this file and pass
/// the real repository/event lookup when they exist.
class DemoVolunteerBackend implements AssignmentRepository, EventLookup {
  static const demoUid = 'demo-volunteer';

  static final _events = {
    'e1': EventSummary(
      id: 'e1',
      title: 'Web Development Workshop',
      description: 'A beginner-friendly workshop to learn modern web '
          'development with hands-on projects.',
      startTime: DateTime(2026, 11, 12, 10),
      endTime: DateTime(2026, 11, 12, 13),
      venueName: 'Main Lab, Block A',
    ),
    'e2': EventSummary(
      id: 'e2',
      title: 'HackVerse 2025',
      startTime: DateTime(2026, 11, 25, 9),
      endTime: DateTime(2026, 11, 25, 21),
      venueName: 'Main Auditorium',
    ),
    'e3': EventSummary(
      id: 'e3',
      title: 'Design Sprint',
      description: 'Go from problem to prototype in a single day.',
      startTime: DateTime(2026, 12, 2, 9),
      endTime: DateTime(2026, 12, 2, 17),
      venueName: 'Studio 2, Block C',
    ),
  };

  static final _assignments = [
    const VolunteerAssignment(
      id: 'a1',
      eventId: 'e1',
      volunteerUid: demoUid,
      role: 'Registration Desk',
      status: AssignmentStatus.assigned,
    ),
    const VolunteerAssignment(
      id: 'a2',
      eventId: 'e2',
      volunteerUid: demoUid,
      role: 'Stage Support',
      status: AssignmentStatus.confirmed,
    ),
    const VolunteerAssignment(
      id: 'a3',
      eventId: 'e3',
      volunteerUid: demoUid,
      role: 'Logistics',
      status: AssignmentStatus.declined,
    ),
  ];

  @override
  Stream<List<VolunteerAssignment>> watchMyAssignments(String volunteerUid) =>
      Stream.value(
        _assignments.where((a) => a.volunteerUid == volunteerUid).toList(),
      );

  @override
  Stream<VolunteerAssignment?> watchAssignment(String assignmentId) {
    final matches = _assignments.where((a) => a.id == assignmentId);
    return Stream.value(matches.isEmpty ? null : matches.first);
  }

  @override
  Future<EventSummary?> getEvent(String eventId) async => _events[eventId];
}

/// Opens the volunteer dashboard with demo data. Shows the integration
/// point: the host decides how a tapped assignment is opened.
void openVolunteerDemo(BuildContext context) {
  final backend = DemoVolunteerBackend();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (dashboardContext) => VolunteerDashboardScreen(
        assignments: backend,
        events: backend,
        volunteerUid: DemoVolunteerBackend.demoUid,
        volunteerName: 'Nilesh',
        onOpenAssignment: (item) => Navigator.of(dashboardContext).push(
          MaterialPageRoute<void>(
            builder: (_) => VolunteerAssignmentDetailsScreen(
              assignments: backend,
              events: backend,
              volunteerUid: DemoVolunteerBackend.demoUid,
              assignmentId: item.id,
            ),
          ),
        ),
      ),
    ),
  );
}
