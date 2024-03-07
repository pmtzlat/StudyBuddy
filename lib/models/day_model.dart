import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class DayModel {
  final int weekday;
  String id;
  final DateTime date;
  List<TimeSlotModel> timeSlots;
  Duration totalAvailableTime;
  bool notifiedIncompleteness;
  Color? color;

  DayModel({
    required this.weekday,
    this.id = '',
    required this.date,
    this.totalAvailableTime = const Duration(hours:24),
    List<TimeSlotModel>? times,
    this.notifiedIncompleteness = false,
    this.color,
  }) : timeSlots = times ?? [];

  String getString() {
    String timesString = '';
    for (TimeSlotModel slot in timeSlots!) {
      timesString +=
          '\n ${slot.id} -> (${slot.startTime} - ${slot.endTime}) : ${slot.examName ?? slot.examID} ${slot.unitName} - completed = ${slot.completed}';
    }

    return '$id -> $date: $weekday\n Times: $timesString \n Available Time: ${formatDuration(totalAvailableTime)}';
  }

  void getTotalAvailableTime() {
    totalAvailableTime = getTotal(timeSlots);
    //logger.d('new total available: $totalAvailableTime');
  }

  Future<void> getGaps() async {
    //await Future.delayed(Duration(seconds: 1));
    if (id != 'empty') {
      try{ 
      List<TimeSlotModel> provTimeSlots = await instanceManager.firebaseCrudService
          .getTimeSlotsForCustomDay(id);
          timeSlots = provTimeSlots;
      }
      catch(e){
        logger.w('Error getting timeSlots for custom day $date: $e');
      }
      
      sortTimeSlotList(timeSlots);
    } else {
      final List<TimeSlotModel> timeSlotList =
          instanceManager.sessionStorage.weeklyGaps[date.weekday - 1];
      var updated = timeSlotList.map((timeSlot) {
        return TimeSlotModel(
            id: timeSlot.id,
            weekday: timeSlot.weekday,
            startTime: timeSlot.startTime,
            endTime: timeSlot.endTime,
            examID: timeSlot.examID,
            unitID: timeSlot.unitID,
            examName: timeSlot.examName,
            unitName: timeSlot.unitName,
            examColor: timeSlot.examColor);
      }).toList();

      timeSlots = updated;
    }
  }

  Duration getTotal(List<TimeSlotModel> timeSlots) {
    Duration totalDuration = Duration.zero;

    for (var timeSlot in timeSlots) {
      timeSlot.calculateDuration(timeSlot.startTime, timeSlot.endTime);

      if (timeSlot.examID == 'free') {
        //logger.d('timeSlot ${timeSlot.startTime} - ${timeSlot.endTime} is free, timeSlot.');
        totalDuration += timeSlot.duration;
      }
    }

    //logger.d('total duration = $totalDuration');

    return totalDuration;
  }

  void headStart(TimeOfDay newStart) {
    for (int i = timeSlots.length - 1; i >= 0; i--) {
      var currentItem = timeSlots[i];
      if (isTimeBefore(currentItem.endTime, newStart)) {
        timeSlots.removeAt(i);
      } else {
        if (isTimeBefore(currentItem.startTime, newStart)) {
          currentItem.startTime = newStart;
        }
      }
    }
  }

  
}
