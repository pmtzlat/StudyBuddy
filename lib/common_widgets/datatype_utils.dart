import 'package:flutter/material.dart';
import 'package:study_buddy/services/logging_service.dart';

TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute;
  return TimeOfDay(hour: hour, minute: minute);
}

bool isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
  var minutes1 = time1.hour * 60 + time1.minute;
  var minutes2 = time2.hour * 60 + time2.minute;

  
  final res = minutes1 < minutes2;
  logger.t('$time1 ($minutes1) is before $time2 ($minutes2) = $res');

  return res;
}

TimeOfDay stringToTimeOfDay24Hr(String timeString) {
      List<String> parts = timeString.split(':');
      if (parts.length == 2) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        return TimeOfDay(hour: hours, minute: minutes);
      } else {
        
        return TimeOfDay(hour: 0, minute: 0);
      }
    }


bool stringToBool(String stringValue) {
  if (stringValue.toLowerCase() == 'true') {
    return true;
  } else if (stringValue.toLowerCase() == 'false') {
    return false;
  } else {
    return false; 
  }
}

Duration doubleToDuration(double hours) {
  int totalMinutes = (hours * 60).round();
  int hoursPart = totalMinutes ~/ 60; 
  int minutesPart = totalMinutes % 60; 

  return Duration(hours: hoursPart, minutes: minutesPart);
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = (duration.inMinutes % 60);
  return '$hours hr $minutes min';
}

double durationToDouble(Duration duration) {
  final totalMinutes = duration.inMinutes;
  final hoursPart = totalMinutes ~/ 60;
  final minutesPart = totalMinutes % 60;

  return hoursPart + (minutesPart / 60.0); // Convert minutes to hours
}
