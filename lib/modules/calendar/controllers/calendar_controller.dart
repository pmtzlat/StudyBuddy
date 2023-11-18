import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/session_storage.dart';

class CalendarController {
  final _firebaseCrud = instanceManager.firebaseCrudService;
  final uid = instanceManager.localStorage.getString('uid') ?? '';

  void printList(List<TimeSlot> list) {
    var res = [];
    for (TimeSlot x in list) {
      res.add([x.weekday, x.startTime, x.endTime]);
    }
    logger.i(res);
  }

  void getGaps() async {
    instanceManager.sessionStorage.weeklyGaps = await _firebaseCrud.getGaps();
  }

  Future<int> calculateSchedule() async {
    if ((instanceManager.sessionStorage.activeCourses.isEmpty) ||
        (instanceManager.sessionStorage.weeklyGaps.isEmpty)) {
      logger.i('No courses or no availability. ');
      return 1;
    }
    ;
    var result = await instanceManager.studyPlanner.calculateSchedule();
    logger.i('Result of calculating new schedule: ${result}');
    logger.i(instanceManager.sessionStorage.leftoverCourses.length);
    if (result == 1) {
      instanceManager.sessionStorage.needsRecalculation = false;
    }
    return result;
  }

  Future<int?> deleteGap(TimeSlot timeSlot) async {
    final res = await instanceManager.firebaseCrudService.deleteGap(timeSlot);
    instanceManager.sessionStorage.needsRecalculation = true;
    return res;
  }

