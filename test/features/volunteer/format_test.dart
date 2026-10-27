import 'package:flutter_test/flutter_test.dart';
import 'package:university_events/features/volunteer/presentation/format.dart';

void main() {
  test('formats afternoon time', () {
    // 5 Nov 2026 is a Thursday.
    expect(
      formatEventDateTime(DateTime(2026, 11, 5, 15, 5)),
      'Thu, 5 Nov · 3:05 PM',
    );
  });

  test('handles midnight and noon', () {
    expect(
        formatEventDateTime(DateTime(2026, 11, 5, 0, 0)), contains('12:00 AM'));
    expect(formatEventDateTime(DateTime(2026, 11, 5, 12, 30)),
        contains('12:30 PM'));
  });

  test('formats a date with the year', () {
    expect(formatEventDate(DateTime(2026, 11, 5)), 'Thu, 5 Nov 2026');
  });

  test('time range on the same day shows only times', () {
    expect(
      formatEventTimeRange(
          DateTime(2026, 11, 5, 15, 5), DateTime(2026, 11, 5, 18)),
      '3:05 PM – 6:00 PM',
    );
  });

  test('time range across days shows dates too', () {
    expect(
      formatEventTimeRange(DateTime(2026, 11, 5, 22), DateTime(2026, 11, 6, 1)),
      'Thu, 5 Nov · 10:00 PM – Fri, 6 Nov · 1:00 AM',
    );
  });
}
