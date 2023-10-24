/*import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';

void main() {
  group('Day Model Tests: ', () {
    group('findLargestTimeGap Tests', () {
      test('No time restraints', () {
        final day = Day(weekday: 1, date: DateTime.now());
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 0, endTime: 23, courseID: 'available'));
      });
      test('Single time slot covers the whole day', () {
        final day = Day(
          weekday: 2,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 0, endTime: 23, courseID: 'busy', weekday: 2)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(largestTimeGap, isNull);
      });

      test('Single time slot covers one hour at beginning', () {
        final day = Day(
          weekday: 2,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 0, endTime: 0, courseID: 'busy', weekday: 2)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                startTime: 1, endTime: 23, courseID: 'available', weekday: 2));
      });
      test('Single time slot covers one hour at end', () {
        final day = Day(
          weekday: 2,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 23, endTime: 23, courseID: 'busy', weekday: 2)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                startTime: 0, endTime: 22, courseID: 'available', weekday: 2));
      });
      test('Single time slot covers one hour at first half', () {
        final day = Day(
          weekday: 2,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 10, endTime: 10, courseID: 'busy', weekday: 2)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                startTime: 11, endTime: 23, courseID: 'available', weekday: 2));
      });
      test('Single time slot covers one hour at second half', () {
        final day = Day(
          weekday: 2,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 15, endTime: 15, courseID: 'busy', weekday: 2)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                startTime: 16, endTime: 23, courseID: 'available', weekday: 2));
      });
      test('One time restrictions - biggest gap in beginning', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 20, endTime: 22, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 23, endTime: 23, courseID: 'available'));
      });
      test('One time restrictions - biggest gap in end', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 2, endTime: 5, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 6, endTime: 23, courseID: 'available'));
      });

      test('One time restrictions - equal gaps', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 2, endTime: 21, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 22, endTime: 23, courseID: 'available'));
      });

      test('Two time restrictions - biggest gap in middle', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 0, endTime: 5, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 20, endTime: 21, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 22, endTime: 23, courseID: 'available'));
      });
      test('Two time restrictions - no gap between times', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 18, endTime: 22, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 23, endTime: 23, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 0, endTime: 17, courseID: 'available'));
      });

      test('Two time restrictions - biggest gap at end', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 0, endTime: 5, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 10, endTime: 13, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 14, endTime: 23, courseID: 'available'));
      });
      test('Two time restrictions - no gap', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 0, endTime: 5, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 6, endTime: 23, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(largestTimeGap, isNull);
      });

      test('Two time restrictions - three equal gaps', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 5, endTime: 9, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 15, endTime: 18, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 19, endTime: 23, courseID: 'available'));
      });

      test('Two time restrictions - one 1 hour gap', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 0, endTime: 9, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 11, endTime: 23, courseID: 'busy', weekday: 1),
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 10, endTime: 10, courseID: 'available'));
      });

      test('Three time restrictions - biggest gap at beginning', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 9, endTime: 10, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 11, endTime: 13, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 18, endTime: 23, courseID: 'busy', weekday: 1)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 14, endTime: 17, courseID: 'available'));
      });

      test('Three time restrictions - biggest gap at pos 1', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 2, endTime: 3, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 11, endTime: 13, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 18, endTime: 23, courseID: 'busy', weekday: 1)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 14, endTime: 17, courseID: 'available'));
      });

      test('Three time restrictions - biggest gap at pos 2', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 2, endTime: 3, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 4, endTime: 6, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 18, endTime: 23, courseID: 'busy', weekday: 1)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 7, endTime: 17, courseID: 'available'));
      });

      test('Three time restrictions - biggest gap at pos 3', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 2, endTime: 3, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 4, endTime: 6, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 10, endTime: 13, courseID: 'busy', weekday: 1)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                weekday: 1, startTime: 14, endTime: 23, courseID: 'available'));
      });

      test('Three time restrictions - no gaps', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 0, endTime: 3, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 4, endTime: 6, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 7, endTime: 23, courseID: 'busy', weekday: 1)
          ],
        );
        final largestTimeGap = day.findLatestTimegap();

        expect(largestTimeGap, isNull);
      });

      test('One hour yes, one hour no', () {
        final day = Day(
          weekday: 1,
          date: DateTime.now(),
          times: [
            TimeSlot(startTime: 1, endTime: 1, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 3, endTime: 3, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 5, endTime: 5, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 7, endTime: 7, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 9, endTime: 9, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 11, endTime: 11, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 13, endTime: 13, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 15, endTime: 15, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 17, endTime: 17, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 19, endTime: 19, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 21, endTime: 22, courseID: 'busy', weekday: 1),
            TimeSlot(startTime: 23, endTime: 23, courseID: 'busy', weekday: 1),
          ],
        );

        final largestTimeGap = day.findLatestTimegap();

        expect(
            largestTimeGap,
            TimeSlot(
                startTime: 20, endTime: 20, courseID: 'available', weekday: 1));
      });

      test('Only a one-hour gap', () => null);
    });
  });
}
*/