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
    await firebaseCrud.deleteExam(examId: id);
    final snackbar = SnackBar(
        content:
            Text(name + AppLocalizations.of(context)!.examDeletedCorrectly),
        backgroundColor: Color.fromARGB(255, 0, 172, 6));

    instanceManager.sessionStorage.setNeedsRecalc(true);
    applyWeights(instanceManager.sessionStorage.activeExams);
    await updateExamWeights();

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future<int> updateExamWeights() async {
    try {
      final exams = instanceManager.sessionStorage.activeExams;
      applyWeights(exams);

      for (ExamModel exam in exams) {
        //logger.i(exam.name);
        await firebaseCrud.editExamWeight(exam);
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
      logger.i(getStringForExams(instanceManager.sessionStorage.activeExams));
      return 3;
    } catch (e) {
      logger.e('Error in addExamScreen3: $e');
      return -1;
    }
  }

  int addExamScreen2(
      GlobalKey<FormBuilderState> unitsFormKey, BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    //returns index of page the addExam flow goes through
    // -1 = error
    // 2 = exam priority page
    // 3 = finish successfully
    try {
      List<UnitModel> units = instanceManager.sessionStorage.examToAdd.units;
      //logger.i(unitsFormKey.currentState!.fields);
      for (UnitModel unit in units) {
        unit.name = unitsFormKey.currentState!
            .fields[' ${_localizations.unit} ${unit.order} name']!.value
            .toString();
        if (unit.name == '')
          unit.name = ' ${_localizations.unit} ${unit.order}';
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

  int addExamScreen1(
      GlobalKey<FormBuilderState> examCreationFormKey,
      Duration sessionTime,
      Duration revisionTime,
      Color examColor,
      int revisions,
      BuildContext context) {
    //returns index of page the addExam flow goes through
    // -1 = error
    // 1 = unit session page
    // 2 = exam priority page
    // 3 = finish successfully
    try {
      final _localizations = AppLocalizations.of(context)!;
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

      final bool orderMatters =
          examCreationFormKey.currentState!.fields['orderMatters']!.value ??
              false;

      final bool revisionInDayBefore =
          examCreationFormKey.currentState!.fields['revisionInPreviousDay']!.value ??
              false;

      final bool sessionSplittable = examCreationFormKey
              .currentState!.fields['sessionSplittable']!.value ??
          false;

      //logger.i('Validation done');

      instanceManager.sessionStorage.examToAdd = ExamModel(
          name: name,
          examDate: examDate,
          orderMatters: orderMatters,
          sessionsSplittable: sessionSplittable,
          unitTime: sessionTime,
          revisionTime: revisionTime,
          revisionInDayBeforeExam: revisionInDayBefore,
          color: examColor);

      instanceManager.sessionStorage.examToAdd!.units = <UnitModel>[];
      List<UnitModel> unitsList =
          instanceManager.sessionStorage.examToAdd!.units;
      for (int i = 0; i < units; i++) {
        final unitNum = i + 1;
        final newUnit = UnitModel(
            name: ' ${_localizations.unit} $unitNum',
            order: unitNum,
            sessionTime: sessionTime);
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

  Future<bool> handleAddExam() async {
    try {
      final exams = instanceManager.sessionStorage.activeExams;

      for (ExamModel exam in exams) {
        ExamModel? alreadyInDB = await firebaseCrud.getExam(exam.id);

        if (alreadyInDB != null) {
          logger.i('Exam ${exam.name} found in DB! Updating...');
          await firebaseCrud.editExamWeight(exam);
        } else {
          logger.i('Exam ${exam.name} not found in DB! Adding...');
          await addExam(exam);
        }
      }

      if (!instanceManager.sessionStorage.activeExams
          .contains(instanceManager.sessionStorage.examToAdd)) {
        await addExam(instanceManager.sessionStorage.examToAdd);
      }

      return true;
    } catch (e) {
      logger.e('Error in handleAddExam: $e');
      instanceManager.sessionStorage.activeExams.removeAt(instanceManager
          .sessionStorage.activeExams
          .indexOf(instanceManager.sessionStorage.examToAdd));
      rethrow; // Rethrow the exception after logging it
    }
  }

  Future<void> addExam(ExamModel exam) async {
    late String examID;
    try {
      // List<int> numbers = [1, 2, 3];
      // print(numbers[5]);
      examID = await firebaseCrud.addExam(newExam: exam);

      if (examID != null) {
        for (UnitModel unit in exam.units) {
          await firebaseCrud.addUnitToExam(newUnit: unit, examID: examID);
        }

        for (UnitModel revision in exam.revisions) {
          await firebaseCrud.addRevisionToExam(
              newRevision: revision, examID: examID);
        }
      }
      instanceManager.sessionStorage.setNeedsRecalc(true);
    } catch (e) {
      logger.e('Error in addExam: $e');
      await firebaseCrud.deleteExam(examId: examID);
      rethrow; // Rethrow the exception after logging it
    }
  }

  Future<bool?> getAllExams() async {
    try {
      final exams = await firebaseCrud.getAllExams();

      logger.i(
          'Getting all exams... ${instanceManager.sessionStorage.gettingAllExams}');

      instanceManager.sessionStorage.savedExams = exams;
      instanceManager.sessionStorage.activeExams = filterActiveExams(exams);
      instanceManager.sessionStorage.pastExams = filterInactiveExams(exams);
      instanceManager.sessionStorage.activeExams
          .sort((ExamModel a, ExamModel b) => b.weight.compareTo(a.weight));
      instanceManager.sessionStorage.pastExams
          .sort((ExamModel a, ExamModel b) => b.examDate.compareTo(a.examDate));

      logger.i(
          'Got exams!: \n ${getStringForExams(instanceManager.sessionStorage.savedExams)}');

      return true;
    } catch (e) {
      logger.e('Error getting exams: $e');
      return false;
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

  Future<int?> handleEditExam(
      GlobalKey<FormBuilderState> examFormKey,
      ExamModel exam,
      int revisions,
      Duration revisionTime,
      Color examColor) async {
    try {
      ExamModel newExam = ExamModel.copy(exam);
      newExam.name = examFormKey.currentState!.fields['name']!.value.toString();
      newExam.revisionTime = revisionTime;
      newExam.examDate =
          examFormKey.currentState!.fields['examDate']!.value ?? exam.examDate;
      newExam.orderMatters =
          examFormKey.currentState!.fields['orderMatters']!.value;
      newExam.sessionsSplittable =
          examFormKey.currentState!.fields['sessionSplittable']!.value;
      newExam.revisionInDayBeforeExam =
          examFormKey.currentState!.fields['revisionDayBefore']!.value;
      newExam.color = examColor;

      newExam.units = List<UnitModel>.from(exam.units);

      await firebaseCrud.editExam(exam.id, newExam);

      await firebaseCrud.clearUnitsForExam(exam.id);
      for (UnitModel unit in newExam.units) {
        await firebaseCrud.addUnitToExam(newUnit: unit, examID: exam.id);
      }

      await handleChangeInRevisions(revisions, newExam);

      instanceManager.sessionStorage.activeOrAllExams = 0;

      await getAllExams();

      // return to exams page

      instanceManager.sessionStorage.setNeedsRecalc(true);
      return 1;
    } catch (e) {
      logger.e('Error handleEditExam: $e');

      await getAllExams();
      rethrow;
    }
  }

  Future<int> handleChangeInRevisions(int revisions, ExamModel exam) async {
    try {
      await firebaseCrud.clearRevisionsForExam(exam.id);
      for (int i = 0; i < revisions; i++) {
        final newUnit = UnitModel(
            name: 'Revision ${i+1}', order: i, sessionTime: exam.revisionTime);
        //logger.i('Adding new revision: ${newUnit.name}');
        await firebaseCrud.addRevisionToExam(
            newRevision: newUnit, examID: exam.id);
      }

      return 1;
    } catch (e) {
      logger.e('Error handling change in revisions: $e');
      rethrow;
    }
  }

  Future<int> markUnitsCompletedIfInPreviousDays(DateTime date) async {
    try {
      //logger.i('updating Day ${date.toString()}');
      final day = await firebaseCrud.getCalendarDayByDate(date);
      ;
      if (day == null) return 1;

      //logger.i('DayID: ${day.id}');

      final List<TimeSlotModel> timeSlotsInDay =
          await firebaseCrud.getTimeSlotsForCalendarDay(day.id);
      ;
      day.getTotalTimes();
      // logger.i(
      //     'Got timeSlots for day ${day.date.toString()}: ${timeSlotsInDay.length}');

      for (var timeSlot in timeSlotsInDay) {
        final unit = timeSlot.unitID;
        final exam = timeSlot.examID;
        // logger.i(
        //     'Marking unit ${timeSlot.unitName} ${timeSlot.unitID} as complete...');
        int res = await firebaseCrud.changeUnitCompleteness(exam, unit, true);
        ;
        if (res != 1) return -1;
        res = await firebaseCrud.markCalendarTimeSlotAsComplete(
            day.id, timeSlot.id);
        ;
        if (res != 1) return -1;

        // logger.i(' ${_localizations.unit} ${timeSlot.unitName} marked as complete');
        // logger.i('TimeSlot ${timeSlot.id} marked as complete');
      }

      return 1;
    } catch (e) {
      logger.e('Error marking units completed for day ${date}: $e');
      await instanceManager.localStorage.setString(
          'newDate', instanceManager.localStorage.getString('oldDate'));
      return -1;
    }
  }

  UnitModel? getUnitModelById(String examID, String unitID) {
    var exams = instanceManager.sessionStorage.savedExams;
    ExamModel targetExam = exams.firstWhere(
      (exam) => exam.id == examID,
      orElse: () => ExamModel(name: 'examNotFound', examDate: DateTime.now()),
    );

    if (targetExam.name != 'examNotFound') {
      UnitModel targetUnit = targetExam.units.firstWhere(
        (unit) => unit.id == unitID,
        orElse: () => UnitModel(name: 'unitNotFound', order: 0),
      );
      logger.f(targetUnit.getString());
      if (targetUnit.name != 'unitNotFound') return targetUnit;

      UnitModel targetRevision = targetExam.revisions.firstWhere(
        (unit) => unit.id == unitID,
        orElse: () => UnitModel(name: 'revisionNotFound', order: 0),
      );

      if (targetUnit.name != 'revisionNotFound') return targetRevision;
    }

    return null;
  }

  Future<void> changeUnitOrRevision(UnitModel newUnit) async {
    try {
      List<ExamModel> exams = instanceManager.sessionStorage.activeExams;
      logger.i('New Unit: ${newUnit.getString()}');

      // Variables to store indices
      int examIndex = -1;
      int unitIndex = -1;
      int revisionIndex = -1;

      // Find the exam with matching examID
      examIndex = exams.indexWhere((exam) => exam.id == newUnit.examID);

      if (examIndex != -1) {
        ExamModel exam = exams[examIndex];

        // Find the unit in exam.units with matching id
        unitIndex = exam.units.indexWhere((unit) => unit.id == newUnit.id);
        if (unitIndex != -1) {
          // If found in exam.units, replace it with newUnit
          
          exams[examIndex].units[unitIndex] = await firebaseCrud
                  .getSpecificUnit(newUnit.examID, newUnit.id, 'units') ??
              exams[examIndex].units[unitIndex];
        } else {
          // If not found in exam.units, find in exam.revisions
          revisionIndex = exam.revisions
              .indexWhere((revision) => revision.id == newUnit.id);
          if (revisionIndex != -1) {
            // If found in exam.revisions, replace it with newUnit
            logger.i('Revision found!');
            exams[examIndex].revisions[revisionIndex] = await firebaseCrud
                    .getSpecificUnit(newUnit.examID, newUnit.id, 'revisions') ??
                exams[examIndex].units[unitIndex];
          } else {
            // If not found in exam.revisions, return
            logger.i('Unit not found!');
            return;
          }
        }
      }
    } catch (e) {
      logger.e('Error setting local unit or revision: $e');
      rethrow;
    }
  }

  Color? getExamColorIfDateMatches(DateTime date) {
    List<ExamModel> exams = instanceManager.sessionStorage.savedExams;

    for (ExamModel exam in exams) {
      if (exam.examDate == date) {
        return exam.color;
      }
    }

    return null;
  }
}
