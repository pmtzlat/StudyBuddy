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

  void printList(List<TimeSlotModel> list) {
    var res = [];
    for (TimeSlotModel x in list) {
      res.add([x.weekday, x.startTime, x.endTime]);
    }
    logger.i(res);
  }

  Future<bool?> getGaps() async {
    try {
      instanceManager.sessionStorage.weeklyGaps =
          await _firebaseCrud.getGaps() ;
      

      
      return true;
    } catch (e) {
      logger.e('Error getting gaps: $e');
      return false;
    }
  }

  Future<bool> getGapsForDay(int weekday) async {
    try{
      instanceManager.sessionStorage.weeklyGaps[weekday-1] = await _firebaseCrud.getGapsForDay(weekday);
      return true;
    }catch(e){
      logger.e('Error getting gaps for weekday $weekday: $e');
      return false;
    }

  }

  Future<int> calculateSchedule() async {
    
    var result = await instanceManager.studyPlanner.calculateSchedule();
    switch (result) {
      case (1):
        logger.i('Result of calculating new schedule: Success');
      case (0):
        logger.i('Result of calculating new schedule: No time');
      default:
        logger.i('Result of calculating new schedule: Failure');
    }

    if (result == 1) {
      instanceManager.sessionStorage.setNeedsRecalc(false);
    }

    return result;
  }

  Future<void> deleteGap(TimeSlotModel timeSlot) async {
    await instanceManager.firebaseCrudService.deleteGap(timeSlot);
    instanceManager.sessionStorage.setNeedsRecalc(true);
    
  }

  Future<int> addGap(GlobalKey<FormBuilderState> key, int weekday,
      List<TimeSlotModel> provisionalList) async {
    try {
      logger.i('Adding gap...');

      final startTime =
          dateTimeToTimeOfDay(key.currentState!.fields['startTime']!.value);
      var endTime =
          dateTimeToTimeOfDay(key.currentState!.fields['endTime']!.value);

      if (endTime.hour == 0 && endTime.minute == 0) {
        endTime = const TimeOfDay(hour: 23, minute: 59);
      }

      var newProvisionalList = List<TimeSlotModel>.from(provisionalList);

      newProvisionalList = checkGapClash(startTime, endTime, weekday, newProvisionalList);

      await _firebaseCrud
              .clearGapsForWeekday(_firebaseCrud.weekDays[weekday - 1]);
                

      for (var timeSlot in newProvisionalList) {
        logger.f(
            '${timeSlot.startTime.toString()} - ${timeSlot.endTime.toString()}');
        final res = await _firebaseCrud
            .addTimeSlotGap(timeSlot: timeSlot)
             ;
        if (res != 1) {
          return -1;
        }
      }
      instanceManager.sessionStorage.setNeedsRecalc(true);
      return 1;
    } catch (e) {
      logger.e('Error adding gap: $e');
      return -1;
    }
  }

  Future<bool?> getCalendarDay(DateTime date) async {
    try {
      
      
      instanceManager.sessionStorage.prevDay =
          instanceManager.sessionStorage.loadedCalendarDay;
      instanceManager.sessionStorage.prevDayDate =
          instanceManager.sessionStorage.selectedDate;

      instanceManager.sessionStorage.selectedDate =
          DateTime(date.year, date.month, date.day);


      var savedDate = instanceManager.sessionStorage.selectedDate;

      instanceManager.sessionStorage.loadedCalendarDay = await _firebaseCrud
          .getCalendarDay(savedDate)
           ;

      

      logger.i(
          'Got current Day! ${instanceManager.sessionStorage.loadedCalendarDay.getString()}');
      return true;
    } catch (e) {
      logger.e('Error getting current days (in calendarController): $e');
      instanceManager.sessionStorage.loadedCalendarDay =
          instanceManager.sessionStorage.prevDay;
      instanceManager.sessionStorage.selectedDate =
          instanceManager.sessionStorage.prevDayDate;
      return false;
    }
  }

  List<TimeSlotModel> checkGapClash(TimeOfDay newStart, TimeOfDay newEnd,
      int weekday, List<TimeSlotModel> provisionalList) {
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

      provisionalList.add(TimeSlotModel(
          examID: 'free',
          startTime: newStart,
          endTime: newEnd,
          weekday: weekday));

      return provisionalList;
    } catch (e) {
      logger.e('Error in check Gap Clash: $e');
      return [];
    }
  }

  String getCustomDaysString() {
    String res = '';
    for (DayModel day in instanceManager.sessionStorage.customDays) {
      res += '\n ${day.getString()}';
    }
    return res;
  }

  Future<bool?> getCustomDays() async {
    try {
      final days = await _firebaseCrud.getCustomDays() ;
      instanceManager.sessionStorage.customDays = days;

      logger.i('Got custom days! ${getCustomDaysString()} \n ${days.length}');
      
      return true;
    } on Exception catch (e) {
      logger.e('Error getting cutom days. $e');
      return false;
    }
  }

  Future<int> updateCustomDay(
    DayModel day,
    GlobalKey<FormBuilderState>? key,
  ) async {
    
    int findIndexOfMatchingDate(List<DayModel> dayModels, DateTime targetDate) {
      for (int i = 0; i < dayModels.length; i++) {
        if (dayModels[i].date.isAtSameMomentAs(targetDate)) {
          return i;
        }
      }
      // If no match is found, you can return a special value or throw an exception.
      // For simplicity, I'll return -1.
      return -1;
    }

    try {
      if (key != null) {
        final startTime =
            dateTimeToTimeOfDay(key.currentState!.fields['startTime']!.value);
        var endTime =
            dateTimeToTimeOfDay(key.currentState!.fields['endTime']!.value);

        if (endTime.hour == 0 && endTime.minute == 0) {
          endTime = const TimeOfDay(hour: 23, minute: 59);
        }

        day.timeSlots =
            checkGapClash(startTime, endTime, day.weekday, day.timeSlots);
      }
      bool customDayExists =
          await _firebaseCrud.checkIfCustomDayExists(day.date);

      if (customDayExists) {
        if (compareTimeSlotLists(day.timeSlots,
            instanceManager.sessionStorage.weeklyGaps[day.date.weekday - 1])) {
          logger.i('Day exists and is the same as normal schedule');

          instanceManager.sessionStorage.customDays.removeAt(
              findIndexOfMatchingDate(instanceManager.sessionStorage.customDays,
                  stripTime(day.date)));

          await _firebaseCrud.deleteCustomDay(day.id);
        } else {
          logger.i('Day exists but is not the same as normal schedule');
          DayModel dayObject = DayModel(
              weekday: day.date.weekday, date: day.date, times: day.timeSlots);
          dayObject.getTotalAvailableTime();
          instanceManager.sessionStorage.customDays.add(dayObject);
          await _firebaseCrud.clearTimesForCustomDay(day.id);
          for (TimeSlotModel timeSlot in day.timeSlots) {
            timeSlot.date = day.date;
            await _firebaseCrud.addTimeSlotToCustomDay(day.id, timeSlot);
          }
        }
      } else {
        if (!compareTimeSlotLists(day.timeSlots,
            instanceManager.sessionStorage.weeklyGaps[day.date.weekday - 1])) {
          logger.i('Day doesn\'t exist but is different from normal schedule');
          DayModel dayObject = DayModel(
              weekday: day.date.weekday, date: day.date, times: day.timeSlots);
          dayObject.getTotalAvailableTime();
          instanceManager.sessionStorage.customDays.add(dayObject);
          day.id = await _firebaseCrud.addCustomDay(day);
          
          for (TimeSlotModel timeSlot in day.timeSlots) {
            timeSlot.date = day.date;
            await _firebaseCrud.addTimeSlotToCustomDay(day.id, timeSlot);
          }
        } else {
          logger.i('Day doesn\'t exists and is the same as normal schedule');
          instanceManager.sessionStorage.customDays.removeAt(
              findIndexOfMatchingDate(instanceManager.sessionStorage.customDays,
                  stripTime(day.date)));
        }
      }
      instanceManager.sessionStorage.setNeedsRecalc(true);
      return 1;
    } on Exception catch (e) {
      logger.e('Error updating Custom day $e');
      return -1;
    }
  }

  

  Future<int> markTimeSlotAsComplete(
      String dayID, TimeSlotModel timeSlot) async {
    try {
      await _firebaseCrud.markCalendarTimeSlotAsComplete(dayID, timeSlot.id);

      return 1;
    } catch (e) {
      logger.e(
          'Error marking calendar timeSlot as complete(calendarController): $e');
      return -1;
    }
  }

  Future<int> markAllTimeSlotsAsCompleteForDay(DateTime date) async {
    try {
      DayModel day = await _firebaseCrud
          .getCalendarDayByDate(date)
           ;
      ;
      logger.i('Obtained day: ${day.id}');
      day.timeSlots = await _firebaseCrud
          .getTimeSlotsForCalendarDay(day.id)
           ;
      ;
      int res = 1;
      for (var timeSlot in day.timeSlots) {
        logger.i('Marking timeSlot ${timeSlot.id} as complete...');
        res = await markTimeSlotAsComplete(day.id, timeSlot);

        if (res != 1) return res;
        logger.i('TimeSlot completed!');
      }
      return res;
    } on Exception catch (e) {
      logger.e('Error marking all timeslots as complete for a day $e');
      return -1;
    }
  }

  Future<int> markTimeSlotListAsComplete(List<TimeSlotModel> arr) async {
    try {
      for (TimeSlotModel timeSlot in arr) {
        logger.i(timeSlot.getString());
        await timeSlot.changeCompleteness(true);
        
        
      }
      return 1;
    } catch (e) {
      logger.e('Error markign TimeSlot List as complete. $e');
      return -1;
    }
  }

  Future<int> markTimeSlotAsIncomplete(
      DayModel day, TimeSlotModel timeSlot) async {
    try {
      await _firebaseCrud
          .markCalendarTimeSlotAsIncomplete(day.id, timeSlot.id)
           ;
      
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
        final obtainedDay =
            await _firebaseCrud.getCalendarDay(date) ;
        ;

        bool addToResult = false;

        var listOfTimeSlots = <TimeSlotModel>[];
        for (var timeSlot in obtainedDay.timeSlots) {
          if (timeSlot.completed == false) {
            addToResult = true;
            listOfTimeSlots.add(timeSlot);
          }
        }
        if (addToResult && !obtainedDay.notifiedIncompleteness)
          instanceManager.sessionStorage
              .incompletePreviousDays[date.toString()] = listOfTimeSlots;
        date = date.add(const Duration(days: 1));
      }
    } catch (e) {
      logger.e('Error getting previous inComplete days: $e');
    }
  }

  Future<void> markDayAsNotified(DateTime date) async {
    try {
      DayModel dayToChange = await _firebaseCrud
          .getCalendarDayByDate(date)
           ;
      ;
      await _firebaseCrud
          .markCalendarDayAsNotified(dayToChange.id)
           ;
      ;
    } catch (e) {
      logger.e('Error marking Day as notified: $e');
    }
  }

  Future<void> saveTimeStudied(TimeSlotModel timeSlot) async {
    try {
      logger.i('Saving time studied for timeslot ${timeSlot.id}, in day ${timeSlot.dayID}');
      await _firebaseCrud
          .updateTimeStudiedForTimeSlot(
              timeSlot.id, timeSlot.dayID, timeSlot.timeStudied);
      
           
    } catch (e) {
      logger.e('Error saving time Studied for timeslot: $e');
    }
  }

  Future<int> resetTimeStudied(TimeSlotModel timeSlot) async {
    try {
      await _firebaseCrud
          .resetTimeSlotTimeStudied(
              timeSlot.id, timeSlot.dayID, timeSlot.timeStudied)
           ;
      ;
      await _firebaseCrud
          .subtractTimeFromUnitRealStudyTime(
              timeSlot.examID, timeSlot.unitID, timeSlot.timeStudied)
           ;
      ;
      await _firebaseCrud
          .subtractTimeFromExamTimeStudied(
              timeSlot.examID, timeSlot.timeStudied)
           ;
      ;
      return 1;
    } catch (e) {
      logger.e('Error resetting time studied for timeSlot: $e');
      return -1;
    }
  }

  Future<TimeSlotModel> getTimeSlot(String timeSlotID, String dayID) async {
    return await _firebaseCrud.getTimeSlot(timeSlotID, dayID);
  }

  Future<void> updateTimeSlotCompleteness(TimeSlotModel timeSlot) async {
    if (timeSlot.completed) {
      await markTimeSlotAsComplete(timeSlot.dayID, timeSlot);
    } else {
      await markTimeSlotAsIncomplete(
          await instanceManager.firebaseCrudService
              .getCalendarDayByID(timeSlot.dayID),
          timeSlot);
    }
  }

  Future<bool> getAllCalendarDaySessionNumbers() async {
    instanceManager.sessionStorage.calendarDaySessions =
        await _firebaseCrud.getAllCalendarDaySessionsNumbers();
    logger.w(
        'Got calendar Day sessions!\n ${instanceManager.sessionStorage.calendarDaySessions}');
    return true;
  }
}
