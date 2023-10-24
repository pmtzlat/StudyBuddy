import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';

class SessionStorage {
  List<CourseModel>? savedCourses;
  List<CourseModel>? activeCourses;
  int calendarBeginPage = 0;
  bool updatedCoursesView = false;

  //NEEDS: a varibale that saves wether the calendar needs recalculating
  // after a new course is added!!

  List<List<TimeSlot>>? weeklyRestrictions;

  

  var savedWeekday = 0;
  int? schedulePresent;
}
