import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/modules/calendar/calendar_controller.dart';

void main() {
  /*group('Time Slots From Matrix Tests: ', () {
    
    test('Regular Matrix 1', () {
      final calendarController = CalendarController();

      final matrix = [
        [true, true, true, false, true],
        [false, true, false, true, true],
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [
        TimeSlot(weekday: 0, startTime: 0, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 0, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 1, endTime: 1, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 3, endTime: 4, courseID: 'busy'),
      ];


      expect(result, expected);
    });

    test('0x0 matrix', () {
      final calendarController = CalendarController();

      final matrix = [];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [];

      expect(result, expected);
    });

    test('1x0 matrix', () {
      final calendarController = CalendarController();

      final matrix = [[]];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [];

      expect(result, expected);
    });
    test('1x1 true matrix', () {
      final calendarController = CalendarController();

      final matrix = [
        [true]
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);
      calendarController.printList(result);

      final expected = [
        TimeSlot(weekday: 0, startTime: 0, endTime: 0, courseID: 'busy'),
      ];

      expect(result, expected);
    });
    test('1x1 false matrix', () {
      final calendarController = CalendarController();

      final matrix = [
        [false]
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [];

      expect(result, expected);
    });
    test('All false matrix', () {
      final calendarController = CalendarController();

      final matrix = [
        [false, false, false, false],
        [false, false, false, false],
        [false, false, false, false],
        [false, false, false, false],
        [false, false, false, false],
        [false, false, false, false],
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [];

      expect(result, expected);
    });
    test('All true matrix', () {
      final calendarController = CalendarController();

      final matrix = [
        [true, true, true, true, true, true],
        [true, true, true, true, true, true],
        [true, true, true, true, true, true],
        [true, true, true, true, true, true],
        [true, true, true, true, true, true],
        [true, true, true, true, true, true],
        [true, true, true, true, true, true],
        [true, true, true, true, true, true],
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [
        TimeSlot(weekday: 0, startTime: 0, endTime: 5, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 0, endTime: 5, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 0, endTime: 5, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 0, endTime: 5, courseID: 'busy'),
        TimeSlot(weekday: 4, startTime: 0, endTime: 5, courseID: 'busy'),
        TimeSlot(weekday: 5, startTime: 0, endTime: 5, courseID: 'busy'),
        TimeSlot(weekday: 6, startTime: 0, endTime: 5, courseID: 'busy'),
        TimeSlot(weekday: 7, startTime: 0, endTime: 5, courseID: 'busy'),
      ];

      expect(result, expected);
    });
    test('All true 1x6 matrix', () {
      final calendarController = CalendarController();

      final matrix = [
        [true, true, true, true, true, true],
        
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [
        TimeSlot(weekday: 0, startTime: 0, endTime: 5, courseID: 'busy'),
        
      ];

      expect(result, expected);
    });
    test('All true 6x1 matrix', () {
      final calendarController = CalendarController();

      final matrix = [
        [true],
        [true],
        [true],
        [true],
        [true],
        [true],
        
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [
        TimeSlot(weekday: 0, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 4, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 5, startTime: 0, endTime: 0, courseID: 'busy'),
        
      ];
      calendarController.printList(result);

      expect(result, expected);
    });
    test('Alternating values', () {
      final calendarController = CalendarController();

      final matrix = [
        [true, false, true, false, true, false],
        [true, false, true, false, true, false],
        [true, false, true, false, true, false],
        [true, false, true, false, true, false],
        
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [
        TimeSlot(weekday: 0, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 0, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 0, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 4, endTime: 4, courseID: 'busy'),
        
      ];

      expect(result, expected);
    });
    test('large matrix', () {
      final calendarController = CalendarController();

      final matrix = [
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        [true, false, true, false, true, false, true, false, true, false, true, false],
        
      ];

      final result = calendarController.getTimeSlotsFromMatrix(matrix: matrix);

      final expected = [
        TimeSlot(weekday: 0, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 0, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 0, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 0, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 0, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 0, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 1, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 2, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 3, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 4, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 4, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 4, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 4, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 4, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 4, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 5, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 5, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 5, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 5, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 5, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 5, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 6, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 6, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 6, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 6, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 6, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 6, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 7, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 7, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 7, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 7, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 7, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 7, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 8, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 8, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 8, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 8, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 8, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 8, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 9, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 9, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 9, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 9, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 9, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 9, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 10, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 10, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 10, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 10, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 10, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 10, startTime: 10, endTime: 10, courseID: 'busy'),
        TimeSlot(weekday: 11, startTime: 0, endTime: 0, courseID: 'busy'),
        TimeSlot(weekday: 11, startTime: 2, endTime: 2, courseID: 'busy'),
        TimeSlot(weekday: 11, startTime: 4, endTime: 4, courseID: 'busy'),
        TimeSlot(weekday: 11, startTime: 6, endTime: 6, courseID: 'busy'),
        TimeSlot(weekday: 11, startTime: 8, endTime: 8, courseID: 'busy'),
        TimeSlot(weekday: 11, startTime: 10, endTime: 10, courseID: 'busy'),
        
      ];

      expect(result, expected);
    });
  });
*/

  group('Add restraint', () {
    test('Empty list - add TimeSlot(00:00 - 23:59)', () => null);

    test('Empty list - add TimeSlot(01:00 - 01:00)', () => null);

    test('Empty list - add TimeSlot(01:00 - 01:01)', () => null);

    test('Empty list - add TimeSlot(01:00 - 02:00)', () => null);

    test('Empty list - add TimeSlot(22:00 - 23:59)', () => null);

    group('1 present:', () {
      group('new separate from old:', () {
        test('new.start = old.one + 2', () {
          // Test logic for new.start = old.one + 2
        });
        test('new.start = old.one + x', () {
          // Test logic for new.start = old.one + x
        });
        test('new.end = old.start - 2', () {
          // Test logic for new.end = old.start - 2
        });
        test('new.end = old.start - x', () {
          // Test logic for new.end = old.start - x
        });
      });

      group('new contained in old:', () {
        test('new.start = old.start, new.end = old.end', () {
          // Test logic for new.start = old.start, new.end = old.end
        });
        test('new.start = old.start + 1, new.end = old.end - 1', () {
          // Test logic for new.start = old.start + 1, new.end = old.end - 1
        });
        test('new.start = old.start + x, new.end = old.end - x', () {
          // Test logic for new.start = old.start + x, new.end = old.end - x
        });
      });

      group('new contains old:', () {
        test('new.start = old.start, new.end = old.end', () {
          // Test logic for new.start = old.start, new.end = old.end
        });
        test('new.start = old.start + 1, new.end = old.end - 1', () {
          // Test logic for new.start = old.start + 1, new.end = old.end - 1
        });

        test('new.start = old.start + a, new.end = old.end - a', () {
          // Test logic for new.start = old.start + a, new.end = old.end - a
        });
      });

      group('new starts in old:', () {
        test('new.start = old.start, new.end = old.end + 1', () {
          // Test logic for new.start = old.start, new.end = old.end + 1
        });
        test('new.start = old.start, new.end = old.end + x', () {
          // Test logic for new.start = old.start, new.end = old.end + x
        });
        test('new.start = old.start + 1, new.end = old.end + 1', () {
          // Test logic for new.start = old.start + 1, new.end = old.end + 1
        });
        test('new.start = old.start + 1, new.end = old.end + x', () {
          // Test logic for new.start = old.start + 1, new.end = old.end + x
        });
        test('new.start = old.start + x, new.end = old.end + 1', () {
          // Test logic for new.start = old.start + x, new.end = old.end + 1
        });
        test('new.start = old.start + x, new.end = old.end + x', () {
          // Test logic for new.start = old.start + x, new.end = old.end + x
        });
        test('new.start = old.end - 1, new.end = old.end + 1', () {
          // Test logic for new.start = old.end - 1, new.end = old.end + 1
        });
        test('new.start = old.end - 1, new.end = old.end + x', () {
          // Test logic for new.start = old.end - 1, new.end = old.end + x
        });
        test('new.start = old.end, new.end = old.end + 1', () {
          // Test logic for new.start = old.end, new.end = old.end + 1
        });
        test('new.start = old.end, new.end = old.end + x', () {
          // Test logic for new.start = old.end, new.end = old.end + x
        });
      });

      group('old starts in new:', () {
        test('old.start = new.start, old.end = new.end + 1', () {
          // Test logic for old.start = new.start, old.end = new.end + 1
        });
        test('old.start = new.start, old.end = new.end + x', () {
          // Test logic for old.start = new.start, old.end = new.end + x
        });
        test('old.start = new.start + 1, old.end = new.end + 1', () {
          // Test logic for old.start = new.start + 1, old.end = new.end + 1
        });
        test('old.start = new.start + 1, old.end = new.end + x', () {
          // Test logic for old.start = new.start + 1, old.end = new.end + x
        });
        test('old.start = new.start + x, old.end = new.end + 1', () {
          // Test logic for old.start = new.start + x, old.end = new.end + 1
        });
        test('old.start = new.start + x, old.end = new.end + x', () {
          // Test logic for old.start = new.start + x, old.end = new.end + x
        });
        test('old.start = new.end - 1, old.end = new.end + 1', () {
          // Test logic for old.start = new.end - 1, old.end = new.end + 1
        });
        test('old.start = new.end - 1, old.end = new.end + x', () {
          // Test logic for old.start = new.end - 1, old.end = new.end + x
        });
        test('old.start = new.end, old.end = new.end + 1', () {
          // Test logic for old.start = new.end, old.end = new.end + 1
        });
        test('old.start = new.end, old.end = new.end + x', () {
          // Test logic for old.start = new.end, old.end = new.end + x
        });
      });

      group('new contiguous to old:', () {
        test('new.start = old.end + 1', () {
          // Test logic for new.start = old.end + 1
        });
        test('new.end = old.start - 1', () {
          // Test logic for new.end = old.start - 1
        });
      });
    });

    group('2 present:', () {
      group('Same ones as one old but with one more old one unaffected', () {
        group('new separate from old:', () {
          test('new.start = old.one + 2', () {
            // Test logic for new.start = old.one + 2
          });
          test('new.start = old.one + x', () {
            // Test logic for new.start = old.one + x
          });
          test('new.end = old.start - 2', () {
            // Test logic for new.end = old.start - 2
          });
          test('new.end = old.start - x', () {
            // Test logic for new.end = old.start - x
          });
        });

        group('new contained in old:', () {
          test('new.start = old.start, new.end = old.end', () {
            // Test logic for new.start = old.start, new.end = old.end
          });
          test('new.start = old.start + 1, new.end = old.end - 1', () {
            // Test logic for new.start = old.start + 1, new.end = old.end - 1
          });
          test('new.start = old.start + x, new.end = old.end - x', () {
            // Test logic for new.start = old.start + x, new.end = old.end - x
          });
        });

        group('new contains old:', () {
          test('new.start = old.start, new.end = old.end', () {
            // Test logic for new.start = old.start, new.end = old.end
          });
          test('new.start = old.start + 1, new.end = old.end - 1', () {
            // Test logic for new.start = old.start + 1, new.end = old.end - 1
          });

          test('new.start = old.start + a, new.end = old.end - a', () {
            // Test logic for new.start = old.start + a, new.end = old.end - a
          });
        });

        group('new starts in old:', () {
          test('new.start = old.start, new.end = old.end + 1', () {
            // Test logic for new.start = old.start, new.end = old.end + 1
          });
          test('new.start = old.start, new.end = old.end + x', () {
            // Test logic for new.start = old.start, new.end = old.end + x
          });
          test('new.start = old.start + 1, new.end = old.end + 1', () {
            // Test logic for new.start = old.start + 1, new.end = old.end + 1
          });
          test('new.start = old.start + 1, new.end = old.end + x', () {
            // Test logic for new.start = old.start + 1, new.end = old.end + x
          });
          test('new.start = old.start + x, new.end = old.end + 1', () {
            // Test logic for new.start = old.start + x, new.end = old.end + 1
          });
          test('new.start = old.start + x, new.end = old.end + x', () {
            // Test logic for new.start = old.start + x, new.end = old.end + x
          });
          test('new.start = old.end - 1, new.end = old.end + 1', () {
            // Test logic for new.start = old.end - 1, new.end = old.end + 1
          });
          test('new.start = old.end - 1, new.end = old.end + x', () {
            // Test logic for new.start = old.end - 1, new.end = old.end + x
          });
          test('new.start = old.end, new.end = old.end + 1', () {
            // Test logic for new.start = old.end, new.end = old.end + 1
          });
          test('new.start = old.end, new.end = old.end + x', () {
            // Test logic for new.start = old.end, new.end = old.end + x
          });
        });

        group('old starts in new:', () {
          test('old.start = new.start, old.end = new.end + 1', () {
            // Test logic for old.start = new.start, old.end = new.end + 1
          });
          test('old.start = new.start, old.end = new.end + x', () {
            // Test logic for old.start = new.start, old.end = new.end + x
          });
          test('old.start = new.start + 1, old.end = new.end + 1', () {
            // Test logic for old.start = new.start + 1, old.end = new.end + 1
          });
          test('old.start = new.start + 1, old.end = new.end + x', () {
            // Test logic for old.start = new.start + 1, old.end = new.end + x
          });
          test('old.start = new.start + x, old.end = new.end + 1', () {
            // Test logic for old.start = new.start + x, old.end = new.end + 1
          });
          test('old.start = new.start + x, old.end = new.end + x', () {
            // Test logic for old.start = new.start + x, old.end = new.end + x
          });
          test('old.start = new.end - 1, old.end = new.end + 1', () {
            // Test logic for old.start = new.end - 1, old.end = new.end + 1
          });
          test('old.start = new.end - 1, old.end = new.end + x', () {
            // Test logic for old.start = new.end - 1, old.end = new.end + x
          });
          test('old.start = new.end, old.end = new.end + 1', () {
            // Test logic for old.start = new.end, old.end = new.end + 1
          });
          test('old.start = new.end, old.end = new.end + x', () {
            // Test logic for old.start = new.end, old.end = new.end + x
          });
        });

        group('new contiguous to old:', () {
          test('new.start = old.end + 1', () {
            // Test logic for new.start = old.end + 1
          });
          test('new.end = old.start - 1', () {
            // Test logic for new.end = old.start - 1
          });
        });
      });
      group('new one starts and ends inside two different ones:', () {
        test('t(new.start = old1.start, new.end = old2.end)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.end)
        });
        test('t(new.start = old1.start + 1, new.end = old2.end)', () {
          // Test logic for t(new.start = old1.start + 1, new.end = old2.end)
        });
        test('t(new.start = old1.start + a, new.end = old2.end) where 1 < a',
            () {
          // Test logic for t(new.start = old1.start + a, new.end = old2.end) where 1 < a
        });
        test('t(new.start = old1.start, new.end = old2.end - 1)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.end - 1)
        });
        test('t(new.start = old1.start, new.end = old2.end - a) where 1 < a',
            () {
          // Test logic for t(new.start = old1.start, new.end = old2.end - a) where 1 < a
        });
        test('t(new.start = old1.start + 1, new.start = old2.end - 1)', () {
          // Test logic for t(new.start = old1.start + 1, new.start = old2.end - 1)
        });
        test(
            't(new.start = old1.start + a, new.start = old2.end - a) where 1 < a',
            () {
          // Test logic for t(new.start = old1.start + a, new.start = old2.end - a) where 1 < a
        });
        test('t(new.start = old1.end - 1, new.end = old2.start + 1)', () {
          // Test logic for t(new.start = old1.end - 1, new.end = old2.start + 1)
        });
        test('t(new.start = old1.end, new.end = old2.start)', () {
          // Test logic for t(new.start = old1.end, new.end = old2.start)
        });
        test('t(new.start = old1.end, new.end = old2.start + 1)', () {
          // Test logic for t(new.start = old1.end, new.end = old2.start + 1)
        });
        test('t(new.start = old1.end - 1, new.end = old2.start)', () {
          // Test logic for t(new.start = old1.end - 1, new.end = old2.start)
        });
      });

      group('new one is contiguous and links both old ones:', () {
        test('t(new.start = old1.end + 1, new.end = old2.start - 1)', () {
          // Test logic for t(new.start = old1.end + 1, new.end = old2.start - 1)
        });
        test('t(new.start = old1.start, new.end = old2.start - 1)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.start - 1)
        });
        test('t(new.start = old1.start + 1, new.end = old2.start - 1)', () {
          // Test logic for t(new.start = old1.start + 1, new.end = old2.start - 1)
        });
        test(
            't(new.start = old1.start + a, new.end = old2.start - 1) where 1 < a',
            () {
          // Test logic for t(new.start = old1.start + a, new.end = old2.start - 1) where 1 < a
        });
        test('t(new.start = old1.end - 1, new.end = old2.start - 1)', () {
          // Test logic for t(new.start = old1.end - 1, new.end = old2.start - 1)
        });
        test('t(new.start = old1.end, new.end = old2.start - 1)', () {
          // Test logic for t(new.start = old1.end, new.end = old2.start - 1)
        });
        test('t(new.start = old1.end + 1, new.end = old2.start)', () {
          // Test logic for t(new.start = old1.end + 1, new.end = old2.start)
        });
        test('t(new.start = old1.end + 1, new.end = old2.start + 1)', () {
          // Test logic for t(new.start = old1.end + 1, new.end = old2.start + 1)
        });
        test('t(new.start = old1.end + 1, new.end = old2.start + a1)', () {
          // Test logic for t(new.start = old1.end + 1, new.end = old2.start + a1)
        });
        test('t(new.start = old1.end + 1, new.end = old2.end - 1)', () {
          // Test logic for t(new.start = old1.end + 1, new.end = old2.end - 1)
        });
        test('t(new.start = old1.end + 1, new.end = old2.end)', () {
          // Test logic for t(new.start = old1.end + 1, new.end = old2.end)
        });
      });

      group('new one is independent:', () {
        test(
            't(new.start = old1.start - a, new.end = old1.start - b) where a > b > 2',
            () {
          // Test logic for t(new.start = old1.start - a, new.end = old1.start - b) where a > b > 2
        });
        test(
            't(new.start = old1.start - a, new.end = old1.start - 2) where a > 2',
            () {
          // Test logic for t(new.start = old1.start - a, new.end = old1.start - 2) where a > 2
        });
        test(
            't(new.start = old1.end + a, new.end = old2.start - b) where a, b > 2',
            () {
          // Test logic for t(new.start = old1.end + a, new.end = old2.start - b) where a, b > 2
        });
        test(
            't(new.start = old1.end + 2, new.end = old2.start - b) where b > 2',
            () {
          // Test logic for t(new.start = old1.end + 2, new.end = old2.start - b) where b > 2
        });
        test(
            't(new.start = old1.end + a, new.end = old2.start - 2) where a > 2',
            () {
          // Test logic for t(new.start = old1.end + a, new.end = old2.start - 2) where a > 2
        });
        test('t(new.start = old2.end + a, new.end = old2.end + b) where a < b',
            () {
          // Test logic for t(new.start = old2.end + a, new.end = old2.end + b) where a < b
        });
        test('t(new.start = old2.end + 2, new.end = old2.end + a) where a > 2',
            () {
          // Test logic for t(new.start = old2.end + 2, new.end = old2.end + a) where a > 2
        });
      });

      group('new one encloses both:', () {
        test('t(new.start = old1.start, new.end = old2.end)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.end)
        });
        test('t(new.start = old1.start - 1, new.end = old2.end)', () {
          // Test logic for t(new.start = old1.start - 1, new.end = old2.end)
        });
        test('t(new.start = old1.start - a, new.end = old2.end) where a > 1',
            () {
          // Test logic for t(new.start = old1.start - a, new.end = old2.end) where a > 1
        });
        test('t(new.start = old1.start, new.end = old2.end + 1)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.end + 1)
        });
        test('t(new.start = old1.start, new.end = old2.end + a)', () {
          // Test logic for t(new.start = old1.start, new.end = old2.end + a)
        });
        test('t(new.start = old1.start - 1, new.end = old2.end + 1)', () {
          // Test logic for t(new.start = old1.start - 1, new.end = old2.end + 1)
        });
        test('t(new.start = old1.start - a, new.end = old2.end + a)', () {
          // Test logic for t(new.start = old1.start - a, new.end = old2.end + a)
        });
      });
    });

    void main() {
      group('3 present:', () {
        group(
            '(all the tests for 2 present, but with one timelot separated that isnt affected)',
            () {
          // Tests for 2 present but with one timelot separated that isn't affected

          group('new one starts and ends inside two different ones:', () {
            test('t(new.start = old1.start, new.end = old2.end)', () {
              // Test logic for t(new.start = old1.start, new.end = old2.end)
            });
            test('t(new.start = old1.start + 1, new.end = old2.end)', () {
              // Test logic for t(new.start = old1.start + 1, new.end = old2.end)
            });
            test(
                't(new.start = old1.start + a, new.end = old2.end) where 1 < a',
                () {
              // Test logic for t(new.start = old1.start + a, new.end = old2.end) where 1 < a
            });
            test('t(new.start = old1.start, new.end = old2.end - 1)', () {
              // Test logic for t(new.start = old1.start, new.end = old2.end - 1)
            });
            test(
                't(new.start = old1.start, new.end = old2.end - a) where 1 < a',
                () {
              // Test logic for t(new.start = old1.start, new.end = old2.end - a) where 1 < a
            });
            test('t(new.start = old1.start + 1, new.start = old2.end - 1)', () {
              // Test logic for t(new.start = old1.start + 1, new.start = old2.end - 1)
            });
            test(
                't(new.start = old1.start + a, new.start = old2.end - a) where 1 < a',
                () {
              // Test logic for t(new.start = old1.start + a, new.start = old2.end - a) where 1 < a
            });
            test('t(new.start = old1.end - 1, new.end = old2.start + 1)', () {
              // Test logic for t(new.start = old1.end - 1, new.end = old2.start + 1)
            });
            test('t(new.start = old1.end, new.end = old2.start)', () {
              // Test logic for t(new.start = old1.end, new.end = old2.start)
            });
            test('t(new.start = old1.end, new.end = old2.start + 1)', () {
              // Test logic for t(new.start = old1.end, new.end = old2.start + 1)
            });
            test('t(new.start = old1.end - 1, new.end = old2.start)', () {
              // Test logic for t(new.start = old1.end - 1, new.end = old2.start)
            });
          });

          group('new one is contiguous and links both old ones:', () {
            test('t(new.start = old1.end + 1, new.end = old2.start - 1)', () {
              // Test logic for t(new.start = old1.end + 1, new.end = old2.start - 1)
            });
            test('t(new.start = old1.start, new.end = old2.start - 1)', () {
              // Test logic for t(new.start = old1.start, new.end = old2.start - 1)
            });
            test('t(new.start = old1.start + 1, new.end = old2.start - 1)', () {
              // Test logic for t(new.start = old1.start + 1, new.end = old2.start - 1)
            });
            test(
                't(new.start = old1.start + a, new.end = old2.start - 1) where 1 < a',
                () {
              // Test logic for t(new.start = old1.start + a, new.end = old2.start - 1) where 1 < a
            });
            test('t(new.start = old1.end - 1, new.end = old2.start - 1)', () {
              // Test logic for t(new.start = old1.end - 1, new.end = old2.start - 1)
            });
            test('t(new.start = old1.end, new.end = old2.start - 1)', () {
              // Test logic for t(new.start = old1.end, new.end = old2.start - 1)
            });
            test('t(new.start = old1.end + 1, new.end = old2.start)', () {
              // Test logic for t(new.start = old1.end + 1, new.end = old2.start)
            });
            test('t(new.start = old1.end + 1, new.end = old2.start + 1)', () {
              // Test logic for t(new.start = old1.end + 1, new.end = old2.start + 1)
            });
            test('t(new.start = old1.end + 1, new.end = old2.start + a1)', () {
              // Test logic for t(new.start = old1.end + 1, new.end = old2.start + a1)
            });
            test('t(new.start = old1.end + 1, new.end = old2.end - 1)', () {
              // Test logic for t(new.start = old1.end + 1, new.end = old2.end - 1)
            });
            test('t(new.start = old1.end + 1, new.end = old2.end)', () {
              // Test logic for t(new.start = old1.end + 1, new.end = old2.end)
            });
          });

          group('new one is independent:', () {
            test(
                't(new.start = old1.start - a, new.end = old1.start - b) where a > b > 2',
                () {
              // Test logic for t(new.start = old1.start - a, new.end = old1.start - b) where a > b > 2
            });
            test(
                't(new.start = old1.start - a, new.end = old1.start - 2) where a > 2',
                () {
              // Test logic for t(new.start = old1.start - a, new.end = old1.start - 2) where a > 2
            });
            test(
                't(new.start = old1.end + a, new.end = old2.start - b) where a, b > 2',
                () {
              // Test logic for t(new.start = old1.end + a, new.end = old2.start - b) where a, b > 2
            });
            test(
                't(new.start = old1.end + 2, new.end = old2.start - b) where b > 2',
                () {
              // Test logic for t(new.start = old1.end + 2, new.end = old2.start - b) where b > 2
            });
            test(
                't(new.start = old1.end + a, new.end = old2.start - 2) where a > 2',
                () {
              // Test logic for t(new.start = old1.end + a, new.end = old2.start - 2) where a > 2
            });
            test(
                't(new.start = old2.end + a, new.end = old2.end + b) where a < b',
                () {
              // Test logic for t(new.start = old2.end + a, new.end = old2.end + b) where a < b
            });
            test(
                't(new.start = old2.end + 2, new.end = old2.end + a) where a > 2',
                () {
              // Test logic for t(new.start = old2.end + 2, new.end = old2.end + a) where a > 2
            });
          });

          group('new one encloses both:', () {
            test('t(new.start = old1.start, new.end = old2.end)', () {
              // Test logic for t(new.start = old1.start, new.end = old2.end)
            });
            test('t(new.start = old1.start - 1, new.end = old2.end)', () {
              // Test logic for t(new.start = old1.start - 1, new.end = old2.end)
            });
            test(
                't(new.start = old1.start - a, new.end = old2.end) where a > 1',
                () {
              // Test logic for t(new.start = old1.start - a, new.end = old2.end) where a > 1
            });
            test('t(new.start = old1.start, new.end = old2.end + 1)', () {
              // Test logic for t(new.start = old1.start, new.end = old2.end + 1)
            });
            test('t(new.start = old1.start, new.end = old2.end + a)', () {
              // Test logic for t(new.start = old1.start, new.end = old2.end + a)
            });
            test('t(new.start = old1.start - 1, new.end = old2.end + 1)', () {
              // Test logic for t(new.start = old1.start - 1, new.end = old2.end + 1)
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
          test('new.start = old1.start + 1, new.end = old3.end', () {
            // Test logic for new.start = old1.start + 1, new.end = old3.end
          });
          test('new.start = old1.start + a, new.end = old3.end where 1 < a',
              () {
            // Test logic for new.start = old1.start + a, new.end = old3.end where 1 < a
          });
          test('new.start = old1.start, new.end = old3.end - 1', () {
            // Test logic for new.start = old1.start, new.end = old3.end - 1
          });
          test('new.start = old1.start, new.end = old3.end - a where 1 < a',
              () {
            // Test logic for new.start = old1.start, new.end = old3.end - a where 1 < a
          });
          test('new.start = old1.start + 1, new.start = old3.end - 1', () {
            // Test logic for new.start = old1.start + 1, new.start = old3.end - 1
          });
          test(
              'new.start = old1.start + a, new.start = old3.end - a where 1 < a',
              () {
            // Test logic for new.start = old1.start + a, new.start = old3.end - a where 1 < a
          });
          test('new.start = old1.end - 1, new.end = old3.start + 1', () {
            // Test logic for new.start = old1.end - 1, new.end = old3.start + 1
          });
          test('new.start = old1.end, new.end = old3.start', () {
            // Test logic for new.start = old1.end, new.end = old3.start
          });
          test('new.start = old1.end, new.end = old3.start + 1', () {
            // Test logic for new.start = old1.end, new.end = old3.start + 1
          });
          test('new.start = old1.end - 1, new.end = old3.start', () {
            // Test logic for new.start = old1.end - 1, new.end = old3.start
          });
        });

        group('new one is independent:', () {
          // Tests for when the new one is independent
        });

        group('new one encloses all three:', () {
          test('new.start = old1.start, new.end = old3.end', () {
            // Test logic for new.start = old1.start, new.end = old3.end
          });
          test('new.start = old1.start - 1, new.end = old3.end', () {
            // Test logic for new.start = old1.start - 1, new.end = old3.end
          });
          test('new.start = old1.start - a, new.end = old3.end where a > 1',
              () {
            // Test logic for new.start = old1.start - a, new.end = old3.end where a > 1
          });
          test('new.start = old1.start, new.end = old3.end + 1', () {
            // Test logic for new.start = old1.start, new.end = old3.end + 1
          });
          test('new.start = old1.start, new.end = old3.end + a', () {
            // Test logic for new.start = old1.start, new.end = old3.end + a
          });
          test('new.start = old1.start - 1, new.end = old3.end + 1', () {
            // Test logic for new.start = old1.start - 1, new.end = old3.end + 1
          });
          test('new.start = old1.start - a, new.end = old3.end + a', () {
            // Test logic for new.start = old1.start - a, new.end = old3.end + a
          });
        });
      });
    }

    /*
    1 present:

  new separate from old:
    new.start = old.one +2
    new.start = old.one +x

    new.end = old.start -2
    new.end = old.start -x


  new contained in old:
    new.start = old.start, new.end = old.end
    new.start = old.start +1, new.end = old.end -1,
    new.start = old.start +x, new.end = old.end -x,
    

  new contains old:
    new.start = old.start, new.end = old.end
    new.start = old.start +1, new.end = old.end -1,

  new starts in old:
    new.start = old.start, new.end = old.end +1
    new.start = old.start, new.end = old.end +x
    
    new.start old.start +1, new.end = old.end +1
    new.start = old.start +1, new.end = old.end +x

    new.start = old.start +x, new.end = old.end +1
    new.start = old.start +x, new.end = old.end +x

    new.start = old.end -1, new.end = old.end +1
    new.start = old.end -1, new.end = old.end +x

    new.start = old.end, new.end = old.end +1
    new.start = old.end, new.end = old.end +x

  old starts in new:
    old.start = new.start, old.end = new.end + 1
    old.start = new.start, old.end = new.end + x

    old.start = new.start + 1, old.end = new.end + 1
    old.start = new.start + 1, old.end = new.end + x

    old.start = new.start + x, old.end = new.end + 1
    old.start = new.start + x, old.end = new.end + x

    old.start = new.end - 1, old.end = new.end + 1
    old.start = new.end - 1, old.end = new.end + x

    old.start = new.end, old.end = new.end + 1
    old.start = new.end, old.end = new.end + x

  new contiguous to old:

    new.start = old.end +1

    new.end = old.start -1



2 present:

  all the tests for one present, with one more present that isn't affected.

  new one starts and end inside two different ones:

    new.start = old1.start, new.end = old2.end
    new.start = old1.start +1. new.old = old2.end
    new.start = old1.start +a. new.old = old2.end 1 < a

    new.start = old1.start, new.end = old2.end -1
    new.start = old1.start, new.end = old2.end -a, 1 < a

    new.start = old1.start +1, new.start = old2.end -1, 
    new.start = old1.start +a, new.start = old2.end -a, 1 < a 

    new.start = old1.end -1, new.end = old2.start+1
    new.start = old1.end, new.end = old2.start

    new.start = old1.end, new.end = old2.start +1
    new.start = old1.end-1, new.end = old2.start

    

  new one is contiguous and links both old ones:

    new.start = old1.end +1, new.end = old2.start -1

    new.start = old1.start, new.end = old2.start -1
    new.start = old1.start +1, new.end = old2.start -1
    new.start = old1.start +a, new.end = old2.start -1
    new.start = old1.end -1, new.end = old2.start -1
    new.start = old1.end, new.end = old2.start -1

    new.start = old1.end +1, new.end = old2.start 
    new.start = old1.end +1, new.end = old2.start +1
    new.start = old1.end +1, new.end = old2.start +a1
    new.start = old1.end +1, new.end = old2.end -1
    new.start = old1.end +1, new.end = old2.end 

  new one is independent:

    new.start = old1.start -a, new.end = old1.start -b , a>b>2
    new.start = old1.start -a, new.end = old1.start -2 , a>2

    new.start = old1.end +a, new.end = old2.start -b, a,b>2
    new.start = old1.end +2, new.end = old2.start -b, b>2
    new.start = old1.end +a, new.end = old2.start -2, a>2

    new.start = old2.end +a, new.end = old2.end +b , a<b
    new.start = old2.end +2, new.end = old2.end +a , a>2

  new one encloses both:

    new.start = old1.start, new.end = old2.end, 

    new.start = old1.start-1, new.end = old2.end,
    new.start = old1.start -a, new.end = old2.end,

    new.start = old1.start, new.end = old2.end+1,
    new.start = old1.start , new.end = old2.end+a,

    
    new.start = old1.start-1, new.end = old2.end+1,
    new.start = old1.start -a, new.end = old2.end+a,



3 present:

  all the tests for two present, but with one separated that isnt affected. 

  new one starts and ends between two different ones, with one in the middle:

    new.start = old1.start, new.end = old3.end
    new.start = old1.start +1. new.old = old3.end
    new.start = old1.start +a. new.old = old3.end 1 < a

    new.start = old1.start, new.end = old3.end -1
    new.start = old1.start, new.end = old3.end -a, 1 < a

    new.start = old1.start +1, new.start = old3.end -1, 
    new.start = old1.start +a, new.start = old3.end -a, 1 < a 

    new.start = old1.end -1, new.end = old3.start+1
    new.start = old1.end, new.end = old3.start

    new.start = old1.end, new.end = old3.start +1
    new.start = old1.end-1, new.end = old3.start

  new one is independent:

  new one encloses all three:

    new.start = old1.start, new.end = old3.end, 

    new.start = old1.start-1, new.end = old3.end,
    new.start = old1.start -a, new.end = old3.end,

    new.start = old1.start, new.end = old3.end+1,
    new.start = old1.start , new.end = old3.end+a,

    
    new.start = old1.start-1, new.end = old3.end+1,
    new.start = old1.start -a, new.end = old3.end+a,








	*/
  });
}
