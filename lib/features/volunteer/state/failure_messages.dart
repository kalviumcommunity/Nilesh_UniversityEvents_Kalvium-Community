import '../contracts/assignment_failure.dart';

/// User-facing text for a load failure. [subject] completes the sentence,
/// e.g. "these assignments" or "this assignment".
String describeFailure(Object error, {String subject = 'these assignments'}) {
  if (error is AssignmentFailure) {
    return switch (error.type) {
      AssignmentFailureType.permissionDenied =>
        "You don't have permission to view $subject.",
      AssignmentFailureType.network =>
        'Network problem. Check your connection and try again.',
      AssignmentFailureType.notFound => "We couldn't find $subject.",
      AssignmentFailureType.invalidTransition ||
      AssignmentFailureType.unknown =>
        'Something went wrong while loading $subject.',
    };
  }
  return 'Something went wrong while loading $subject.';
}
