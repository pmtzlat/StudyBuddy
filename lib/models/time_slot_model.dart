import 'package:flutter/material.dart';
import 'package:study_buddy/services/logging_service.dart';

class TimeSlot {
   String id;
  final int weekday; // from 1 - 7
  TimeOfDay startTime;
  TimeOfDay endTime;
  Duration duration;
  Duration timeStudied;

  final String examID;
  final String unitID;
  final String examName;
  final String unitName;
  bool completed;
  final String dayID;
  DateTime? date;

  TimeSlot(
      {this.id = '',
      required this.weekday,
      required this.startTime,
      required this.endTime,
      this.timeStudied = Duration.zero,
      required this.examID,
      this.unitID= '',
      this.examName = '',
      this.unitName= '',
      this.completed = false,
      this.dayID = '',
      this.date})
      : duration = _calculateDuration(startTime, endTime);

  static Duration _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final minutesDifference = endMinutes - startMinutes;
    final minutes = minutesDifference % 60;
    final hours = (minutesDifference - minutes) ~/ 60;
    return Duration(hours: hours, minutes: minutes);
  }

  void calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final minutesDifference = endMinutes - startMinutes;
    final minutes = minutesDifference % 60;
    final hours = (minutesDifference - minutes) ~/ 60;

    //logger.d('New duration for timeSlot $startTime - $endTime -> $hours : $minutes');
    duration =  Duration(hours: hours, minutes: minutes);
  }

  String getInfoString() {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final result =
        'TimeSlot: \n${weekdays[weekday-1]} ${startTime.toString()} - ${endTime.toString()} : $examName';
    return result;
  }

  String timeOfDayToString(TimeOfDay time){
    final String formattedHour = time.hour.toString().padLeft(2, '0');
  final String formattedMinute = time.minute.toString().padLeft(2, '0');
  return '$formattedHour:$formattedMinute';

  }

  


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          weekday == other.weekday &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          examID == other.examID &&
          unitID == other.unitID;

  @override
  int get hashCode =>
      id.hashCode ^
      weekday.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      examID.hashCode ^
      unitID.hashCode;
}
