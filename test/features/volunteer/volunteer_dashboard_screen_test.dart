import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:university_events/features/volunteer/contracts/assignment_failure.dart';
import 'package:university_events/features/volunteer/models/assignment_list_item.dart';
import 'package:university_events/features/volunteer/models/assignment_status.dart';
import 'package:university_events/features/volunteer/presentation/format.dart';
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

  Future<void> pumpScreen(
    WidgetTester tester, {
    void Function(AssignmentListItem)? onOpen,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: VolunteerDashboardScreen(
          assignments: repo,
          events: events,
          volunteerUid: kUid,
          volunteerName: 'Priya',
          onOpenAssignment: onOpen,
        ),
      ),
    );
  }

  // Lets the stream event and the async event lookups complete.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows a loading indicator before data arrives', (tester) async {
    await pumpScreen(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the empty state', (tester) async {
    await pumpScreen(tester);
    repo.emit([]);
    await settle(tester);

    expect(find.text('No assignments yet'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows the error state and recovers via Retry', (tester) async {
    await pumpScreen(tester);
    repo.emitError(const AssignmentFailure(AssignmentFailureType.network));
    await settle(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('Network problem'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    ]);
    await settle(tester);

    expect(find.text('Annual Robotics Showcase'), findsOneWidget);
    expect(repo.watchCount, 2);
  });

  testWidgets('renders welcome, summary and assignment cards', (tester) async {
    await pumpScreen(tester);
    repo.emit([
      assignment(
        id: 'a1',
        eventId: robotics.id,
        status: AssignmentStatus.assigned,
        role: 'Registration Desk',
      ),
      assignment(
        id: 'a2',
        eventId: workshop.id,
        status: AssignmentStatus.confirmed,
        role: 'Tech Support',
      ),
    ]);
    await settle(tester);

    expect(find.text('Welcome, Priya'), findsOneWidget);
    expect(find.text('1 assignment is waiting for your response.'),
        findsOneWidget);

    expect(find.text('Annual Robotics Showcase'), findsOneWidget);
    expect(find.text('Intro to Flutter Workshop'), findsOneWidget);
    expect(find.text('Role: Registration Desk'), findsOneWidget);
    expect(find.text('Role: Tech Support'), findsOneWidget);
    expect(find.text('Main Auditorium'), findsOneWidget);
    expect(find.text(formatEventDateTime(robotics.startTime)), findsOneWidget);

    expect(
        find.widgetWithText(AssignmentStatusChip, 'Assigned'), findsOneWidget);
    expect(
        find.widgetWithText(AssignmentStatusChip, 'Confirmed'), findsOneWidget);
  });

  testWidgets('does not show another volunteer\'s assignment', (tester) async {
    await pumpScreen(tester);
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
    await settle(tester);

    expect(find.text('Annual Robotics Showcase'), findsOneWidget);
    expect(find.text('Intro to Flutter Workshop'), findsNothing);
  });

  testWidgets('handles missing event information', (tester) async {
    await pumpScreen(tester);
    repo.emit([
      assignment(id: 'a1', eventId: 'gone', status: AssignmentStatus.assigned),
    ]);
    await settle(tester);

    expect(find.text('Event unavailable'), findsOneWidget);
    expect(find.text('Event details are not available right now.'),
        findsOneWidget);
  });

  testWidgets('tapping a card calls onOpenAssignment with that item',
      (tester) async {
    AssignmentListItem? opened;
    await pumpScreen(tester, onOpen: (item) => opened = item);
    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    ]);
    await settle(tester);

    await tester.tap(find.text('Annual Robotics Showcase'));
    await tester.pump();

    expect(opened?.id, 'a1');
  });

  testWidgets('updates the displayed status when Firestore data changes',
      (tester) async {
    await pumpScreen(tester);
    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.assigned),
    ]);
    await settle(tester);
    expect(
        find.widgetWithText(AssignmentStatusChip, 'Assigned'), findsOneWidget);

    repo.emit([
      assignment(
          id: 'a1', eventId: robotics.id, status: AssignmentStatus.confirmed),
    ]);
    await settle(tester);

    expect(find.widgetWithText(AssignmentStatusChip, 'Assigned'), findsNothing);
    expect(
        find.widgetWithText(AssignmentStatusChip, 'Confirmed'), findsOneWidget);
    expect(find.text('You are all caught up.'), findsOneWidget);
  });
}
