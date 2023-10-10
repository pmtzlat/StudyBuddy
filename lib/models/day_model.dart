import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class Day{
  final int weekday;
  final String id;
  final DateTime date;
  List<TimeSlot>? times;

  Day({
    required this.weekday, 
    this.id = '',
    required this.date,
    this.times,
  });


  void print(){
    String timesString = '';
    for (TimeSlot slot in times!){
      timesString += '\n ${slot.startTime} - ${slot.endTime} : ${slot.courseID}';
    }

    logger.i('$date: $weekday\n Times: $timesString');
  }
}