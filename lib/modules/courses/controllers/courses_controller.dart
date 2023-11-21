import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/common_widgets/course_card.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/unit_model.dart';
import '../../../services/logging_service.dart';

class CoursesController {
  final firebaseCrud = instanceManager.firebaseCrudService;
  final uid = instanceManager.localStorage.getString('uid') ?? '';

  addCourse({
    required name,
    weight,
    required examDate,
    color = '#0000000',
    sessionTime = const Duration(hours: 2),
    orderMatters = false,
  }) {
    try {
      final newCourse = CourseModel(
        name: name,
        examDate: examDate,
        weight: weight,
        color: color,
        sessionTime: sessionTime,
        orderMatters: orderMatters,
      );
      instanceManager.sessionStorage.needsRecalculation = true;

      return firebaseCrud.addCourseToUser(newCourse: newCourse);
    } catch (e) {
      logger.e('Error in CoursesController.addCourse: $e');
    }
  }

  Future<void> deleteCourse(
      {required String id,
      required int index,
      required BuildContext context}) async {
    final res = await firebaseCrud.deleteCourse(courseId: id);
    final snackbar = SnackBar(
      content: Text(
        res == 1
            ? AppLocalizations.of(context)!.courseDeletedCorrectly
            : AppLocalizations.of(context)!.errorDeletingCourse,
      ),
      backgroundColor: res == 1
          ? Color.fromARGB(255, 0, 172, 6)
          : Color.fromARGB(255, 221, 15, 0),
    );
    if (res == 1) {
      instanceManager.sessionStorage.needsRecalculation = true;
    }
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future<int?> addUnitsToCourse(
      {required String id,
      required int units,
      required Duration sessionTime}) async {
    try {
      for (int i = 0; i < units; i++) {
        final unitNum = i + 1;
        final newUnit = UnitModel(
            name: 'Unit $unitNum', order: unitNum, sessionTime: sessionTime);
        await firebaseCrud.addUnitToCourse(newUnit: newUnit, courseID: id);
      }
      return 1;
    } catch (e) {
      logger.e('Error adding units: $e');
      return null;
    }
  }

  Future<int?> addRevisionsToCourse(
      {required String id,
      required int revisions,
      required Duration sessionTime}) async {
    try {
      for (int i = 0; i < revisions; i++) {
        final revisionNum = i + 1;
        final newUnit = UnitModel(
            name: 'Revision $revisionNum',
            order: revisionNum,
            sessionTime:
                doubleToDuration((durationToDouble(sessionTime) * 1.5)));
        await firebaseCrud.addRevisionToCourse(newUnit: newUnit, courseID: id);
      }
      return 1;
    } catch (e) {
      logger.e('Error adding units: $e');
      return null;
    }
  }

  Future<int?> handleAddCourse(
      GlobalKey<FormBuilderState> courseCreationFormKey,
      BuildContext context) async {
    int? res;
    try {
      if (courseCreationFormKey.currentState!.validate()) {
        courseCreationFormKey.currentState!.save();
        dynamic snackbar;
        final examDate = DateTime.parse(courseCreationFormKey
            .currentState!.fields['examDate']!.value
            .toString());

        if (examDate.isAfter(DateTime.now())) {
          final name = courseCreationFormKey
              .currentState!.fields['courseName']!.value
              .toString();

          final weight =
              courseCreationFormKey.currentState!.fields['weightSlider']!.value;
          final session = doubleToDuration(double.parse(courseCreationFormKey
              .currentState!.fields['sessionTime']!.value));

          final int units = int.parse(
              courseCreationFormKey.currentState!.fields['units']!.value);

          final int revisions = int.parse(
              courseCreationFormKey.currentState!.fields['revisions']!.value);

          final bool orderMatters =
              courseCreationFormKey.currentState!.fields['orderMatters']!.value;

          dynamic res = await addCourse(
            name: name,
            examDate: examDate,
            weight: weight,
            sessionTime: session,
            orderMatters: orderMatters,
          );

          int? unitsAdded = 0;
          if (res != null) {
            unitsAdded = await addUnitsToCourse(
                id: res, units: units, sessionTime: session);
          }

          int? revisionsAdded = 0;

          if (unitsAdded != null) {
            revisionsAdded = await addRevisionsToCourse(
                id: res, revisions: revisions, sessionTime: session);
          }

          // Close the bottom sheet
          Navigator.of(context).pop();

          // Show a snackbar based on the value of 'res'
          snackbar = SnackBar(
            content: Text(
              revisionsAdded != null
                  ? AppLocalizations.of(context)!.courseAddedCorrectly
                  : AppLocalizations.of(context)!.errorAddingCourse,
            ),
            backgroundColor: revisionsAdded != null
                ? Color.fromARGB(255, 0, 172, 6)
                : Color.fromARGB(255, 221, 15, 0),
          );
          if (revisionsAdded != null)
            instanceManager.sessionStorage.needsRecalculation = true;
        } else {
          // Close the bottom sheet
          Navigator.of(context).pop();

          snackbar = SnackBar(
            content: Text(AppLocalizations.of(context)!.wrongDates),
            backgroundColor: Color.fromARGB(255, 221, 15, 0),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        return res;
      } else {
        logger.e("Error validating fields!");
      }
    } catch (e) {
      logger.e('Error handling add course: $e');
    }
  }

  Future<void> getAllCourses() async {
    try {
      final courses = await firebaseCrud.getAllCourses();

      instanceManager.sessionStorage.savedCourses = courses;
      instanceManager.sessionStorage.activeCourses =
          filterActiveCourses(courses);
    } catch (e) {
      logger.e('Error getting courses: $e');
    }
  }

  List<CourseModel> filterActiveCourses(List<CourseModel> courses) {
    return courses.where((course) => course.inFuture(DateTime.now())).toList();
  }

  void printActiveCourses() {
    for (var i in instanceManager.sessionStorage.savedCourses) {
      print(i.name);
    }
  }

  Future<int?> handleEditUnit(GlobalKey<FormBuilderState> unitFormKey,
      CourseModel course, UnitModel oldUnit) async {
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
          course: course, unitID: oldUnit.id, updatedUnit: updatedUnit);
      if (res == 1) instanceManager.sessionStorage.needsRecalculation = true;

      return res;
    } else {
      logger.e('Error validating unit keys!');
    }
  }

  Future<int?> handleEditCourse(
    GlobalKey<FormBuilderState> courseFormKey,
    CourseModel course,
  ) async {
    if (courseFormKey.currentState!.validate()) {
      courseFormKey.currentState!.save();
      final name =
          courseFormKey.currentState!.fields['courseName']!.value.toString();
      final weight = courseFormKey.currentState!.fields['weightSlider']!.value;
      final sessionTime = doubleToDuration(double.parse(
          courseFormKey.currentState!.fields['sessionTime']!.value));
      final examDate = courseFormKey.currentState!.fields['examDate']!.value ??
          course.examDate;
      final orderMatters =
          courseFormKey.currentState!.fields['orderMatters']!.value;
      final revisions =
          int.parse(courseFormKey.currentState!.fields['revisions']!.value);

      if (examDate.isAfter(DateTime.now())) {
        final updatedCourse = CourseModel(
            id: course.id,
            name: name,
            examDate: examDate,
            weight: weight,
            sessionTime: sessionTime,
            orderMatters: orderMatters);

        var res = await firebaseCrud.editCourse(updatedCourse);

        if (res == 1) {
          res = await handleChangeInRevisions(revisions, course);
          if (res == 1)
            instanceManager.sessionStorage.needsRecalculation = true;
        }
        return res;
      }
      return -2;
    } else {
      logger.e('Error validating edited course!');
    }
  }

  Future<int> handleChangeInRevisions(int revisions, CourseModel course) async {
    try {
      var res;
      int currentRevisions = course.revisions.length;
      logger.i('CurrentRevisions: $currentRevisions');
      logger.i('revisions: $revisions');
      if (revisions > currentRevisions) {
        logger.i('new revisions is >= current revisions');
        while (revisions > currentRevisions) {
          currentRevisions++;
          final newUnit = UnitModel(
              name: 'Revision $currentRevisions',
              order: currentRevisions,
              sessionTime: doubleToDuration(
                  (durationToDouble(course.sessionTime) * 1.5)));
          logger.i('Adding new revision: ${newUnit.name}');
          res = await firebaseCrud.addRevisionToCourse(
              newUnit: newUnit, courseID: course.id);
          if (res == null) return -1;
          
        }
      }

      else if (revisions < currentRevisions) {
        logger.i('new revisions is < current revisions');
        while (revisions < currentRevisions) {
          logger.i('Removing new revision: ${currentRevisions}');
          res = await firebaseCrud.removeRevisionFromCourse(
              currentRevisions, course.id);
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
        final course = timeSlot.courseID;
        logger.i(
            'Marking unit ${timeSlot.unitName} ${timeSlot.unitID} as complete...');
        int res = await firebaseCrud.markUnitAsComplete(course, unit);
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
