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


  group('Add restraint', (){
    test('description', () => null);

  });
}
