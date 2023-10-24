import 'package:flutter/material.dart';
import 'package:study_buddy/services/logging_service.dart';

class TimeSlot {
  final String id;
  final int weekday;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Duration duration;

  final String courseID;
  final String? unitID;
  final String? courseName;
  final String? unitName;

  TimeSlot(
      {this.id = '',
      required this.weekday,
      required this.startTime,
      required this.endTime,
      required this.courseID,
      this.unitID,
      this.courseName,
      this.unitName})
      : duration = _calculateDuration(startTime, endTime);

  static Duration _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final minutesDifference = endMinutes - startMinutes;
    final minutes = minutesDifference % 60;
    final hours = (minutesDifference - minutes) ~/ 60;
    return Duration(hours: hours, minutes: minutes);
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
        'TimeSlot: \n${weekdays[weekday]} ${startTime.toString()} - ${endTime.toString()} ';
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
          courseID == other.courseID &&
          unitID == other.unitID;

  @override
  int get hashCode =>
      id.hashCode ^
      weekday.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      courseID.hashCode ^
      unitID.hashCode;
}
