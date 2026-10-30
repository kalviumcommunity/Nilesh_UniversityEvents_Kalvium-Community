import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:university_events/features/volunteer/contracts/assignment_failure.dart';
import 'package:university_events/features/volunteer/models/assignment_status.dart';
import 'package:university_events/features/volunteer/presentation/format.dart';
import 'package:university_events/features/volunteer/presentation/screens/volunteer_assignment_details_screen.dart';
import 'package:university_events/features/volunteer/presentation/screens/volunteer_dashboard_screen.dart';
import 'package:university_events/features/volunteer/presentation/widgets/assignment_status_chip.dart';

import 'fakes/fake_assignment_repository.dart';
import 'fakes/sample_data.dart';

void main() {
  late FakeAssignmentRepository repo;
  late FakeEventLookup events;

  setUp(() {
    repo = FakeAssignmentRepository();
    events = FakeEventLookup([robotics, workshop]);
  });

  tearDown(() => repo.close());

  void bigScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpDetails(
    WidgetTester tester, {
    VoidCallback? onConfirm,
    VoidCallback? onDecline,
    String uid = kUid,
  }) async {
    bigScreen(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: VolunteerAssignmentDetailsScreen(
          assignments: repo,
          events: events,
          volunteerUid: uid,
          assignmentId: 'a1',
          onConfirm: onConfirm,
          onDecline: onDecline,
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows a loading indicator first', (tester) async {
    await pumpDetails(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows event and assignment information', (tester) async {
    await pumpDetails(tester);
    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    );
    await settle(tester);

    expect(find.text('Annual Robotics Showcase'), findsOneWidget);
    expect(find.text(formatEventDate(robotics.startTime)), findsOneWidget);
    expect(
      find.text(formatEventTimeRange(robotics.startTime, robotics.endTime)),
      findsOneWidget,
    );
    expect(find.text('Main Auditorium'), findsOneWidget);
    expect(find.text(robotics.description), findsOneWidget);
    expect(find.text('Your role'), findsOneWidget);
    expect(find.text('Registration Desk'), findsOneWidget);
    expect(
        find.widgetWithText(AssignmentStatusChip, 'Assigned'), findsOneWidget);
    expect(
      find.text('This assignment is waiting for your response.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a placeholder when the event has no description',
      (tester) async {
    await pumpDetails(tester);
    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: workshop.id, status: AssignmentStatus.assigned),
    );
    await settle(tester);

    expect(find.text('No description provided.'), findsOneWidget);
  });

  testWidgets('shows assigned and responded times when known', (tester) async {
    final assignedAt = DateTime(2026, 10, 1, 9, 30);
    final respondedAt = DateTime(2026, 10, 2, 14);
    await pumpDetails(tester);
    repo.emitAssignment(
      assignment(
        id: 'a1',
        eventId: robotics.id,
        status: AssignmentStatus.confirmed,
        assignedAt: assignedAt,
        respondedAt: respondedAt,
      ),
    );
    await settle(tester);

    expect(find.text('Assigned: ${formatEventDateTime(assignedAt)}'),
        findsOneWidget);
    expect(find.text('Responded: ${formatEventDateTime(respondedAt)}'),
        findsOneWidget);
  });

  group('Confirm / Decline buttons', () {
    testWidgets('are shown, but disabled, when no callbacks are given',
        (tester) async {
      await pumpDetails(tester);
      repo.emitAssignment(
        assignment(
            id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
      );
      await settle(tester);

      final confirm = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm'),
      );
      final decline = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Decline'),
      );
      expect(confirm.onPressed, isNull);
      expect(decline.onPressed, isNull);
    });

    testWidgets('call the provided callbacks', (tester) async {
      var confirmed = 0;
      var declined = 0;
      await pumpDetails(
        tester,
        onConfirm: () => confirmed++,
        onDecline: () => declined++,
      );
      repo.emitAssignment(
        assignment(
            id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
      );
      await settle(tester);

      await tester.tap(find.text('Confirm'));
      await tester.tap(find.text('Decline'));
      await tester.pump();

      expect(confirmed, 1);
      expect(declined, 1);
    });

    for (final status in [
      AssignmentStatus.confirmed,
      AssignmentStatus.declined
    ]) {
      testWidgets('are hidden once the assignment is ${status.name}',
          (tester) async {
        await pumpDetails(tester, onConfirm: () {}, onDecline: () {});
        repo.emitAssignment(
          assignment(id: 'a1', eventId: robotics.id, status: status),
        );
        await settle(tester);

        expect(find.widgetWithText(AssignmentStatusChip, status.label),
            findsOneWidget);
        expect(find.text('Confirm'), findsNothing);
        expect(find.text('Decline'), findsNothing);
      });
    }

    testWidgets('disappear when the status changes to a final value',
        (tester) async {
      await pumpDetails(tester, onConfirm: () {}, onDecline: () {});
      repo.emitAssignment(
        assignment(
            id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
      );
      await settle(tester);
      expect(find.text('Confirm'), findsOneWidget);

      repo.emitAssignment(
        assignment(
            id: 'a1', eventId: robotics.id, status: AssignmentStatus.confirmed),
      );
      await settle(tester);

      expect(find.text('Confirm'), findsNothing);
      expect(find.widgetWithText(AssignmentStatusChip, 'Confirmed'),
          findsOneWidget);
    });
  });

  testWidgets('handles missing event information', (tester) async {
    await pumpDetails(tester);
    repo.emitAssignment(
      assignment(id: 'a1', eventId: 'gone', status: AssignmentStatus.assigned),
    );
    await settle(tester);

    expect(find.text('Event unavailable'), findsOneWidget);
    expect(find.text('Event details are not available right now.'),
        findsOneWidget);
    expect(find.text('Registration Desk'), findsOneWidget);
    expect(
        find.widgetWithText(AssignmentStatusChip, 'Assigned'), findsOneWidget);
    expect(find.text('About this event'), findsNothing);
  });

  testWidgets('shows not found when the assignment does not exist',
      (tester) async {
    await pumpDetails(tester);
    repo.emitAssignment(null);
    await settle(tester);

    expect(find.text('Assignment not found'), findsOneWidget);
  });

  testWidgets('shows not found for another volunteer\'s assignment',
      (tester) async {
    await pumpDetails(tester);
    repo.emitAssignment(
      assignment(
        id: 'a1',
        eventId: robotics.id,
        status: AssignmentStatus.assigned,
        volunteerUid: kOtherUid,
      ),
    );
    await settle(tester);

    expect(find.text('Assignment not found'), findsOneWidget);
    expect(find.text('Annual Robotics Showcase'), findsNothing);
  });

  testWidgets('shows a permission error and recovers via Retry',
      (tester) async {
    await pumpDetails(tester);
    repo.emitAssignmentError(
      const AssignmentFailure(AssignmentFailureType.permissionDenied),
    );
    await settle(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('permission'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repo.emitAssignment(
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    );
    await settle(tester);

    expect(find.text('Annual Robotics Showcase'), findsOneWidget);
    expect(repo.watchAssignmentCount, 2);
  });

  testWidgets('dashboard card opens the details screen and back returns',
      (tester) async {
    bigScreen(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => VolunteerDashboardScreen(
            assignments: repo,
            events: events,
            volunteerUid: kUid,
            volunteerName: 'Priya',
            onOpenAssignment: (item) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => VolunteerAssignmentDetailsScreen(
                  assignments: repo,
                  events: events,
                  volunteerUid: kUid,
                  assignmentId: item.id,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final a1 = assignment(
      id: 'a1',
      eventId: robotics.id,
      status: AssignmentStatus.assigned,
    );
    repo.emit([a1]);
    await settle(tester);
    expect(find.text('My Assignments'), findsOneWidget);

    await tester.tap(find.text('Annual Robotics Showcase'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    repo.emitAssignment(a1);
    await settle(tester);

    expect(find.text('Assignment Details'), findsOneWidget);
    expect(repo.lastAssignmentId, 'a1');

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('My Assignments'), findsOneWidget);
    expect(find.text('Assignment Details'), findsNothing);
  });
}