  Future<int> addGap(GlobalKey<FormBuilderState> key, int weekday,
      List<TimeSlot> provisionalList, String purpose) async {
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

        provisionalList =
            await checkGapClash(startTime, endTime, weekday, provisionalList);

        switch (purpose) {
          case ('generalGaps'):
            if (await _firebaseCrud
                    .clearGapsForWeekday(_firebaseCrud.weekDays[weekday - 1]) ==
                -1) {
              return -1;
            }

            for (var timeSlot in provisionalList) {
              logger.f(
                  '${timeSlot.startTime.toString()} - ${timeSlot.endTime.toString()}');
              final res =
                  await _firebaseCrud.addGeneralTimeSlot(timeSlot: timeSlot);
              if (res != 1) {
                return -1;
              }
            }
            instanceManager.sessionStorage.needsRecalculation = true;
            return 1;

          default:
            instanceManager.sessionStorage.needsRecalculation = true;
            return 1;
        }
      } else {
        return 0;
      }
    } catch (e) {
      logger.e('Error adding gap: $e');
      return -1;
    }
  }

  Future<void> getCalendarDay(DateTime date) async {
    try {
      instanceManager.sessionStorage.currentDay =
          DateTime(date.year, date.month, date.day);
      var savedDate = instanceManager.sessionStorage.currentDay;
      instanceManager.sessionStorage.loadedCalendarDay =
          await _firebaseCrud.getCalendarDay(savedDate);

      instanceManager.sessionStorage.dayLoaded = true;
      logger.i(
          'Got current Day! ${instanceManager.sessionStorage.loadedCalendarDay.getString()}');
    } catch (e) {
      logger.e('Error getting current days (in calendarController): $e');
    }
  }

  Future<List<TimeSlot>> checkGapClash(TimeOfDay newStart, TimeOfDay newEnd,
      int weekday, List<TimeSlot> provisionalList) async {
    try {
      if (newStart == newEnd) return provisionalList;

      List<int> itemsToDeleteFromProvisionalList = [];
      for (var i = provisionalList.length - 1; i >= 0; i--) {
        final old = provisionalList[i];
        final oldStart = old.startTime;
        final oldEnd = old.endTime;
        bool deleteOld = false;

        if (isTimeBefore(newStart, oldStart) && isTimeBefore(oldEnd, newEnd))
          deleteOld = true;

        if (stickyTime('Start', newStart, oldStart, oldEnd)) {
          newStart = oldStart;
          deleteOld = true;
        }

        if (stickyTime('End', newEnd, oldStart, oldEnd)) {
          newEnd = oldEnd;
          deleteOld = true;
        }

        if (deleteOld) {
          itemsToDeleteFromProvisionalList.add(i);
        }
      }

      for (var index in itemsToDeleteFromProvisionalList) {
        provisionalList.removeAt(index);
      }

      provisionalList.add(TimeSlot(
          courseID: 'free',
          startTime: newStart,
          endTime: newEnd,
          weekday: weekday));

      return provisionalList;
    } catch (e) {
      logger.e('Error in check Gap Clash: $e');
      return [];
    }
  }

  Future<void> getCustomDays() async {
    final days = await _firebaseCrud.getCustomDays();
    instanceManager.sessionStorage.customDays = days;
    instanceManager.sessionStorage.activeCustomDays =
        days.where((Day day) => day.date.isAfter(DateTime.now())).toList();
    logger.i('Got custom days! ${instanceManager.sessionStorage.customDays}');
  }

  Future<int> addCustomDay(
      GlobalKey<FormBuilderState> key, List<TimeSlot> customSchdule) async {
    try {
      if (key.currentState!.validate()) {
        key.currentState!.save();

        final date = DateTime.parse(
            key.currentState!.fields['customDate']!.value.toString());

        if (await _firebaseCrud.findDate(date.toString())) {
          logger.e('Day Already in customdays list!');
          return 2;
        }

        if (customSchdule.isEmpty) {
          logger.e('No timeSlots added to day!');
          return 3;
        }

        Day customDay = Day(
            date: date, weekday: date.weekday, id: date.toString(), times: []);

        final res = await _firebaseCrud.addCustomDay(customDay);
        if (res == null) {
          logger.e('Error: addCustomDay returned error');
          return -1;
        }

        for (var timeSlot in customSchdule) {
          final result =
              await _firebaseCrud.addTimeSlotToCustomDay(res, timeSlot);
          if (result != 1) {
            logger.e(
                'Error: addTimeSlot for TimeSlot ${timeSlot.startTime.toString()} - ${timeSlot.endTime.toString()} returned error');
            return -1;
          }
        }
        logger.i('Added custom day!');
        instanceManager.sessionStorage.needsRecalculation = true;
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      logger.e('Error adding custom day: $e');
      return -1;
    }
  }

  Future<int> updateCustomDayTimes(Day day) async {
    var res = await _firebaseCrud.clearTimesForCustomDay(day.id);
    if (res != 1) {
      return -1;
    }
    for (var slot in day.times) {
      res = await _firebaseCrud.addTimeSlotToCustomDay(day.id, slot);
      if (res != 1) {
        return -1;
      }
    }
    instanceManager.sessionStorage.needsRecalculation = true;
    return 1;
  }

  Future<void> getTimeSlotsForCustomDay(Day day) async {
    final times = await _firebaseCrud.getTimeSlotsForCustomDay(day.id);
    day.times = times;
    if (day.times == null) day.times = [];
  }

  Future<int> deleteCustomDay(String dayID) async {
    instanceManager.sessionStorage.needsRecalculation = true;
    return await _firebaseCrud.deleteCustomDay(dayID);
  }

  Future<int> markTimeSlotAsComplete(String dayID, TimeSlot timeSlot) async {
    try {
      await _firebaseCrud.markCalendarTimeSlotAsComplete(dayID, timeSlot.id);
      await getCalendarDay(instanceManager.sessionStorage.currentDay);
      final String unitOrRevision = getUnitOrRevision(timeSlot.unitName) + 's';

      final UnitModel unit = await _firebaseCrud.getSpecificUnit(
          timeSlot.courseID, timeSlot.unitID, unitOrRevision.toLowerCase());
      unit.completionTime = unit.completionTime + timeSlot.duration;

      if (await _firebaseCrud.updateUnitCompletionTime(
              timeSlot.courseID,
              timeSlot.unitID,
              unitOrRevision.toLowerCase(),
              unit.completionTime) !=
          1) {
        unit.completionTime = unit.completionTime - timeSlot.duration;
        return -1;
      }
      ;
      if (unit.completionTime == unit.sessionTime) {
        //logger.i('Changing unit to complete...');
        await _firebaseCrud.markUnitAsComplete(
            timeSlot.courseID, timeSlot.unitID);
      }
      //logger.i('Success marking timeSlot as complete!');
      return 1;
    } catch (e) {
      logger.e(
          'Error marking calendar timeSlot as complete(calendarController): $e');
      return -1;
    }
  }

  Future<int> markAllTimeSlotsAsCompleteForDay(DateTime date) async {
    Day day = await _firebaseCrud.getCalendarDayByDate(date);
    logger.i('Obtained day: ${day.id}');
    day.times = await _firebaseCrud.getTimeSlotsForCalendarDay(day.id);
    int res = 1;
    for (var timeSlot in day.times) {
      logger.i('Marking timeSlot ${timeSlot.id} as complete...');
      res = await markTimeSlotAsComplete(day.id, timeSlot);

      if (res != 1) return res;
      logger.i('TimeSlot completed!');
    }
    return res;
  }

  Future<int> markTimeSlotListAsComplete(List<TimeSlot> arr) async {
    try {
      for (TimeSlot timeSlot in arr) {
        logger.i(timeSlot.getInfoString());
        int res = await markTimeSlotAsComplete(timeSlot.dayID, timeSlot);
        if (res == -1) return -1;
      }
      return 1;
    } catch (e) {
      logger.e('Error markign TimeSlot List as complete. $e');
      return -1;
    }
  }

  Future<int> markTimeSlotAsIncomplete(Day day, TimeSlot timeSlot) async {
    try {
      await _firebaseCrud.markCalendarTimeSlotAsIncomplete(day.id, timeSlot.id);
      await getCalendarDay(instanceManager.sessionStorage.currentDay);
      final unitOrRevision = getUnitOrRevision(timeSlot.unitName) + 's';
      final UnitModel unit = await _firebaseCrud.getSpecificUnit(
          timeSlot.courseID, timeSlot.unitID, unitOrRevision.toLowerCase());
      unit.completionTime = unit.completionTime - timeSlot.duration;

      if (await _firebaseCrud.updateUnitCompletionTime(
              timeSlot.courseID,
              timeSlot.unitID,
              unitOrRevision.toLowerCase(),
              unit.completionTime) !=
          1) {
        unit.completionTime = unit.completionTime + timeSlot.duration;
        return -1;
      }
      ;

      await _firebaseCrud.markUnitAsIncomplete(
          timeSlot.courseID, timeSlot.unitID);

      //logger.i('Success marking timeSlot as not complete!');
      instanceManager.sessionStorage.needsRecalculation = true;
      return 1;
    } catch (e) {
      logger.e('Error marking timeSlot as not complete: $e');
      return -1;
    }
  }

  Future<void> getIncompletePreviousDays(DateTime date) async {
    try {
      final now = stripTime(DateTime.now());

      while (now.isAfter(date)) {
        final obtainedDay = await _firebaseCrud.getCalendarDay(date);

        bool addToResult = false;

        var listOfTimeSlots = <TimeSlot>[];
        for (var timeSlot in obtainedDay.times) {
          if (timeSlot.completed == false) {
            addToResult = true;
            listOfTimeSlots.add(timeSlot);
          }
        }
        if (addToResult)
          instanceManager.sessionStorage
              .incompletePreviousDays[date.toString()] = listOfTimeSlots;
        date = date.add(const Duration(days: 1));
      }
    } catch (e) {
      logger.e('Error getting previous inComplete days: $e');
    }
  }
}
