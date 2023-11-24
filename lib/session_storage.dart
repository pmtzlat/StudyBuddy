import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class SessionStorage {
  List<CourseModel> savedCourses =[];
  List<CourseModel> activeCourses = [];

  //NEEDS: a varibale that saves wether the calendar needs recalculating
  // after a new course is added!!

  List<List<TimeSlot>> weeklyGaps = [];
  List<Day> customDays = [];
  List<Day> activeCustomDays = [];

  Day loadedCalendarDay = Day(
      date: DateTime.now(), weekday: DateTime.now().weekday, id: 'Placeholder');

  DateTime currentDay = stripTime(DateTime.now());
  bool dayLoaded = false;

  var savedWeekday = 0;
  int? schedulePresent;
  List<String> leftoverCourses = [];

  bool needsRecalculation = false;
  Map<String,List<TimeSlot>> incompletePreviousDays = {};
}
