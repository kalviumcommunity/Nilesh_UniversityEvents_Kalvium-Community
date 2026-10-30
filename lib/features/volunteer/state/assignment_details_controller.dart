import 'dart:async';

import 'package:flutter/foundation.dart';

import '../contracts/assignment_repository.dart';
import '../contracts/event_lookup.dart';
import '../contracts/volunteer_assignment.dart';
import '../models/assignment_list_item.dart';
import 'failure_messages.dart';

sealed class DetailsState {
  const DetailsState();
}

final class DetailsLoading extends DetailsState {
  const DetailsLoading();
}

/// The assignment does not exist, or does not belong to this volunteer.
final class DetailsNotFound extends DetailsState {
  const DetailsNotFound();
}

final class DetailsError extends DetailsState {
  const DetailsError(this.message);
  final String message;
}

final class DetailsLoaded extends DetailsState {
  const DetailsLoaded(this.item);
  final AssignmentListItem item;
}

/// Loads one assignment by id and joins it with its event. Reuses
/// [AssignmentListItem] from the dashboard. Confirm/decline is not here yet
/// (Step 4).
class AssignmentDetailsController extends ChangeNotifier {
  AssignmentDetailsController({
    required AssignmentRepository assignments,
    required EventLookup events,
    required String volunteerUid,
    required String assignmentId,
  })  : _assignments = assignments,
        _events = events,
        _uid = volunteerUid,
        _assignmentId = assignmentId;

  final AssignmentRepository _assignments;
  final EventLookup _events;
  final String _uid;
  final String _assignmentId;

  DetailsState _state = const DetailsLoading();
  DetailsState get state => _state;

  StreamSubscription<VolunteerAssignment?>? _subscription;
  int _version = 0; // guards against stale async results
  bool _disposed = false;

  /// Starts (or restarts) listening. Also serves as "retry".
  void load() {
    _subscription?.cancel();
    _version++;
    _setState(const DetailsLoading());
    _subscription = _assignments.watchAssignment(_assignmentId).listen(
          _onAssignment,
          onError: _onError,
        );
  }

  void _onError(Object error, StackTrace _) {
    _version++;
    _setState(DetailsError(describeFailure(error, subject: 'this assignment')));
  }

  Future<void> _onAssignment(VolunteerAssignment? assignment) async {
    final version = ++_version;

    // Defence in depth only; real isolation is the repository + Security
    // Rules. Someone else's assignment is shown as "not found".
    if (assignment == null || assignment.volunteerUid != _uid) {
      _setState(const DetailsNotFound());
      return;
    }

    final event = await _events.getEventOrNull(assignment.eventId);
    if (version != _version) return;
    _setState(
      DetailsLoaded(AssignmentListItem(assignment: assignment, event: event)),
    );
  }

  void _setState(DetailsState next) {
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
