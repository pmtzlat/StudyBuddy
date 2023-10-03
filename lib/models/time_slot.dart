class TimeSlot{

  final String id;
  final String weekday;
  final int startTime;
  final int endTime;
  final String courseID;
  final String unitID;

  TimeSlot({
    this.id = '',
    required this.weekday ,
    required this.startTime, 
    required this.endTime, 
    required this.courseID,
    required this.unitID
  });

}