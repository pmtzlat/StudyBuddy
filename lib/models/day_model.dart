import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class Day {
  final int weekday;
  final String id;
  final DateTime date;
  List<TimeSlot> times;
  late int totalAvailableTime;

  Day({
    required this.weekday,
    this.id = '',
    required this.date,
    List<TimeSlot>? times,
  }) : times = times ?? [];

  void getTotalAvailableTime() {
    int availableTime = 24; // The entire day is initially available.

    for (final timeSlot in times) {
      availableTime -= (timeSlot.endTime - timeSlot.startTime + 1);
    }

    totalAvailableTime = availableTime;
  }

  String getString() {
    String timesString = '';
    for (TimeSlot slot in times!) {
      timesString +=
          '\n ${slot.startTime} - ${slot.endTime} : ${slot.courseName ?? slot.courseID}';
    }

    return '$date: $weekday\n Times: $timesString';
  }

  TimeSlot? findLatestTimegap() {
    if (times == null || times.isEmpty) {
      return TimeSlot(
          weekday: weekday, startTime: 0, endTime: 23, courseID: 'available');
    }

    times.sort((a, b) => a.startTime.compareTo(b.startTime));

    int startTime = -1;
    int endTime = -1;
    if (times.length == 1) {
      if (times[0].endTime == 23) {
        if (times[0].startTime != 0) {
          startTime = 0;
          endTime = times[0].startTime - 1;
        } else {
          return null;
        }
      } else {
        startTime = times[0].endTime + 1;
        endTime = 23;
      }
    } else {
      for (int i = times.length - 1; i >= 0; i--) {
        if (i == 0) {
          if (times[i].startTime == 0) {
            return null;
          }
          startTime = 0;
          endTime = times[i].startTime - 1;
          break;
        } else {
          if (i == times.length - 1) {
            if (times[i].endTime != 23) {
              startTime = times[i].endTime + 1;
              endTime = 23;
              break;
            }
          }
          if (times[i].startTime - times[i - 1].endTime > 1) {
            startTime = times[i - 1].endTime + 1;
            endTime = times[i].startTime - 1;
            break;
          }
        }
      }
    }

    if ((startTime >= 0) && (endTime >= 0)) {
      return TimeSlot(
          weekday: weekday,
          startTime: startTime,
          endTime: endTime,
          courseID: 'available');
    }
  }
}
