import 'dart:async';

import 'package:flutter/foundation.dart';

import '../contracts/assignment_repository.dart';
import '../contracts/event_lookup.dart';
import '../contracts/volunteer_assignment.dart';
import '../models/assignment_list_item.dart';
import '../models/assignment_summary.dart';
import 'failure_messages.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardEmpty extends DashboardState {
  const DashboardEmpty();
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;
}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded({required this.items, required this.summary});
  final List<AssignmentListItem> items;
  final AssignmentSummary summary;
}

/// Loads the signed-in volunteer's assignments and joins each with its
/// event. Plain [ChangeNotifier] so it works with `ListenableBuilder` today
/// and is easy to wrap in Provider/Riverpod/Bloc later.
class DashboardController extends ChangeNotifier {
  DashboardController({
    required AssignmentRepository assignments,
    required EventLookup events,
    required String volunteerUid,
  })  : _assignments = assignments,
        _events = events,
        _uid = volunteerUid;

  final AssignmentRepository _assignments;
  final EventLookup _events;
  final String _uid;

  DashboardState _state = const DashboardLoading();
  DashboardState get state => _state;

  StreamSubscription<List<VolunteerAssignment>>? _subscription;

  /// Bumped on every (re)load and every emission so a slow, older event
  /// lookup can never overwrite a newer result.
  int _version = 0;
  bool _disposed = false;

  /// Starts (or restarts) listening. Also serves as "retry".
  void load() {
    _subscription?.cancel();
    _version++;
    _setState(const DashboardLoading());
    _subscription = _assignments.watchMyAssignments(_uid).listen(
          _onAssignments,
          onError: _onError,
        );
  }

  void _onError(Object error, StackTrace _) {
    _version++;
    _setState(DashboardError(describeFailure(error)));
  }

  Future<void> _onAssignments(List<VolunteerAssignment> all) async {
    final version = ++_version;

    // Defence in depth only; real isolation is the repository + Security Rules.
    final mine = all.where((a) => a.volunteerUid == _uid).toList();
    if (mine.isEmpty) {
      _setState(const DashboardEmpty());
      return;
    }

    final items = await Future.wait(
      mine.map(
        (a) async => AssignmentListItem(
          assignment: a,
          event: await _events.getEventOrNull(a.eventId),
        ),
      ),
    );

    if (version != _version) return; // a newer emission/reload took over
    items.sort(_compare);
    _setState(
      DashboardLoaded(
          items: items, summary: AssignmentSummary.fromItems(items)),
    );
  }

  /// Awaiting-response first, then by event start; unknown events last.
  static int _compare(AssignmentListItem a, AssignmentListItem b) {
    final byAction = (a.assignment.status.canRespond ? 0 : 1)
        .compareTo(b.assignment.status.canRespond ? 0 : 1);
    if (byAction != 0) return byAction;

    final aStart = a.event?.startTime;
    final bStart = b.event?.startTime;
    if (aStart != null && bStart != null) {
      final byTime = aStart.compareTo(bStart);
      if (byTime != 0) return byTime;
    } else if (aStart == null && bStart != null) {
      return 1;
    } else if (aStart != null && bStart == null) {
      return -1;
    }
    return a.id.compareTo(b.id);
  }

  void _setState(DashboardState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
