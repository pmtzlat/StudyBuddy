import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class SchedulerStack {
  late List<UnitModel> units;
  late List<UnitModel> revisions;
  int? daysUntilExam;
  double? weight;
  ExamModel exam;
  int unitsInDay = 0;

  SchedulerStack({required this.exam});

  Future<void> initializeUnitsAndRevision(ExamModel exam) async {
    try {
      units = exam.units!.where((unit) => unit.completed == false).toList();
      revisions = exam.revisions.where((result) => result.completed == false).toList();
      daysUntilExam = getDaysUntilExam(exam.examDate);

    } catch (e) {
      logger.d('Error initializing unitsWithRevision: $e');
      units = [];
    }
  }

  

  Future<List<UnitModel>> extractUnitsWithRevision(ExamModel exam) async {
    try {
      List<UnitModel> units = [];
      final examUnits = await instanceManager.firebaseCrudService
          .getUnitsForExam(examID: exam.id);
      units += examUnits;
      logger.i('Revisons for exam ${exam.name}: ${exam.revisions}');

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
        'Stack ${exam.name} \n Session Time: ${formatDuration(exam.revisionTime)} \n Exam date: ${exam.examDate} \n Order matters: ${exam.orderMatters} \n Weight: ${exam.weight}\n $unitString');
  }

  int getDaysUntilExam(DateTime date) {
    DateTime currentDate = date;
    DateTime date2 = exam.examDate;

    DateTime date1 =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    Duration difference = date2.difference(date1);

    int numberOfDays = difference.inDays;

    return numberOfDays;
  }

  void calculateWeight(DateTime date) {
    weight = exam.weight + (1 / getDaysUntilExam(date));
  }

  UnitModel? getUnitForTimeSlot(Duration timeAvailable) {
    for (UnitModel unit in units) {
      if ((unit.sessionTime) <= timeAvailable) {
        return unit;
      }
      if (exam.orderMatters) {
        return null;
      }
    }
  }
}
