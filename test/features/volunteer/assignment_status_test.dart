import 'package:flutter_test/flutter_test.dart';
import 'package:university_events/features/volunteer/models/assignment_status.dart';

void main() {
  group('AssignmentStatus labels', () {
    test('have user-facing labels', () {
      expect(AssignmentStatus.assigned.label, 'Assigned');
      expect(AssignmentStatus.confirmed.label, 'Confirmed');
      expect(AssignmentStatus.declined.label, 'Declined');
    });
  });

  group('response eligibility', () {
    test('only assigned can respond', () {
      expect(AssignmentStatus.assigned.canRespond, isTrue);
      expect(AssignmentStatus.confirmed.canRespond, isFalse);
      expect(AssignmentStatus.declined.canRespond, isFalse);
    });

    test('confirmed and declined are final', () {
      expect(AssignmentStatus.assigned.isFinal, isFalse);
      expect(AssignmentStatus.confirmed.isFinal, isTrue);
      expect(AssignmentStatus.declined.isFinal, isTrue);
    });

    test('allows assigned -> confirmed and assigned -> declined', () {
      expect(
        AssignmentStatus.assigned.canTransitionTo(AssignmentStatus.confirmed),
        isTrue,
      );
      expect(
        AssignmentStatus.assigned.canTransitionTo(AssignmentStatus.declined),
        isTrue,
      );
    });

    test('rejects every other transition (responses are one-way)', () {
      for (final from in [
        AssignmentStatus.confirmed,
        AssignmentStatus.declined
      ]) {
        for (final to in AssignmentStatus.values) {
          expect(from.canTransitionTo(to), isFalse, reason: '$from -> $to');
        }
      }
      expect(
        AssignmentStatus.assigned.canTransitionTo(AssignmentStatus.assigned),
        isFalse,
      );
    });
  });

  group('tryParse', () {
    test('maps known values', () {
      expect(AssignmentStatus.tryParse('assigned'), AssignmentStatus.assigned);
      expect(
          AssignmentStatus.tryParse('confirmed'), AssignmentStatus.confirmed);
      expect(AssignmentStatus.tryParse('declined'), AssignmentStatus.declined);
    });

    test('returns null for unknown or missing values', () {
      expect(AssignmentStatus.tryParse('pending'), isNull);
      expect(AssignmentStatus.tryParse(''), isNull);
      expect(AssignmentStatus.tryParse(null), isNull);
    });
  });
}
