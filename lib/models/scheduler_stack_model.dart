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
      units = await extractUnitsWithRevision(course);
      revisions = createRevisions(course);
    } catch (e) {
      logger.d('Error initializing unitsWithRevision: $e');
      units = [];
    }
  }

  List<UnitModel> createRevisions(CourseModel course) {
    List<UnitModel> revisions = [];

    for (int x = 0; x < course.revisions; x++) {
      revisions
          .add(UnitModel(name: 'Revision session $x', order: x, hours: course.sessionTime));
    }
    return revisions;
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
      unitString += '\n ${unit.name}, hours: ${unit.hours/3600}';
    }
    unitString += '\n Revisons: ';
    for (UnitModel revision in revisions) {
      unitString += '\n ${revision.name}, hours: ${revision.hours/3600}';
    }
    logger.f(
        'Stack ${course.name} \n Session Time: ${course.sessionTime / 3600} \n Exam date: ${course.examDate} \n Order matters: ${course.orderMatters} \n Weight: ${course.weight}\n $unitString');
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
    for (UnitModel unit in units) {
      if ((unit.hours/3600) <= timeAvailable) {
        return unit;
      }
      if (course.orderMatters) {
        return null;
      }
    }
  }
}
