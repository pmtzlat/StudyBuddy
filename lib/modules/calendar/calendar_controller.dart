import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/common_widgets/datatype_utils.dart';
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

    if (instanceManager.sessionStorage.weeklyGaps == null) {
      addDefaultGaps();
    }
  }

  void addDefaultGaps() async {
    logger.i('Adding Default Gaps...');

    for (var i = 0; i < 7; i++) {
      final newSlot = TimeSlot(
          weekday: i + 1,
          startTime: TimeOfDay(hour: 0, minute: 0),
          endTime: TimeOfDay(hour: 9, minute: 0),
          courseID: 'busy');

      await instanceManager.firebaseCrudService.addTimeGap(timeSlot: newSlot);
    }
    instanceManager.sessionStorage.weeklyGaps = await _firebaseCrud.getGaps();
  }

  void calculateSchedule() async {
    logger.i(await instanceManager.studyPlanner.calculateSchedule());
  }

  Future<int?> deleteGap(TimeSlot timeSlot) async {
    final res =
        await instanceManager.firebaseCrudService.deleteGap(timeSlot); //EDIT

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
              final res = await _firebaseCrud.addTimeGap(timeSlot: timeSlot);
              if (res != 1) {
                return -1;
              }
            }
            return 1;

          default:
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
      //logger.f('deleteIndexes: $itemsToDeleteFromProvisionalList');
      //logger.f('provisinalList: $provisionalList');

      for (var index in itemsToDeleteFromProvisionalList) {
        provisionalList.removeAt(index);
      }

      provisionalList.add(TimeSlot(
          courseID: 'free',
          startTime: newStart,
          endTime: newEnd,
          weekday: weekday));

      String printer = 'ProvisionalList: \n';

      for (var gap in provisionalList) {
        printer += '\n ${gap.startTime} - ${gap.endTime}';
      }

      logger.d(printer);

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
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      logger.e('Error adding custom day: $e');
      return -1;
    }
  }

  Future<int> updateTimes(Day day) async {
    var res = await _firebaseCrud.clearTimesForDay(day.id);
    if (res != 1) {
      return -1;
    }
    for (var slot in day.times) {
      res = await _firebaseCrud.addTimeSlotToCustomDay(day.id, slot);
      if (res != 1) {
        return -1;
      }
    }
    return 1;
  }

  Future<void> getTimeSlotsForDay(Day day) async {
    final times = await _firebaseCrud.getTimeSlotsForDay(day.id);
    day.times = times;
    if (day.times == null) day.times = [];
  }

  Future<int> deleteCustomDay(String dayID) async {
    return await _firebaseCrud.deleteCustomDay(dayID);
  }

}
