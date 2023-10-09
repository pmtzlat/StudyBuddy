import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class StudyPlanner {
  final _firebaseCrud = instanceManager.firebaseCrudService;
  final uid = instanceManager.localStorage.getString('uid') ?? '';

  Future<int?> calculateSchedule() async {
    await _firebaseCrud.deleteSchedule();
    List<TimeSlot>? scheduleLimits = await _firebaseCrud.getScheduleLimits();
    if (scheduleLimits == null) {
      logger.e('No restraints found');
      return null;
    }
    printAllTimeSlots(scheduleLimits);
    List<Day> days = generateDays();

    //get unit stacks

    //allocate timeslots in each day

    //save days to db

    return 1;
  }

  List<Day> generateDays() {
    DateTime loopDate = getLatestExam().subtract(Duration(days: 1));
    List<Day> result = [];
    while (loopDate.isAfter(DateTime.now()) ||
        loopDate.isAtSameMomentAs(DateTime.now())) {
      result.add(Day(weekday: loopDate.weekday - 1, date: loopDate));

      loopDate = loopDate.subtract(Duration(days: 1));
    }

    return result;
  }

  DateTime getLatestExam() {
    DateTime? currentDate = null;
    for (CourseModel course in instanceManager.sessionStorage.activeCourses) {
      if (currentDate != null) {
        if (course.examDate.isAfter(currentDate)) {
          currentDate = course.examDate;
        }
      } else {
        currentDate = course.examDate;
      }
    }
    return currentDate!;
  }

  void printAllTimeSlots(List<TimeSlot> list) {
    logger.i('Timeslots gotten:');
    for (TimeSlot x in list) {
      x.print();
    }
  }

  void generateCourseTimeSlots({required dictionary}) {
    for (CourseModel course in instanceManager.sessionStorage.activeCourses) {
      dictionary[course.id] = {
        'name': course.name,
        'weight': course.weight,
        'unitTimeSlots': [],
      };
      if (course.units != null) {
        for (UnitModel unit in course.units!) {
          final timeSlot = unitToTimeSlot(unit);
          dictionary[course.id]['unitTimeSlots'] = timeSlot;
        }
      }
    }
  }

  TimeSlot? unitToTimeSlot(UnitModel unit) {}
}

//
