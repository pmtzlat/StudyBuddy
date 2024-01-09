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

DateTime stripTime(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

bool areDatesEqual(DateTime dateTime1, DateTime dateTime2) {
  return dateTime1.year == dateTime2.year &&
      dateTime1.month == dateTime2.month &&
      dateTime1.day == dateTime2.day;
}

bool isSecondDayNext(DateTime firstDateTime, DateTime secondDateTime) {
  final firstDate =
      DateTime(firstDateTime.year, firstDateTime.month, firstDateTime.day);
  final secondDate =
      DateTime(secondDateTime.year, secondDateTime.month, secondDateTime.day);

  final differenceInDays = secondDate.difference(firstDate).inDays;

  return differenceInDays == 1;
}

TimeOfDay addDurationToTimeOfDay(TimeOfDay time, Duration duration) {
  int totalMinutes = time.hour * 60 + time.minute;

  totalMinutes += duration.inMinutes;

  int newHour = totalMinutes ~/ 60;
  int newMinute = totalMinutes % 60;

  newHour = newHour.clamp(0, 23);
  newMinute = newMinute.clamp(0, 59);

  return TimeOfDay(hour: newHour, minute: newMinute);
}

String timeOfDayToStr(TimeOfDay time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

bool stickyTime(
    String type, TimeOfDay timeInQuestion, TimeOfDay start, TimeOfDay end) {
  if (type == 'Start') {
    if (isTimeBefore(start, timeInQuestion) &&
        isTimeBefore(timeInQuestion, end)) {
      return true;
    }

    if (start == timeInQuestion || timeInQuestion == end) {
      return true;
    }

    if (timeInQuestion == addDurationToTimeOfDay(end, Duration(minutes: 1))) {
      return true;
    }
    return false;
  }

  if (type == 'End') {
    if (isTimeBefore(start, timeInQuestion) &&
        isTimeBefore(timeInQuestion, end)) {
      return true;
    }

    if (start == timeInQuestion || timeInQuestion == end) {
      return true;
    }

    if (start == addDurationToTimeOfDay(timeInQuestion, Duration(minutes: 1))) {
      return true;
    }
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

TimeOfDay subtractDurationFromTimeOfDay(TimeOfDay time, Duration duration) {
  // Convert TimeOfDay to total minutes since midnight
  final timeMinutes = time.hour * 60 + time.minute;

  final durationMinutes = duration.inMinutes;

  var resultMinutes = timeMinutes - durationMinutes;

  if (resultMinutes < 0) {
    resultMinutes = 0;
  }
  final hours = resultMinutes ~/ 60;
  final minutes = resultMinutes % 60;
  return TimeOfDay(hour: hours, minute: minutes);
}

String getUnitOrRevision(String unitName) {
  if (unitName.contains('Revision')) {
    return 'Revision';
  } else if (unitName.contains('Unit')) {
    return 'Unit';
  } else {
    return 'Unknown';
  }
}

String formatDateTime(DateTime dateTime) {
  String day = dateTime.day.toString().padLeft(2, '0');
  String month = dateTime.month.toString().padLeft(2, '0');
  String year = dateTime.year.toString();

  return '$day/$month/$year';
}
