import 'dart:async';

import 'package:flutter/material.dart';

import '../features/volunteer/volunteer.dart';
import 'syncsphere_backend.dart';

void openVolunteerDashboard(BuildContext context) {
  final backend = SyncSphereBackend.instance;
  final volunteerUid = backend.currentUserId;
  if (volunteerUid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in to view volunteer assignments.')),
    );
    return;
  }

  final repository = FirebaseVolunteerBackend(backend);

  Future<void> respond(String assignmentId, AssignmentStatus status) async {
    try {
      await backend.respondToAssignment(
        assignmentId: assignmentId,
        status: status,
      );
    } on BackendException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (dashboardContext) => VolunteerDashboardScreen(
        assignments: repository,
        events: repository,
        volunteerUid: volunteerUid,
        volunteerName: backend.currentUserName,
        onOpenAssignment: (item) => Navigator.of(dashboardContext).push(
          MaterialPageRoute<void>(
            builder: (_) => VolunteerAssignmentDetailsScreen(
              assignments: repository,
              events: repository,
              volunteerUid: volunteerUid,
              assignmentId: item.id,
              onConfirm: () => unawaited(
                respond(item.id, AssignmentStatus.confirmed),
              ),
              onDecline: () => unawaited(
                respond(item.id, AssignmentStatus.declined),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class FirebaseVolunteerBackend implements AssignmentRepository, EventLookup {
  FirebaseVolunteerBackend(this.backend);

  final SyncSphereBackend backend;

  @override
  Stream<List<VolunteerAssignment>> watchMyAssignments(String volunteerUid) =>
      backend.watchMyVolunteerAssignments(volunteerUid);

  @override
  Stream<VolunteerAssignment?> watchAssignment(String assignmentId) =>
      backend.watchVolunteerAssignment(assignmentId);

  @override
  Future<EventSummary?> getEvent(String eventId) => backend.getEvent(eventId);
}
