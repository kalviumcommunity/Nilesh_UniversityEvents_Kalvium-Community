import 'event_summary.dart';

/// Minimal event access needed to display an assignment. Should be backed
/// by Aman's event repository. Returns null when the event does not exist.
abstract class EventLookup {
  Future<EventSummary?> getEvent(String eventId);
}

extension EventLookupSafe on EventLookup {
  /// A missing or failing event must never break an assignment screen, so
  /// any lookup error is treated as "event unavailable" (null).
  Future<EventSummary?> getEventOrNull(String eventId) async {
    try {
      return await getEvent(eventId);
    } catch (_) {
      return null;
    }
  }
}
