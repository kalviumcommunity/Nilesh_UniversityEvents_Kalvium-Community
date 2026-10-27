import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:university_events/features/volunteer/contracts/assignment_failure.dart';
import 'package:university_events/features/volunteer/models/assignment_status.dart';
import 'package:university_events/features/volunteer/state/assignment_details_controller.dart';

import 'fakes/fake_assignment_repository.dart';
import 'fakes/sample_data.dart';

void main() {
  late FakeAssignmentRepository repo;
  late FakeEventLookup events;
  late AssignmentDetailsController controller;

  setUp(() {
    repo = FakeAssignmentRepository();
    events = FakeEventLookup([robotics, workshop]);
    controller = AssignmentDetailsController(
      assignments: repo,
      events: events,
      volunteerUid: kUid,
      assignmentId: 'a1',
    );
  });

  tearDown(() {
    controller.dispose();
    repo.close();
  });

  DetailsLoaded loaded() => controller.state as DetailsLoaded;

  test('starts loading and watches the requested assignment id', () {
    expect(controller.state, isA<DetailsLoading>());
    controller.load();
    expect(repo.watchAssignmentCount, 1);
    expect(repo.lastAssignmentId, 'a1');
  });

  test('joins the assignment with its event', () async {
    controller.load();
    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    );
    await pumpEventQueue();

    expect(loaded().item.event?.title, 'Annual Robotics Showcase');
    expect(loaded().item.assignment.status, AssignmentStatus.assigned);
  });

  test('null assignment means not found', () async {
    controller.load();
    repo.emitAssignment(null);
    await pumpEventQueue();
    expect(controller.state, isA<DetailsNotFound>());
  });

  test('another volunteer\'s assignment is treated as not found', () async {
    controller.load();
    repo.emitAssignment(
      assignment(
        id: 'a1',
        eventId: robotics.id,
        status: AssignmentStatus.assigned,
        volunteerUid: kOtherUid,
      ),
    );
    await pumpEventQueue();
    expect(controller.state, isA<DetailsNotFound>());
  });

  test('missing event still loads with a null event', () async {
    controller.load();
    repo.emitAssignment(
      assignment(id: 'a1', eventId: 'gone', status: AssignmentStatus.assigned),
    );
    await pumpEventQueue();
    expect(loaded().item.event, isNull);
  });

  test('failing event lookup still loads with a null event', () async {
    events.failing.add(robotics.id);
    controller.load();
    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    );
    await pumpEventQueue();
    expect(loaded().item.event, isNull);
  });

  test('updates live when the status changes', () async {
    controller.load();
    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    );
    await pumpEventQueue();
    expect(loaded().item.assignment.status.canRespond, isTrue);

    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.confirmed),
    );
    await pumpEventQueue();
    expect(loaded().item.assignment.status, AssignmentStatus.confirmed);
  });

  group('errors', () {
    test('permission denied gives a permission message', () async {
      controller.load();
      repo.emitAssignmentError(
        const AssignmentFailure(AssignmentFailureType.permissionDenied),
      );
      await pumpEventQueue();
      expect(
          (controller.state as DetailsError).message, contains('permission'));
    });

    test('network failure gives a network message', () async {
      controller.load();
      repo.emitAssignmentError(
          const AssignmentFailure(AssignmentFailureType.network));
      await pumpEventQueue();
      expect((controller.state as DetailsError).message, contains('Network'));
    });

    test('retry recovers from an error', () async {
      controller.load();
      repo.emitAssignmentError(
          const AssignmentFailure(AssignmentFailureType.network));
      await pumpEventQueue();
      expect(controller.state, isA<DetailsError>());

      controller.load();
      expect(controller.state, isA<DetailsLoading>());
      repo.emitAssignment(
        assignment(
            id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
      );
      await pumpEventQueue();
      expect(controller.state, isA<DetailsLoaded>());
      expect(repo.watchAssignmentCount, 2);
    });
  });

  test('a slow older lookup cannot overwrite a newer emission', () async {
    final gate = Completer<void>();
    events.gates[robotics.id] = gate;

    controller.load();
    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    );
    await pumpEventQueue(); // stuck on the gate

    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: workshop.id, status: AssignmentStatus.confirmed),
    );
    await pumpEventQueue();
    expect(loaded().item.assignment.status, AssignmentStatus.confirmed);

    gate.complete();
    await pumpEventQueue();
    expect(loaded().item.assignment.status, AssignmentStatus.confirmed);
    expect(loaded().item.event?.id, workshop.id);
  });
}
