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

  return res;
}

TimeOfDay addDurationToTimeOfDay(TimeOfDay time, Duration duration) {
  int totalMinutes = time.hour * 60 + time.minute;

  totalMinutes += duration.inMinutes;

  int newHour = totalMinutes ~/ 60;
  int newMinute = totalMinutes % 60;

  newHour = newHour.clamp(0, 23);
  newMinute = newMinute.clamp(0, 59);

  logger.t('${time.hour}:${time.minute} -> $newHour:$newMinute');

  return TimeOfDay(hour: newHour, minute: newMinute);
}

bool stickyTime(
    String type, TimeOfDay timeInQuestion, TimeOfDay start, TimeOfDay end) {

  

  if (type == 'Start') {
    logger.i('Start = $timeInQuestion');
    if (isTimeBefore(start, timeInQuestion) &&
        isTimeBefore(timeInQuestion, end)) {
      logger.w('$type $timeInQuestion is between $start - $end');
      return true;
    }

    if (start == timeInQuestion || timeInQuestion == end) {
      logger.w('$type $timeInQuestion is equal to $start or $end');
      return true;
    }

    if (timeInQuestion == addDurationToTimeOfDay(end, Duration(minutes: 1))) {
      logger.w('$type $timeInQuestion = $end +1');
      return true;
    }
    logger.i('$type is independent');
    return false;
  }

  if (type == 'End') {
    if (isTimeBefore(start, timeInQuestion) &&
        isTimeBefore(timeInQuestion, end)) {
      logger.w('$type $timeInQuestion is between $start - $end');
      return true;
    }

    if (start == timeInQuestion || timeInQuestion == end) {
      logger.w('$type $timeInQuestion is equal to $start or $end');
      return true;
    }

    if (start == addDurationToTimeOfDay(timeInQuestion, Duration(minutes: 1))) {
      logger.w('$type $timeInQuestion = $start -1');
      return true;
    }
    logger.i('$type is independent');
    return false;
  }
  return false;
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

  int closestMultipleOf5 = (totalMinutes / 5).round() * 5;

  int hoursPart = closestMultipleOf5 ~/ 60;
  int minutesPart = closestMultipleOf5 % 60;

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

  double result = hoursPart + (minutesPart / 60.0); 

  
  return double.parse(result.toStringAsFixed(2));
}

