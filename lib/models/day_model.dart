import 'package:study_buddy/models/time_slot.dart';
import 'package:study_buddy/services/logging_service.dart';

class Day{
  final int weekday;
  final String id;
  final DateTime date;
  final List<TimeSlot>? times;

  Day({
    required this.weekday, 
    this.id = '',
    required this.date,
    this.times,
  });


  void print(){
    logger.i('$date: $weekday');
  }
}