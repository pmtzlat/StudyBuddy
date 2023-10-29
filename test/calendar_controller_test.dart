import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/modules/calendar/calendar_controller.dart';

void main() {
  group('Manage gap generation', () {
    group('Empty list', () {
      test('add TimeSlot(00:00 - 23:59)', () async {
        final controller = CalendarController();
        final start = TimeOfDay(hour: 0, minute: 0);
        final end = TimeOfDay(hour: 23, minute: 59);

        final weekday = 1;

        final provisionalList = <TimeSlot>[];
        final expectedResult = [
          TimeSlot(
              courseID: 'free',
              startTime: start,
              endTime: end,
              weekday: weekday)
        ];

        final result = await controller.checkGapClash(
            start, end, weekday, provisionalList);

        expect(result, expectedResult);
      });

      test('add TimeSlot(01:00 - 01:00)', () async {
        final controller = CalendarController();
        final start = TimeOfDay(hour: 1, minute: 0);
        final end = TimeOfDay(hour: 1, minute: 00);

        final weekday = 1;

        final provisionalList = <TimeSlot>[];
        final expectedResult = [];

        final result = await controller.checkGapClash(
            start, end, weekday, provisionalList);

        expect(result, expectedResult);
      });

      test('add TimeSlot(01:00 - 01:01)', () async {
        final controller = CalendarController();
        final start = TimeOfDay(hour: 1, minute: 0);
        final end = TimeOfDay(hour: 1, minute: 1);

        final weekday = 1;

        final provisionalList = <TimeSlot>[];
        final expectedResult = [
          TimeSlot(
              courseID: 'free',
              startTime: start,
              endTime: end,
              weekday: weekday)
        ];

        final result = await controller.checkGapClash(
            start, end, weekday, provisionalList);

        expect(result, expectedResult);
      });

      test('add TimeSlot(01:00 - 02:00)', () async {
        final controller = CalendarController();
        final start = TimeOfDay(hour: 1, minute: 0);
        final end = TimeOfDay(hour: 2, minute: 0);

        final weekday = 1;

        final provisionalList = <TimeSlot>[];
        final expectedResult = [
          TimeSlot(
              courseID: 'free',
              startTime: start,
              endTime: end,
              weekday: weekday)
        ];

        final result = await controller.checkGapClash(
            start, end, weekday, provisionalList);

        expect(result, expectedResult);
      });

      test('add TimeSlot(22:00 - 23:59)', () async {
        final controller = CalendarController();
        final start = TimeOfDay(hour: 22, minute: 0);
        final end = TimeOfDay(hour: 23, minute: 59);

        final weekday = 1;

        final provisionalList = <TimeSlot>[];
        final expectedResult = [
          TimeSlot(
              courseID: 'free',
              startTime: start,
              endTime: end,
              weekday: weekday)
        ];

        final result = await controller.checkGapClash(
            start, end, weekday, provisionalList);

        expect(result, expectedResult);
      });
    });
    group('1 present:', () {
      group('new separate from old:', () {
        test('new.start = old.one + x', () async {
          // Test logic for new.start = old.one + x
          final weekday = 1;

          final provisionalList = <TimeSlot>[
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 11, minute: 30);
          final end = TimeOfDay(hour: 12, minute: 00);

          final expectedResult = [
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
            TimeSlot(
                courseID: 'free',
                startTime: start,
                endTime: end,
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
        test('new.end = old.start - x', () async {
          // Test logic for new.end = old.start - x
          final weekday = 1;

          final provisionalList = <TimeSlot>[
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 9, minute: 2);
          final end = TimeOfDay(hour: 9, minute: 30);

          final expectedResult = [
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
            TimeSlot(
                courseID: 'free',
                startTime: start,
                endTime: end,
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
      });

      group('new contained in old:', () {
        test('new.start = old.start, new.end = old.end', () async {
          // Test logic for new.start = old.start, new.end = old.end
          final weekday = 1;

          final provisionalList = <TimeSlot>[
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 10, minute: 0);
          final end = TimeOfDay(hour: 11, minute: 00);

          final expectedResult = [
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
        test('new.start = old.start + x, new.end = old.end - x', () async {
          // Test logic for new.start = old.start + x, new.end = old.end - x
          final weekday = 1;

          final provisionalList = <TimeSlot>[
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 10, minute: 2);
          final end = TimeOfDay(hour: 10, minute: 58);

          final expectedResult = [
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
      });

      group('new contains old:', () {
        test('new.start = old.start, new.end = old.end', () async {
          // Test logic for new.start = old.start, new.end = old.end
          final weekday = 1;

          final provisionalList = <TimeSlot>[
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 10, minute: 0);
          final end = TimeOfDay(hour: 11, minute: 00);

          final expectedResult = [
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });

        test('new.start = old.start - a, new.end = old.end + a', () async {
          // Test logic for new.start = old.start + a, new.end = old.end - a
          final weekday = 1;

          final provisionalList = <TimeSlot>[
            TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free'),
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 9, minute: 58);
          final end = TimeOfDay(hour: 11, minute: 02);

          final expectedResult = [
            TimeSlot(
                courseID: 'free',
                startTime: start,
                endTime: end,
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
      });

      group('new starts in old:', () {
        test('new.start = old.start, new.end = old.end + x', () async {
          // Test logic for new.start = old.start, new.end = old.end + x
          final weekday = 1;
          final old = TimeSlot(
              weekday: weekday,
              startTime: TimeOfDay(hour: 10, minute: 0),
              endTime: TimeOfDay(hour: 11, minute: 0),
              courseID: 'free');

          final provisionalList = <TimeSlot>[
            old,
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 10, minute: 0);
          final end = TimeOfDay(hour: 11, minute: 02);

          final expectedResult = [
            TimeSlot(
                courseID: 'free',
                startTime: start,
                endTime: end,
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
        test('new.start = old.start + x, new.end = old.end + x', () async {
          // Test logic for new.start = old.start + x, new.end = old.end + x
          final weekday = 1;
          final old = TimeSlot(
              weekday: weekday,
              startTime: TimeOfDay(hour: 10, minute: 0),
              endTime: TimeOfDay(hour: 11, minute: 0),
              courseID: 'free');

          final provisionalList = <TimeSlot>[
            old,
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 10, minute: 2);
          final end = TimeOfDay(hour: 11, minute: 02);

          final expectedResult = [
            TimeSlot(
                courseID: 'free',
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: end,
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
        test('new.start = old.end, new.end = old.end + x', () async {
          // Test logic for new.start = old.end, new.end = old.end + x
          final weekday = 1;
          final old = TimeSlot(
              weekday: weekday,
              startTime: TimeOfDay(hour: 10, minute: 0),
              endTime: TimeOfDay(hour: 11, minute: 0),
              courseID: 'free');

          final provisionalList = <TimeSlot>[
            old,
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 11, minute: 00);
          final end = TimeOfDay(hour: 11, minute: 02);

          final expectedResult = [
            TimeSlot(
                courseID: 'free',
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: end,
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
      });

      group('old starts in new:', () {
        test('old.start = new.start, old.end = new.end + x', () async {
          final weekday = 1;
          final old = TimeSlot(
              weekday: weekday,
              startTime: TimeOfDay(hour: 10, minute: 0),
              endTime: TimeOfDay(hour: 11, minute: 2),
              courseID: 'free');

          final provisionalList = <TimeSlot>[
            old,
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 10, minute: 00);
          final end = TimeOfDay(hour: 11, minute: 00);

          final expectedResult = [
            TimeSlot(
                courseID: 'free',
                startTime: start,
                endTime: TimeOfDay(hour: 11, minute: 2),
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
        test('old.start = new.start + x, old.end = new.end + x', () async {
          final weekday = 1;
          final old = TimeSlot(
              weekday: weekday,
              startTime: TimeOfDay(hour: 10, minute: 2),
              endTime: TimeOfDay(hour: 11, minute: 2),
              courseID: 'free');

          final provisionalList = <TimeSlot>[
            old,
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 10, minute: 00);
          final end = TimeOfDay(hour: 11, minute: 00);

          final expectedResult = [
            TimeSlot(
                courseID: 'free',
                startTime: start,
                endTime: TimeOfDay(hour: 11, minute: 2),
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
        test('old.start = new.end, old.end = new.end + x', () async {
          final weekday = 1;
          final old = TimeSlot(
              weekday: weekday,
              startTime: TimeOfDay(hour: 10, minute: 1),
              endTime: TimeOfDay(hour: 11, minute: 2),
              courseID: 'free');

          final provisionalList = <TimeSlot>[
            old,
          ];

          final controller = CalendarController();
          final start = TimeOfDay(hour: 10, minute: 00);
          final end = TimeOfDay(hour: 11, minute: 00);

          final expectedResult = [
            TimeSlot(
                courseID: 'free',
                startTime: start,
                endTime: TimeOfDay(hour: 11, minute: 2),
                weekday: weekday)
          ];

          final result = await controller.checkGapClash(
              start, end, weekday, provisionalList);

          expect(result, expectedResult);
        });
      });
    });

    group('2 present:', () {
      group('Same ones as one old but with one more old one unaffected', () {
        group('new separate from old:', () {
          test('new.start = old.one + x', () async {
            // Test logic for new.start = old.one + x
            final weekday = 1;

            final provisionalList = <TimeSlot>[
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 11, minute: 30);
            final end = TimeOfDay(hour: 12, minute: 00);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: start,
                  endTime: end,
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });
          test('new.end = old.start - x', () async {
            // Test logic for new.end = old.start - x
            final weekday = 1;

            final provisionalList = <TimeSlot>[
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 9, minute: 2);
            final end = TimeOfDay(hour: 9, minute: 30);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: start,
                  endTime: end,
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });
        });

        group('new contained in old:', () {
          test('new.start = old.start, new.end = old.end', () async {
            // Test logic for new.start = old.start, new.end = old.end
            final weekday = 1;

            final provisionalList = <TimeSlot>[
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 10, minute: 0);
            final end = TimeOfDay(hour: 11, minute: 00);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });

          test('new.start = old.start + x, new.end = old.end - x', () async {
            // Test logic for new.start = old.start + x, new.end = old.end - x
            final weekday = 1;

            final provisionalList = <TimeSlot>[
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 10, minute: 2);
            final end = TimeOfDay(hour: 10, minute: 58);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });
        });

        group('new contains old:', () {
          test('new.start = old.start, new.end = old.end', () async {
            // Test logic for new.start = old.start, new.end = old.end
            final weekday = 1;

            final provisionalList = <TimeSlot>[
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 10, minute: 0);
            final end = TimeOfDay(hour: 11, minute: 00);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });

          test('new.start = old.start - a, new.end = old.end + a', () async {
            // Test logic for new.start = old.start + a, new.end = old.end - a
            final weekday = 1;

            final provisionalList = <TimeSlot>[
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: TimeOfDay(hour: 11, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 9, minute: 58);
            final end = TimeOfDay(hour: 11, minute: 02);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: start,
                  endTime: end,
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });
        });

        group('new starts in old:', () {
          test('new.start = old.start, new.end = old.end + x', () async {
            // Test logic for new.start = old.start, new.end = old.end + x
            final weekday = 1;
            final old = TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free');

            final provisionalList = <TimeSlot>[
              old,
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 10, minute: 0);
            final end = TimeOfDay(hour: 11, minute: 02);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: start,
                  endTime: end,
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });

          test('new.start = old.start + x, new.end = old.end + x', () async {
            // Test logic for new.start = old.start + x, new.end = old.end + x
            final weekday = 1;
            final old = TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free');

            final provisionalList = <TimeSlot>[
              old,
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 10, minute: 2);
            final end = TimeOfDay(hour: 11, minute: 02);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: end,
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });
          test('new.start = old.end, new.end = old.end + x', () async {
            // Test logic for new.start = old.end, new.end = old.end + x
            final weekday = 1;
            final old = TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 0),
                courseID: 'free');

            final provisionalList = <TimeSlot>[
              old,
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 11, minute: 00);
            final end = TimeOfDay(hour: 11, minute: 02);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: TimeOfDay(hour: 10, minute: 0),
                  endTime: end,
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });
        });

        group('old starts in new:', () {
          test('old.start = new.start, old.end = new.end + x', () async {
            final weekday = 1;
            final old = TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 0),
                endTime: TimeOfDay(hour: 11, minute: 2),
                courseID: 'free');

            final provisionalList = <TimeSlot>[
              old,
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 10, minute: 00);
            final end = TimeOfDay(hour: 11, minute: 00);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: start,
                  endTime: TimeOfDay(hour: 11, minute: 2),
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });

          test('old.start = new.start + x, old.end = new.end + x', () async {
            final weekday = 1;
            final old = TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 2),
                endTime: TimeOfDay(hour: 11, minute: 2),
                courseID: 'free');

            final provisionalList = <TimeSlot>[
              old,
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 10, minute: 00);
            final end = TimeOfDay(hour: 11, minute: 00);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: start,
                  endTime: TimeOfDay(hour: 11, minute: 2),
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });

          test('old.start = new.end, old.end = new.end + x', () async {
            final weekday = 1;
            final old = TimeSlot(
                weekday: weekday,
                startTime: TimeOfDay(hour: 10, minute: 1),
                endTime: TimeOfDay(hour: 11, minute: 2),
                courseID: 'free');

            final provisionalList = <TimeSlot>[
              old,
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
            ];

            final controller = CalendarController();
            final start = TimeOfDay(hour: 10, minute: 00);
            final end = TimeOfDay(hour: 11, minute: 00);

            final expectedResult = [
              TimeSlot(
                  weekday: weekday,
                  startTime: TimeOfDay(hour: 22, minute: 0),
                  endTime: TimeOfDay(hour: 23, minute: 0),
                  courseID: 'free'),
              TimeSlot(
                  courseID: 'free',
                  startTime: start,
                  endTime: TimeOfDay(hour: 11, minute: 2),
                  weekday: weekday)
            ];

            final result = await controller.checkGapClash(
                start, end, weekday, provisionalList);

            expect(result, expectedResult);
          });
        });
      });
      group('new one starts and ends inside two different ones:', () {
        test('t(new.start = old1.start, new.end = old2.end)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.end)
        });
        test('t(new.start = old1.start + a, new.end = old2.end) where 1 < a',
            () {
          // Test logic for t(new.start = old1.start + a, new.end = old2.end) where 1 < a
        });
        test('t(new.start = old1.start, new.end = old2.end - a) where 1 < a',
            () {
          // Test logic for t(new.start = old1.start, new.end = old2.end - a) where 1 < a
        });
        test(
            't(new.start = old1.start + a, new.start = old2.end - a) where 1 < a',
            () {
          // Test logic for t(new.start = old1.start + a, new.start = old2.end - a) where 1 < a
        });
        test('t(new.start = old1.end, new.end = old2.start)', () {
          // Test logic for t(new.start = old1.end, new.end = old2.start)
        });
      });

      group('new one is independent:', () {
        test(
            'new.start = old1.start - a, new.end = old1.start - b where a > b > 2',
            () {
          // Test logic for t(new.start = old1.start - a, new.end = old1.start - b) where a > b > 2
        });

        test(
            'new.start = old1.end + a, new.end = old2.start - b where a, b > 2',
            () {
          // Test logic for t(new.start = old1.end + a, new.end = old2.start - b) where a, b > 2
        });

        test('new.start = old2.end + a, new.end = old2.end + b where a < b',
            () {
          // Test logic for t(new.start = old2.end + a, new.end = old2.end + b) where a < b
        });
      });

      group('new one encloses both:', () {
        test('t(new.start = old1.start, new.end = old2.end)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.end)
        });

        test('t(new.start = old1.start - a, new.end = old2.end) where a > 1',
            () {
          // Test logic for t(new.start = old1.start - a, new.end = old2.end) where a > 1
        });

        test('t(new.start = old1.start, new.end = old2.end + a)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.end + a)
        });

        test('t(new.start = old1.start - a, new.end = old2.end + a)', () {
          // Test logic for t(new.start = old1.start - a, new.end = old2.end + a)
        });
      });
    });

    group('3 present:', () {
      group(
          '(all the tests for 2 present, but with one timelot separated that isnt affected)',
          () {
        // Tests for 2 present but with one timelot separated that isn't affected

        group('new one starts and ends inside two different ones:', () {
          test('t(new.start = old1.start, new.end = old2.end)', () {
            // Test logic for t(new.start = old1.start, new.end = old2.end)
          });

          test('t(new.start = old1.start + a, new.end = old2.end) where 1 < a',
              () {
            // Test logic for t(new.start = old1.start + a, new.end = old2.end) where 1 < a
          });
          test('t(new.start = old1.start, new.end = old2.end - a) where 1 < a',
              () {
            // Test logic for t(new.start = old1.start, new.end = old2.end - a) where 1 < a
          });
          test(
              't(new.start = old1.start + a, new.start = old2.end - a) where 1 < a',
              () {
            // Test logic for t(new.start = old1.start + a, new.start = old2.end - a) where 1 < a
          });
          test('t(new.start = old1.end, new.end = old2.start)', () {
            // Test logic for t(new.start = old1.end, new.end = old2.start)
          });
        });

        group('new one is independent:', () {
          test(
              't(new.start = old1.start - a, new.end = old1.start - b) where a > b > 2',
              () {
            // Test logic for t(new.start = old1.start - a, new.end = old1.start - b) where a > b > 2
          });

          test(
              't(new.start = old1.end + a, new.end = old2.start - b) where a, b > 2',
              () {
            // Test logic for t(new.start = old1.end + a, new.end = old2.start - b) where a, b > 2
          });

          test(
              't(new.start = old2.end + a, new.end = old2.end + b) where a < b',
              () {
            // Test logic for t(new.start = old2.end + a, new.end = old2.end + b) where a < b
          });
        });

        group('new one encloses both:', () {
          test('t(new.start = old1.start, new.end = old2.end)', () {
            // Test logic for t(new.start = old1.start, new.end = old2.end)
          });

          test('t(new.start = old1.start - a, new.end = old2.end) where a > 1',
              () {
            // Test logic for t(new.start = old1.start - a, new.end = old2.end) where a > 1
          });

          test('t(new.start = old1.start, new.end = old2.end + a)', () {
            // Test logic for t(new.start = old1.start, new.end = old2.end + a)
          });

          test('t(new.start = old1.start - a, new.end = old2.end + a)', () {
            // Test logic for t(new.start = old1.start - a, new.end = old2.end + a)
          });
        });
      });

      group(
          'new one starts and ends between two different ones, with one in the middle:',
          () {
        test('new.start = old1.start, new.end = old3.end', () {
          // Test logic for new.start = old1.start, new.end = old3.end
        });
        
        test('new.start = old1.start + a, new.end = old3.end where 1 < a', () {
          // Test logic for new.start = old1.start + a, new.end = old3.end where 1 < a
        });
        
        test('new.start = old1.start, new.end = old3.end - a where 1 < a', () {
          // Test logic for new.start = old1.start, new.end = old3.end - a where 1 < a
        });
        
        test('new.start = old1.start + a, new.start = old3.end - a where 1 < a',
            () {
          // Test logic for new.start = old1.start + a, new.start = old3.end - a where 1 < a
        });
        
        test('new.start = old1.end, new.end = old3.start', () {
          // Test logic for new.start = old1.end, new.end = old3.start
        });
        
        
      });

      group('new one is independent:', () {
        // Tests for when the new one is independent
      });

      group('new one encloses all three:', () {
        test('new.start = old1.start, new.end = old3.end', () {
          // Test logic for new.start = old1.start, new.end = old3.end
        });
        
        test('new.start = old1.start - a, new.end = old3.end where a > 1', () {
          // Test logic for new.start = old1.start - a, new.end = old3.end where a > 1
        });
        
        test('new.start = old1.start, new.end = old3.end + a', () {
          // Test logic for new.start = old1.start, new.end = old3.end + a
        });
        
        test('new.start = old1.start - a, new.end = old3.end + a', () {
          // Test logic for new.start = old1.start - a, new.end = old3.end + a
        });
      });
    });
  });
}
