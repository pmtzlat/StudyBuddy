import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/common_widgets/datatype_utils.dart';
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
          addTimeSlot(i + 1, startTime, endTime);
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
              addTimeSlot(i + 1, startTime, endTime);
            }
          }
          if (current == false && previous == true) {
            endTime = j - 1;
            addTimeSlot(i + 1, startTime, endTime);
          }
        }
      }
    }
    if (result.length == 0) {
      addTimeSlot(1, 0, 0);
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

  void getRestraints() async {
    instanceManager.sessionStorage.weeklyRestrictions =
        await _firebaseCrud.getRestraints();

    if (instanceManager.sessionStorage.weeklyRestrictions == null) {
      addDefaultRestrictions();
    }
  }

  void addDefaultRestrictions() async {
    logger.i('Adding Default Restrictions...');

    var weeklyRestrictions = instanceManager.sessionStorage.weeklyRestrictions;
    weeklyRestrictions = [];
    for (var i = 0; i < 7; i++) {
      final newSlot = TimeSlot(
          weekday: i + 1,
          startTime: TimeOfDay(hour: 0, minute: 0),
          endTime: TimeOfDay(hour: 9, minute: 0),
          courseID: 'busy');

      await instanceManager.firebaseCrudService
          .addTimeRestraint(timeSlot: newSlot);

      weeklyRestrictions.add(<TimeSlot>[newSlot]);
    }
    instanceManager.sessionStorage.weeklyRestrictions =
        await _firebaseCrud.getRestraints();
  }

  void calculateSchedule() async {
    logger.i(await instanceManager.studyPlanner.calculateSchedule());
  }

  Future<int?> deleteRestraint(TimeSlot timeSlot) async {
    final res =
        await instanceManager.firebaseCrudService.deleteRestraint(timeSlot);

    return res;
  }

  Future<int> addRestraint(GlobalKey<FormBuilderState> key, int weekday) async {
    try {
      if (key.currentState!.validate()) {
        key.currentState!.save();
        final startTime =
            dateTimeToTimeOfDay(key.currentState!.fields['startTime']!.value);
        var endTime =
            dateTimeToTimeOfDay(key.currentState!.fields['endTime']!.value);

        if (endTime.hour == 0 && endTime.minute == 0) {
          endTime = TimeOfDay(hour: 23, minute: 59);
        }

        if (!isTimeBefore(startTime, endTime)) {
          return 0;
        }

        final newRestraint =
            await checkRestraintClash(startTime, endTime, weekday);

        final res =
            await _firebaseCrud.addTimeRestraint(timeSlot: newRestraint);

        return res;
      } else {
        return 0;
      }
    } catch (e) {
      logger.e('Error adding restraint: $e');
      return -1;
    }
  }

  Future<TimeSlot> checkRestraintClash(
      TimeOfDay startTime, TimeOfDay endTime, int weekday, ) async {
    weekday--;
    for (var timeslot
        in instanceManager.sessionStorage.weeklyRestrictions[weekday]) {
      final timeslotStart = timeslot.startTime;
      final timeslotEnd = timeslot.endTime;
      bool deleteDBtimeslot = false;

      if (isTimeBefore(timeslotStart, startTime) &&
          isTimeBefore(startTime, timeslotEnd)) {
        startTime = timeslotStart;
      }

      if (isTimeBefore(timeslotStart, endTime) &&
          isTimeBefore(endTime, timeslotEnd)) {
        endTime = timeslotEnd;
      }

      if (isTimeBefore(startTime, timeslotStart) &&
          isTimeBefore(timeslotStart, endTime)) {
        deleteDBtimeslot = true;
      }

      if (isTimeBefore(startTime, timeslotEnd) &&
          isTimeBefore(timeslotEnd, endTime)) {
        deleteDBtimeslot = true;
      }

      if (startTime == timeslotStart && endTime == timeslotEnd) {
        deleteDBtimeslot = true;
      }

      if (deleteDBtimeslot) {
        _firebaseCrud.deleteRestraint(timeslot);
      }
    }
    weekday++;

    return TimeSlot(
        courseID: 'busy',
        startTime: startTime,
        endTime: endTime,
        weekday: weekday);
  }
}
