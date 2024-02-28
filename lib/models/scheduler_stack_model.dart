import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class SchedulerStackModel {
  late List<UnitModel> units;
  late List<UnitModel> revisions;
  int? daysUntilExam;
  double weight = 1.0;
  ExamModel exam ;
  int unitsInDay = 0;
  bool revisionNeedsToBePutInDayBefore = false;

  SchedulerStackModel({required this.exam});

  Future<void> intializeDependantParameters(ExamModel exam, DateTime date) async {
    try {
      units = exam.units
          .where((unit) => !unit.completed)
          .map((unit) => unit.deepCopy())
          .toList();

      revisions = exam.revisions.map((unit) => unit.deepCopy()).toList();
      daysUntilExam = getDaysUntilExam(date);
      revisionNeedsToBePutInDayBefore = exam.revisionInDayBeforeExam;
      weight = exam.weight;

    } catch (e) {
      logger.e('Error initializing unitsWithRevision: $e');
      units = [];
    }
  }

  void print() {
    String unitString = 'Units:';
    for (UnitModel unit in units) {
      unitString +=
          '\n ${unit.name}, hours: ${formatDuration(unit.sessionTime)}';
    }
    unitString += '\n Revisons: ';
    for (UnitModel revision in revisions) {
      unitString +=
          '\n ${revision.name}, hours: ${formatDuration(revision.sessionTime)}';
    }
    logger.f(
        'Stack ${exam.name} \n Session Time: ${formatDuration(exam.revisionTime)} \n Exam date: ${exam.examDate} \n Order matters: ${exam.orderMatters} \n Weight: ${exam.weight}\n $unitString');
  }

  SchedulerStackModel customDeepCopy() {

    SchedulerStackModel newStack = SchedulerStackModel(exam: exam);
    newStack.units = units;
    newStack.revisions = revisions;
    newStack.daysUntilExam = daysUntilExam;
    newStack.weight = weight;
    
    newStack.unitsInDay = unitsInDay;
    newStack.revisionNeedsToBePutInDayBefore = revisionNeedsToBePutInDayBefore;
    return newStack;
  }

  String getString() {
    String unitString = 'Units:';
    for (UnitModel unit in units) {
      unitString +=
          '\n ${unit.name}, hours: ${formatDuration(unit.sessionTime)}';
    }
    unitString += '\n Revisons: ';
    for (UnitModel revision in revisions) {
      unitString +=
          '\n ${revision.name}, hours: ${formatDuration(revision.sessionTime)}';
    }
    return 'Stack ${exam.name} \n Session Time: ${formatDuration(exam.revisionTime)} \n Exam date: ${exam.examDate} \n Order matters: ${exam.orderMatters} \n Weight: ${weight}\n $unitString\nUnits in day: $unitsInDay';
  }

  int getDaysUntilExam(DateTime date) {
    
    
    Duration difference = exam.examDate.difference(date);
    //logger.i('${exam.examDate} , $date : $difference');

    int numberOfDays = difference.inDays;
     //logger.i(numberOfDays);

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
