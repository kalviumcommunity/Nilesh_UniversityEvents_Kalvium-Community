import 'dart:async';

import 'package:university_events/features/volunteer/contracts/assignment_repository.dart';
import 'package:university_events/features/volunteer/contracts/event_lookup.dart';
import 'package:university_events/features/volunteer/contracts/event_summary.dart';
import 'package:university_events/features/volunteer/contracts/volunteer_assignment.dart';

/// Test/dev-preview fake. Emits only what a test pushes in, so tests can
/// also push another volunteer's data to check the controller's filter.
class FakeAssignmentRepository implements AssignmentRepository {
  final _stream = StreamController<List<VolunteerAssignment>>.broadcast();

  final _single = StreamController<VolunteerAssignment?>.broadcast();

  int watchCount = 0;
  String? lastUid;
  int watchAssignmentCount = 0;
  String? lastAssignmentId;

  @override
  Stream<List<VolunteerAssignment>> watchMyAssignments(String volunteerUid) {
    watchCount++;
    lastUid = volunteerUid;
    return _stream.stream;
  }

  @override
  Stream<VolunteerAssignment?> watchAssignment(String assignmentId) {
    watchAssignmentCount++;
    lastAssignmentId = assignmentId;
    return _single.stream;
  }

  void emit(List<VolunteerAssignment> assignments) => _stream.add(assignments);
  void emitError(Object error) => _stream.addError(error);

  void emitAssignment(VolunteerAssignment? assignment) =>
      _single.add(assignment);
  void emitAssignmentError(Object error) => _single.addError(error);

  Future<void> close() async {
    await _stream.close();
    await _single.close();
  }
}

class FakeEventLookup implements EventLookup {
  FakeEventLookup(Iterable<EventSummary> events)
      : _events = {for (final e in events) e.id: e};

  final Map<String, EventSummary> _events;

  /// Event ids whose lookup throws.
  final Set<String> failing = {};

  /// If a gate exists for an id, the lookup waits for it (simulates slowness).
  final Map<String, Completer<void>> gates = {};

  @override
  Future<EventSummary?> getEvent(String eventId) async {
    if (failing.contains(eventId)) throw StateError('lookup failed');
    final gate = gates[eventId];
    if (gate != null) await gate.future;
    return _events[eventId];
  }
}
