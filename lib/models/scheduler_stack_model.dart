import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class SchedulerStack {
  late List<UnitModel> unitsWithRevision;
  int? daysUntilExam;
  double? weight;
  CourseModel course;

  SchedulerStack({required this.course});

  Future<void> initializeUnitsWithRevision(CourseModel course) async {
    try {
      unitsWithRevision = await extractUnitsWithRevision(course);
    } catch (e) {
      logger.e('Error initializing unitsWithRevision: $e');
      unitsWithRevision = [];
    }
  }

  Future<List<UnitModel>> extractUnitsWithRevision(CourseModel course) async {
    try {
      List<UnitModel> units = [];
      final courseUnits = await instanceManager.firebaseCrudService
          .getUnitsForCourse(courseID: course.id);
      units += courseUnits;
      logger.i('Revisons for course ${course.name}: ${course.revisions}');

      for (int x = 0; x < course.revisions; x++) {
        units.add(
            UnitModel(name: 'Revision day $x', order: courseUnits.length + x, weight: 2.0));
      }
      return units;
    } catch (e) {
      logger.e('extractUnitsWithRevision error: $e');
      return []; // Return an empty list as a default value.
    }
  }

  void print() {
    String unitString = 'Units:';
    for (UnitModel unit in unitsWithRevision) {
      unitString += '\n ${unit.name}, weight: ${unit.weight}';
    }
    logger.i(
        'Stack ${course.name} \n Order matters: ${course.orderMatters} \n $unitString');
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

  UnitModel? getUnitForTimeSlot(int timeAvailable) {
    for (UnitModel unit in unitsWithRevision) {
      if ((unit.weight * course.sessionTime) <= timeAvailable) {
        return unit;
      }
      if (course.orderMatters) {
        return null;
      }
    }
  }
}
