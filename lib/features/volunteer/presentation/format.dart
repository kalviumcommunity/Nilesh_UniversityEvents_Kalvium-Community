const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// Hand-rolled to avoid adding `intl`; swap for the project's formatter if
// the team adopts one.

String _time(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour < 12 ? 'AM' : 'PM'}';
}

/// e.g. "Thu, 5 Nov 2026".
String formatEventDate(DateTime t) =>
    '${_weekdays[t.weekday - 1]}, ${t.day} ${_months[t.month - 1]} ${t.year}';

/// e.g. "Thu, 5 Nov · 3:05 PM".
String formatEventDateTime(DateTime t) =>
    '${_weekdays[t.weekday - 1]}, ${t.day} ${_months[t.month - 1]} '
    '· ${_time(t)}';

/// "3:05 PM – 6:00 PM" on the same day, otherwise full date-times.
String formatEventTimeRange(DateTime start, DateTime end) {
  final sameDay = start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  return sameDay
      ? '${_time(start)} – ${_time(end)}'
      : '${formatEventDateTime(start)} – ${formatEventDateTime(end)}';
}
