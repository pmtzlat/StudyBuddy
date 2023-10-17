import 'package:study_buddy/services/logging_service.dart';

class TimeSlot {
  final String id;
  final int weekday;
  int startTime;
  int endTime;
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
      this.unitName});

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
    final result = 'TimeSlot: \n${weekdays[weekday]} ${startTime} - ${endTime} ';
    return result;
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
