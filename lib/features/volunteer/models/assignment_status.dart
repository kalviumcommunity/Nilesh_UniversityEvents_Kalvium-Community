/// Status handling for the volunteer module, isolated in one place.
///
/// PROVISIONAL: `assigned`, `confirmed`, `declined` are the values the team
/// proposed. Once Aman's model fixes the real Firestore strings, only
/// [tryParse] (and whatever adapter builds [VolunteerAssignment]) should
/// need to change; the rest of the module only uses this enum.
enum AssignmentStatus {
  assigned('Assigned'),
  confirmed('Confirmed'),
  declined('Declined');

  const AssignmentStatus(this.label);

  /// User-facing text.
  final String label;

  /// Whether the volunteer may still confirm or decline. Responses are
  /// one-way, so only a fresh `assigned` assignment can be answered.
  bool get canRespond => this == AssignmentStatus.assigned;

  /// True once the volunteer has answered; no further actions are offered.
  bool get isFinal => !canRespond;

  /// The only allowed transitions: assigned -> confirmed, assigned -> declined.
  bool canTransitionTo(AssignmentStatus next) =>
      this == AssignmentStatus.assigned &&
      (next == AssignmentStatus.confirmed || next == AssignmentStatus.declined);

  /// Maps a stored string to a status, or null if it is not recognised.
  /// This is the single mapping point to adjust to Aman's Firestore values.
  static AssignmentStatus? tryParse(String? raw) {
    for (final status in values) {
      if (status.name == raw) return status;
    }
    return null;
  }
}
