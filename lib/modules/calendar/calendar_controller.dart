import 'package:flutter/cupertino.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/session_storage.dart';

class CalendarController {
  final _firebaseCrud = instanceManager.firebaseCrudService;
  final uid = instanceManager.localStorage.getString('uid') ?? '';

  void moveToStageTwo() {
    instanceManager.sessionStorage.calendarBeginPage = 1;
    instanceManager.sessionStorage.savedWeekday = 0;
  }

  void moveToStageThree() {
    instanceManager.sessionStorage.calendarBeginPage = 2;
  }

  Future<void> addScheduleRestraints() async {
    await Future.delayed(Duration(seconds: 1));
    final _sessionStorage = instanceManager.sessionStorage;

    final hoursMatrix = _sessionStorage.checkboxMatrix;
    final deletion = await _firebaseCrud.deleteRestraints();

    if (deletion == -1) {
      _sessionStorage.schedulePresent = -1;
      return;
    }

    List<TimeSlot> busyTimes =
        getTimeSlotsFromMatrix(matrix: _sessionStorage.checkboxMatrix);

    for (TimeSlot slot in busyTimes) {
      final res = await _firebaseCrud.addTimeRestraint(timeSlot: slot);
      logger.i('Added slot!');
      if (res == -1) {
        _sessionStorage.schedulePresent = -1;
        return;
      }
    }

    logger.i('Success adding all busy slots!');
    _sessionStorage.schedulePresent = 1;
  }

  List<TimeSlot> getTimeSlotsFromMatrix({required matrix}) {
    //TODO: This solution could be more elegant...

    List<TimeSlot> result = [];
    void addTimeSlot(
      final weekday,
      final startTime,
      final endTime,
    ) {
      result.add(TimeSlot(
          weekday: weekday,
          startTime: startTime,
          endTime: endTime,
          courseID: 'busy'));
    }

    for (int i = 0; i < matrix.length; i++) {
      int startTime = 0;
      int endTime = 0;
      if (matrix[i].length == 1) {
        if (matrix[i][0] == true) {
          startTime = 0;
          endTime = 0;
          addTimeSlot(i, startTime, endTime);
        }
      } else {
        for (int j = 1; j < matrix[i].length; j++) {
          final current = matrix[i][j];
          final previous = matrix[i][j - 1];
          if (current == true) {
            if (previous == false) {
              startTime = j;
            }
            if (j == matrix[i].length - 1) {
              endTime = j;
              addTimeSlot(i, startTime, endTime);
            }
          }
          if (current == false && previous == true) {
            endTime = j - 1;
            addTimeSlot(i, startTime, endTime);
          }
        }
      }
    }
    if (result.length == 0) {
      addTimeSlot(0, 0, 0);
    }
    return result;
  }

  void printList(List<TimeSlot> list) {
    var res = [];
    for (TimeSlot x in list) {
      res.add([x.weekday, x.startTime, x.endTime]);
    }
    logger.i(res);
  }

  void checkIfRestraintsExist() async {
    instanceManager.sessionStorage.schedulePresent =
        await _firebaseCrud.checkRestraints();
  }

  void calculateSchedule() async {
    logger.i(await instanceManager.studyPlanner.calculateSchedule());
  }
}
