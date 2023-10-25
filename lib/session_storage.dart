import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';

class SessionStorage {
  List<CourseModel>? savedCourses;
  List<CourseModel>? activeCourses;
  int calendarBeginPage = 0;

  //NEEDS: a varibale that saves wether the calendar needs recalculating
  // after a new course is added!!

  List<List<TimeSlot>>? weeklyRestrictions;
  List<Day> customDays = [];
  List<Day> activeCustomDays = [];

  

  var savedWeekday = 0;
  int? schedulePresent;
}
