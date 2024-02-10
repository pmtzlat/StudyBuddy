import 'package:flutter/material.dart';
import 'package:study_buddy/services/logging_service.dart';

class TimeSlotModel {
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
  Color examColor;

  TimeSlotModel(
      {this.id = '',
      required this.weekday,
      required this.startTime,
      required this.endTime,
      this.timeStudied = Duration.zero,
      required this.examID,
      this.unitID = '',
      this.examName = 'ExamPlaceholderName',
      this.unitName = 'UnitPlaceholderName',
      this.completed = false,
      this.dayID = '',
      this.date,
      this.examColor = Colors.amber})
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
    duration = Duration(hours: hours, minutes: minutes);
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
        'TimeSlot: \n${weekdays[weekday - 1]} ${startTime.toString()} - ${endTime.toString()} : $examName';
    return result;
  }

  TimeSlotModel.from(TimeSlotModel other)
      : id = other.id,
        weekday = other.weekday,
        startTime = other.startTime,
        endTime = other.endTime,
        duration = other.duration,
        timeStudied = other.timeStudied,
        examID = other.examID,
        unitID = other.unitID,
        examName = other.examName,
        unitName = other.unitName,
        completed = other.completed,
        dayID = other.dayID,
        date = other.date,
        examColor = other.examColor;

  String timeOfDayToString(TimeOfDay time) {
    final String formattedHour = time.hour.toString().padLeft(2, '0');
    final String formattedMinute = time.minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  String getString() {
    String res =
        'TimeSlot: $id: \n $startTime - $endTime \n $timeStudied \n $completed';
        return res;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlotModel &&
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
