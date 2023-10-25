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
        // Handle invalid input (return a default time if necessary)
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