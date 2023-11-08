import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class Day {
  final int weekday;
  final String id;
  final DateTime date;
  List<TimeSlot> times;
  late Duration totalAvailableTime;

  Day({
    required this.weekday,
    this.id = '',
    required this.date,
    List<TimeSlot>? times,
  }) : times = times ?? [];

  String getString() {
    String timesString = '';
    for (TimeSlot slot in times!) {
      timesString +=
          '\n ${slot.startTime} - ${slot.endTime} : ${slot.courseName ?? slot.courseID} ${slot.unitName}';
    }

    return '$id -> $date: $weekday\n Times: $timesString';
  }

  void getTotalAvailableTime() {
    totalAvailableTime = getTotal(times);
    //logger.d('new total available: $totalAvailableTime');
  }

  Future<void> getGaps() async {
    if (times.isEmpty) {
      Day dayInQuestion = instanceManager.sessionStorage.activeCustomDays
          .firstWhere((obj) => obj.date == date,
              orElse: () => Day(id: 'empty', weekday: 0, date: DateTime.now()));

      if (dayInQuestion.id != 'empty') {
        times = await instanceManager.firebaseCrudService
                .getTimeSlotsForDay(dayInQuestion.id) ??
            [];
      } else {
        final List<TimeSlot> timeSlotList =
            instanceManager.sessionStorage.weeklyGaps[date.weekday - 1];
        final updated = timeSlotList.map((timeSlot) {
          return TimeSlot(
            id: timeSlot.id,
            weekday: timeSlot.weekday,
            startTime: timeSlot.startTime,
            endTime: timeSlot.endTime,
            courseID: timeSlot.courseID,
            unitID: timeSlot.unitID,
            courseName: timeSlot.courseName,
            unitName: timeSlot.unitName,
          );
        }).toList();

        times = updated;
      }
    }
  }

  Duration getTotal(List<TimeSlot> timeSlots) {
    Duration totalDuration = Duration.zero;

    for (var timeSlot in timeSlots) {
      timeSlot.calculateDuration(timeSlot.startTime, timeSlot.endTime);

      if (timeSlot.courseID == 'free') {
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
