import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/common_widgets/exam_card.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/general_utils.dart';

class ExamsController {
  final firebaseCrud = instanceManager.firebaseCrudService;
  final uid = instanceManager.localStorage.getString('uid') ?? '';

  

  Future<void> deleteExam(
      {required String name,
      required String id,
      required int index,
      required BuildContext context}) async {
    try {
      await firebaseCrud.deleteExam(examId: id);
      final snackbar = SnackBar(
          content:
              Text(name + AppLocalizations.of(context)!.examDeletedCorrectly),
          backgroundColor: Color.fromARGB(255, 0, 172, 6));

      instanceManager.sessionStorage.needsRecalculation = true;
      applyWeights(instanceManager.sessionStorage.activeExams);
      await updateExamWeights();

      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } catch (e) {
      logger.e('Error deleting exam: $e');
      final snackbar = SnackBar(
        content: Text(AppLocalizations.of(context)!.errorDeletingExam + name),
        backgroundColor: Color.fromARGB(255, 221, 15, 0),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<int> updateExamWeights() async {
    try {
      final exams = instanceManager.sessionStorage.activeExams;
      applyWeights(exams);

      for (ExamModel exam in exams) {
        logger.i(exam.name);
        await firebaseCrud.editExamWeight(exam);
      }
      return 1;
    } catch (e) {
      logger.e('Error updating Exam Weights: $e');
      return -1;
    }
  }

  Future<int> replaceExams(List<ExamModel> newExams) async {
    try {
      final oldExams = filterActiveExams(await firebaseCrud.getAllExams());
      

      for (ExamModel exam in oldExams) {
        await firebaseCrud.deleteExam(examId: exam.id);
      }

      for (ExamModel exam in newExams) {
        await addExam(exam);
      }
      return 1;
    } catch (e) {
      logger.e('Error updating Exam Weights: $e');
      return -1;
    }
  }

  int applyWeights(List<ExamModel> exams) {
    try {
      var weights = instanceManager.sessionStorage.examWeightArray;
      weights = generateDescendingList(exams.length);
      for (int i = 0; i < exams.length; i++) {
        exams[i].weight = weights[i];
        logger.i('New weight for exam: ${exams[i].name}: ${weights[i]}');
      }
      instanceManager.sessionStorage.activeExams
          .sort((ExamModel a, ExamModel b) => b.weight.compareTo(a.weight));
      logger.i(getActiveExamsString(null));
      return 3;
    } catch (e) {
      logger.e('Error in addExamScreen3: $e');
      return -1;
    }
  }

  int addExamScreen2(GlobalKey<FormBuilderState> unitsFormKey) {
    //returns index of page the addExam flow goes through
    // -1 = error
    // 2 = exam priority page
    // 3 = finish successfully
    try {
      List<UnitModel> units = instanceManager.sessionStorage.examToAdd.units;
      //logger.i(unitsFormKey.currentState!.fields);
      for (UnitModel unit in units) {
        unit.name = unitsFormKey
            .currentState!.fields['Unit ${unit.order} name']!.value
            .toString();
        // logger.i(
        //     'Name and time for unit ${unit.order}: ${unit.name}, ${formatDuration(unit.sessionTime)}');
      }
      if (instanceManager.sessionStorage.activeExams.isNotEmpty) {
        return 2;
      } else {
        //save exam to DB

        return 3;
      }
    } catch (e) {
      logger.e('Error addExamScreen2: $e');
      return -1;
    }
  }

  int addExamScreen1(GlobalKey<FormBuilderState> examCreationFormKey,
      Duration sessionTime, Duration revisionTime, Color examColor) {
    //returns index of page the addExam flow goes through
    // -1 = error
    // 1 = unit session page
    // 2 = exam priority page
    // 3 = finish successfully
    try {
      final examDate = DateTime.parse(examCreationFormKey
          .currentState!.fields['examDate']!.value
          .toString());

      final name = examCreationFormKey.currentState!.fields['examName']!.value
          .toString();

      // final weight =
      //     examCreationFormKey.currentState!.fields['weightSlider']!.value ??
      //         1.0;

      final int units =
          int.parse(examCreationFormKey.currentState!.fields['units']!.value) ??
              1;

      final int revisions = int.parse(
              examCreationFormKey.currentState!.fields['revisions']!.value) ??
          1;

      final bool orderMatters =
          examCreationFormKey.currentState!.fields['orderMatters']!.value ??
              false;

      //logger.i('Validation done');

      instanceManager.sessionStorage.examToAdd =
          ExamModel(name: name, examDate: examDate, orderMatters: orderMatters, color: examColor);

      instanceManager.sessionStorage.examToAdd!.units = <UnitModel>[];
      List<UnitModel> unitsList =
          instanceManager.sessionStorage.examToAdd!.units;
      for (int i = 0; i < units; i++) {
        final unitNum = i + 1;
        final newUnit = UnitModel(name: 'Unit $unitNum', order: unitNum);
        unitsList!.add(newUnit);
      }

      instanceManager.sessionStorage.examToAdd!.revisions = <UnitModel>[];
      List<UnitModel> revisionsList =
          instanceManager.sessionStorage.examToAdd!.revisions;
      for (int i = 0; i < revisions; i++) {
        final revisionNum = i + 1;
        final newRevision = UnitModel(
            name: 'Revision $revisionNum',
            order: revisionNum,
            sessionTime: revisionTime);
        revisionsList!.add(newRevision);
      }

      if (units > 0) {
        //logger.i(unitsList!.length);
        return 1;
      } else {
        if (instanceManager.sessionStorage.activeExams.isNotEmpty) {
          return 2;
        }

        //save exam to db

        return 3;
      }
    } catch (e) {
      logger.e('Error in addExamScreen1: $e');
      return -1;
    }
  }

  Future<int> handleAddExam() async {
    try {
      final exams = instanceManager.sessionStorage.activeExams;

      for (ExamModel exam in exams) {
        ExamModel? alreadyInDB = await firebaseCrud.getExam(exam.id);
        if (alreadyInDB != null) {
          //update weight
          logger.i('Exam ${exam.name} found in DB! Updating...');

          await firebaseCrud.editExamWeight(exam);
          //logger.i('Done!');
        } else {
          //add exam
          logger.i('Exam ${exam.name} not found in DB! Adding...');

          await addExam(exam);
          // logger.i('Revisions added!');
          // logger.i('Done!');
        }
      }

      return 1;
    } catch (e) {
      logger.e('Error handling add exam: $e');
      return -1;
    }
  }

  Future<void> addExam(ExamModel exam) async {
    String examID = await firebaseCrud.addExamToUser(newExam: exam);

    //logger.i('Exam added!');
    for (UnitModel unit in exam.units) {
      await firebaseCrud.addUnitToExam(newUnit: unit, examID: examID);
    }
    //logger.i('Units added!');

    for (UnitModel revision in exam.revisions) {
      await firebaseCrud.addRevisionToExam(newUnit: revision, examID: examID);
    }
  }

  Future<void> getAllExams() async {
    try {
      final exams = await firebaseCrud.getAllExams();
      logger.i('getAllexams: ${getActiveExamsString(exams)}');

      instanceManager.sessionStorage.savedExams = exams;
      instanceManager.sessionStorage.activeExams = filterActiveExams(exams);
      instanceManager.sessionStorage.pastExams = filterInactiveExams(exams);
      instanceManager.sessionStorage.activeExams
          .sort((ExamModel a, ExamModel b) => b.weight.compareTo(a.weight));
      instanceManager.sessionStorage.pastExams
          .sort((ExamModel a, ExamModel b) => b.examDate.compareTo(a.examDate));
    } catch (e) {
      logger.e('Error getting exams: $e');
    }
  }

  List<ExamModel> filterActiveExams(List<ExamModel> exams) {
    return exams.where((exam) => exam.inFuture(DateTime.now())).toList();
  }

  List<ExamModel> filterInactiveExams(List<ExamModel> exams) {
    return exams.where((exam) => exam.inPastOrPresent(DateTime.now())).toList();
  }

  void printActiveExams() {
    for (var i in instanceManager.sessionStorage.savedExams) {
      print(i.name);
    }
  }

  Future<int?> handleEditUnit(GlobalKey<FormBuilderState> unitFormKey,
      ExamModel exam, UnitModel oldUnit) async {
    if (unitFormKey.currentState!.validate()) {
      unitFormKey.currentState!.save();

      final name =
          unitFormKey.currentState!.fields['unitName']!.value.toString();
      final sessionTime = doubleToDuration(double.parse(
          unitFormKey.currentState!.fields['sessionTime']!.value.toString()));
      final completed = unitFormKey.currentState!.fields['completed']!.value;
      final completionTime;
      if (completed == false) {
        completionTime = Duration.zero;
      } else {
        completionTime = sessionTime;
      }

      final updatedUnit = UnitModel(
          name: name,
          order: oldUnit.order,
          sessionTime: sessionTime,
          completed: completed,
          completionTime: completionTime);

      dynamic res = await firebaseCrud.editUnit(
          exam: exam, unitID: oldUnit.id, updatedUnit: updatedUnit);
      if (res == 1) instanceManager.sessionStorage.needsRecalculation = true;

      return res;
    } else {
      logger.e('Error validating unit keys!');
    }
  }

  Future<int?> handleEditExam(
    GlobalKey<FormBuilderState> examFormKey,
    ExamModel exam,
  ) async {
    if (examFormKey.currentState!.validate()) {
      examFormKey.currentState!.save();
      final name =
          examFormKey.currentState!.fields['examName']!.value.toString();
      final weight = examFormKey.currentState!.fields['weightSlider']!.value;
      final sessionTime = doubleToDuration(
          double.parse(examFormKey.currentState!.fields['sessionTime']!.value));
      final examDate =
          examFormKey.currentState!.fields['examDate']!.value ?? exam.examDate;
      final orderMatters =
          examFormKey.currentState!.fields['orderMatters']!.value;
      final revisions =
          int.parse(examFormKey.currentState!.fields['revisions']!.value);

      if (examDate.isAfter(DateTime.now())) {
        final updatedExam = ExamModel(
            id: exam.id,
            name: name,
            examDate: examDate,
            weight: weight,
            sessionTime: sessionTime,
            orderMatters: orderMatters);

        var res = await firebaseCrud.editExam(updatedExam);

        if (res == 1) {
          res = await handleChangeInRevisions(revisions, exam);
          if (res == 1)
            instanceManager.sessionStorage.needsRecalculation = true;
        }
        return res;
      }
      return -2;
    } else {
      logger.e('Error validating edited exam!');
    }
  }

  Future<int> handleChangeInRevisions(int revisions, ExamModel exam) async {
    try {
      var res;
      int currentRevisions = exam.revisions.length;
      logger.i('CurrentRevisions: $currentRevisions');
      logger.i('revisions: $revisions');
      if (revisions > currentRevisions) {
        logger.i('new revisions is >= current revisions');
        while (revisions > currentRevisions) {
          currentRevisions++;
          final newUnit = UnitModel(
              name: 'Revision $currentRevisions',
              order: currentRevisions,
              sessionTime:
                  doubleToDuration((durationToDouble(exam.sessionTime) * 1.5)));
          logger.i('Adding new revision: ${newUnit.name}');
          res = await firebaseCrud.addRevisionToExam(
              newUnit: newUnit, examID: exam.id);
          if (res == null) return -1;
        }
      } else if (revisions < currentRevisions) {
        logger.i('new revisions is < current revisions');
        while (revisions < currentRevisions) {
          logger.i('Removing new revision: ${currentRevisions}');
          res = await firebaseCrud.removeRevisionFromExam(
              currentRevisions, exam.id);
          if (res == null) return -1;
          currentRevisions--;
        }
      }
      return 1;
    } catch (e) {
      logger.e('Error handling change in revisions: $e');
      return -1;
    }
  }

  Future<int> markUnitsCompletedIfInPreviousDays(DateTime date) async {
    try {
      logger.i('updating Day ${date.toString()}');
      final day = await firebaseCrud.getCalendarDayByDate(date);
      if (day == null) return 1;

      logger.i('DayID: ${day.id}');

      final List<TimeSlot> timeSlotsInDay =
          await firebaseCrud.getTimeSlotsForCalendarDay(day.id);
      logger.i(
          'Got timeSlots for day ${day.date.toString()}: ${timeSlotsInDay.length}');

      for (var timeSlot in timeSlotsInDay) {
        final unit = timeSlot.unitID;
        final exam = timeSlot.examID;
        logger.i(
            'Marking unit ${timeSlot.unitName} ${timeSlot.unitID} as complete...');
        int res = await firebaseCrud.markUnitAsComplete(exam, unit);
        if (res != 1) return -1;
        res = await firebaseCrud.markCalendarTimeSlotAsComplete(
            day.id, timeSlot.id);
        if (res != 1) return -1;

        logger.i('Unit ${timeSlot.unitName} marked as complete');
        logger.i('TimeSlot ${timeSlot.id} marked as complete');
      }

      return 1;
    } catch (e) {
      logger.e('Error marking units completed for day ${date}: $e');
      await instanceManager.localStorage.setString(
          'newDate', instanceManager.localStorage.getString('oldDate'));
      return -1;
    }
  }
}
