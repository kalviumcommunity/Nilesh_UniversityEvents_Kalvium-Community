import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:university_events/features/volunteer/contracts/assignment_failure.dart';
import 'package:university_events/features/volunteer/models/assignment_status.dart';
import 'package:university_events/features/volunteer/state/dashboard_controller.dart';

import 'fakes/fake_assignment_repository.dart';
import 'fakes/sample_data.dart';

void main() {
  late FakeAssignmentRepository repo;
  late FakeEventLookup events;
  late DashboardController controller;

  setUp(() {
    repo = FakeAssignmentRepository();
    events = FakeEventLookup([robotics, workshop, careerFair]);
    controller = DashboardController(
      assignments: repo,
      events: events,
      volunteerUid: kUid,
    );
  });

  tearDown(() {
    controller.dispose();
    repo.close();
  });

  DashboardLoaded loaded() => controller.state as DashboardLoaded;

  test('starts in loading and watches the volunteer\'s own uid', () {
    expect(controller.state, isA<DashboardLoading>());
    controller.load();
    expect(controller.state, isA<DashboardLoading>());
    expect(repo.watchCount, 1);
    expect(repo.lastUid, kUid);
  });

  test('emits empty when there are no assignments', () async {
    controller.load();
    repo.emit([]);
    await pumpEventQueue();
    expect(controller.state, isA<DashboardEmpty>());
  });

  test('joins assignments with events', () async {
    controller.load();
    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    ]);
    await pumpEventQueue();

    expect(loaded().items, hasLength(1));
    expect(loaded().items.single.event?.title, 'Annual Robotics Showcase');
    expect(loaded().items.single.assignment.role, 'Registration Desk');
  });

  test('sorts awaiting-response first, then by event start', () async {
    controller.load();
    repo.emit([
      assignment(
          id: 'a-confirmed',
          eventId: robotics.id,
          status: AssignmentStatus.confirmed),
      assignment(
          id: 'a-declined',
          eventId: careerFair.id,
          status: AssignmentStatus.declined),
      assignment(
          id: 'a-assigned',
          eventId: workshop.id,
          status: AssignmentStatus.assigned),
    ]);
    await pumpEventQueue();

    expect(
      loaded().items.map((i) => i.id).toList(),
      ['a-assigned', 'a-confirmed', 'a-declined'],
    );
  });

  test('filters out other volunteers\' assignments', () async {
    controller.load();
    repo.emit([
      assignment(
          id: 'mine', eventId: robotics.id, status: AssignmentStatus.assigned),
      assignment(
        id: 'theirs',
        eventId: workshop.id,
        status: AssignmentStatus.assigned,
        volunteerUid: kOtherUid,
      ),
    ]);
    await pumpEventQueue();

    expect(loaded().items.map((i) => i.id), ['mine']);
  });

  test('shows empty when every assignment belongs to someone else', () async {
    controller.load();
    repo.emit([
      assignment(
        id: 'theirs',
        eventId: workshop.id,
        status: AssignmentStatus.assigned,
        volunteerUid: kOtherUid,
      ),
    ]);
    await pumpEventQueue();
    expect(controller.state, isA<DashboardEmpty>());
  });

  test('keeps the item when the event does not exist', () async {
    controller.load();
    repo.emit([
      assignment(
          id: 'a1',
          eventId: 'missing-event',
          status: AssignmentStatus.assigned),
    ]);
    await pumpEventQueue();

    expect(loaded().items.single.event, isNull);
  });

  test('keeps the item when the event lookup throws', () async {
    events.failing.add(robotics.id);
    controller.load();
    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
      assignment(
          id: 'a2', eventId: workshop.id, status: AssignmentStatus.assigned),
    ]);
    await pumpEventQueue();

    final byId = {for (final i in loaded().items) i.id: i};
    expect(byId['a1']!.event, isNull);
    expect(byId['a2']!.event, isNotNull);
  });

  test('summary counts each status', () async {
    controller.load();
    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
      assignment(
          id: 'a2', eventId: workshop.id, status: AssignmentStatus.assigned),
      assignment(
          id: 'a3', eventId: careerFair.id, status: AssignmentStatus.confirmed),
      assignment(
          id: 'a4', eventId: careerFair.id, status: AssignmentStatus.declined),
    ]);
    await pumpEventQueue();

    final summary = loaded().summary;
    expect(summary.total, 4);
    expect(summary.assigned, 2);
    expect(summary.confirmed, 1);
    expect(summary.declined, 1);
  });

  test('updates live when an assignment\'s status changes', () async {
    controller.load();
    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    ]);
    await pumpEventQueue();
    expect(loaded().summary.assigned, 1);

    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.confirmed),
    ]);
    await pumpEventQueue();

    expect(loaded().summary.assigned, 0);
    expect(loaded().summary.confirmed, 1);
    expect(loaded().items.single.assignment.status, AssignmentStatus.confirmed);
  });

  group('errors', () {
    test('network failure gives a network message', () async {
      controller.load();
      repo.emitError(const AssignmentFailure(AssignmentFailureType.network));
      await pumpEventQueue();

      final state = controller.state as DashboardError;
      expect(state.message, contains('Network'));
    });

    test('permission denied gives a permission message', () async {
      controller.load();
      repo.emitError(
          const AssignmentFailure(AssignmentFailureType.permissionDenied));
      await pumpEventQueue();

      final state = controller.state as DashboardError;
      expect(state.message, contains('permission'));
    });

    test('unknown errors give a generic message', () async {
      controller.load();
      repo.emitError(StateError('boom'));
      await pumpEventQueue();

      final state = controller.state as DashboardError;
      expect(state.message, contains('Something went wrong'));
    });

    test('retry (load again) recovers from an error', () async {
      controller.load();
      repo.emitError(const AssignmentFailure(AssignmentFailureType.network));
      await pumpEventQueue();
      expect(controller.state, isA<DashboardError>());

      controller.load();
      expect(controller.state, isA<DashboardLoading>());
      repo.emit([
        assignment(
            id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
      ]);
      await pumpEventQueue();

      expect(controller.state, isA<DashboardLoaded>());
      expect(repo.watchCount, 2);
    });
  });

  test('a slow older lookup cannot overwrite a newer emission', () async {
    final gate = Completer<void>();
    events.gates[robotics.id] = gate;

    controller.load();
    repo.emit([
      assignment(
          id: 'old', eventId: robotics.id, status: AssignmentStatus.assigned),
    ]);
    await pumpEventQueue(); // first emission is stuck on the gate

    repo.emit([
      assignment(
          id: 'new', eventId: workshop.id, status: AssignmentStatus.assigned),
    ]);
    await pumpEventQueue();
    expect(loaded().items.map((i) => i.id), ['new']);

    gate.complete(); // the stale lookup finishes late
    await pumpEventQueue();
    expect(loaded().items.map((i) => i.id), ['new']);
  });

  test('does not notify after dispose', () async {
    controller.load();
    controller.dispose();
    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    ]);
    await pumpEventQueue();
    // Reaching here without a "used after dispose" error is the assertion.
    // tearDown disposes again; recreate so it stays valid.
    controller = DashboardController(
      assignments: repo,
      events: events,
      volunteerUid: kUid,
    );
  });
}
