import 'package:study_buddy/common_widgets/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class SchedulerStack {
  late List<UnitModel> units;
  late List<UnitModel> revisions;
  int? daysUntilExam;
  double? weight;
  CourseModel course;

  SchedulerStack({required this.course});

  Future<void> initializeUnitsWithRevision(CourseModel course) async {
    try {
    } catch (e) {
      logger.d('Error initializing unitsWithRevision: $e');
      units = [];
    }
  }

  

  Future<List<UnitModel>> extractUnitsWithRevision(CourseModel course) async {
    try {
      List<UnitModel> units = [];
      final courseUnits = await instanceManager.firebaseCrudService
          .getUnitsForCourse(courseID: course.id);
      units += courseUnits;
      logger.i('Revisons for course ${course.name}: ${course.revisions}');

      return units;
    } catch (e) {
      logger.e('extractUnitsWithRevision error: $e');
      return []; // Return an empty list as a default value.
    }
  }

  void print() {
    String unitString = 'Units:';
    for (UnitModel unit in units) {
      unitString += '\n ${unit.name}, hours: ${formatDuration(unit.sessionTime)}';
    }
    unitString += '\n Revisons: ';
    for (UnitModel revision in revisions) {
      unitString += '\n ${revision.name}, hours: ${formatDuration(revision.sessionTime)}';
    }
    logger.f(
        'Stack ${course.name} \n Session Time: ${formatDuration(course.sessionTime)} \n Exam date: ${course.examDate} \n Order matters: ${course.orderMatters} \n Weight: ${course.weight}\n $unitString');
  }

  int getDaysUntilExam(DateTime date) {
    DateTime currentDate = date;
    DateTime date2 = course.examDate;

    DateTime date1 =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    Duration difference = date2.difference(date1);

    int numberOfDays = difference.inDays;

    return numberOfDays;
  }

  void calculateWeight(DateTime date) {
    weight = course.weight + (1 / getDaysUntilExam(date));
  }

  UnitModel? getUnitForTimeSlot(Duration timeAvailable) {
    for (UnitModel unit in units) {
      if ((unit.sessionTime) <= timeAvailable) {
        return unit;
      }
      if (course.orderMatters) {
        return null;
      }
    }
  }
}
