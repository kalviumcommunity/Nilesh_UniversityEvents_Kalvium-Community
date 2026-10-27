enum AssignmentFailureType {
  permissionDenied,
  notFound,
  invalidTransition,
  network,
  unknown,
}

/// Typed error the repository throws (or emits on a stream), so the UI
/// never has to know about FirebaseException. The real repository maps
/// Firebase errors to these; that mapping belongs to Aman's implementation.
class AssignmentFailure implements Exception {
  const AssignmentFailure(this.type, [this.message]);

  final AssignmentFailureType type;
  final String? message;

  @override
  String toString() =>
      'AssignmentFailure($type${message == null ? '' : ': $message'})';
}
