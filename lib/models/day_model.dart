import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class DayModel {
  final int weekday;
  String id;
  final DateTime date;
  List<TimeSlotModel> times;
  late Duration totalAvailableTime;
  bool notifiedIncompleteness;
  Color? color;

  DayModel({
    required this.weekday,
    this.id = '',
    required this.date,
    List<TimeSlotModel>? times,
    this.notifiedIncompleteness = false,
    this.color,
  }) : times = times ?? [];

  String getString() {
    String timesString = '';
    for (TimeSlotModel slot in times!) {
      timesString +=
          '\n ${slot.startTime} - ${slot.endTime} : ${slot.examName ?? slot.examID} ${slot.unitName}';
    }

    return '$id -> $date: $weekday\n Times: $timesString';
  }

  void getTotalAvailableTime() {
    totalAvailableTime = getTotal(times);
    //logger.d('new total available: $totalAvailableTime');
  }

  Future<void> getGaps() async {
    if (id != 'empty') {
      times = await instanceManager.firebaseCrudService
          .getTimeSlotsForCustomDay(id);
      times.sort((a, b) {
        if (a.startTime.hour != b.startTime.hour) {
          return b.startTime.hour - a.startTime.hour;
        } else {
          return b.startTime.minute - a.startTime.minute;
        }
      });
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

      times = updated;
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
    for (int i = times.length - 1; i >= 0; i--) {
      var currentItem = times[i];
      if (isTimeBefore(currentItem.endTime, newStart)) {
        times.removeAt(i);
      } else {
        if (isTimeBefore(currentItem.startTime, newStart)) {
          currentItem.startTime = newStart;
        }
      }
    }
  }
}
