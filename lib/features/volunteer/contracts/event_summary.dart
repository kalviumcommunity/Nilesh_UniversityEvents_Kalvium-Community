/// TEMPORARY stand-in for the few event fields this module displays.
/// Kept separate from the assignment on purpose: events are Aman's data.
class EventSummary {
  const EventSummary({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.venueName,
    this.description = '',
  });

  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String venueName;
}
