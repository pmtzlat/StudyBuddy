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
import 'package:study_buddy/services/logging_service.dart';

class CoursesController {
  final firebaseCrud = instanceManager.firebaseCrudService;
  final uid = instanceManager.localStorage.getString('uid') ?? '';

  // addCourse({
  //   required name,
  //   weight,
  //   required examDate,
  //   color = '#0000000',
  //   sessionTime = const Duration(hours: 2),
  //   orderMatters = false,
  // }) {
  //   try {
  //     final newCourse = CourseModel(
  //       name: name,
  //       examDate: examDate,
  //       weight: weight,
  //       color: color,
  //       sessionTime: sessionTime,
  //       orderMatters: orderMatters,
  //     );
  //     instanceManager.sessionStorage.needsRecalculation = true;

  //     return firebaseCrud.addCourseToUser(newCourse: newCourse);
  //   } catch (e) {
  //     logger.e('Error in CoursesController.addCourse: $e');
  //   }
  // }

  Future<void> deleteCourse(
      {required String name,
      required String id,
      required int index,
      required BuildContext context}) async {
    final res = await firebaseCrud.deleteCourse(courseId: id);
    final snackbar = SnackBar(
      content: Text(
        res == 1
            ? name + AppLocalizations.of(context)!.courseDeletedCorrectly
            : AppLocalizations.of(context)!.errorDeletingCourse +name,
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

  // Future<int?> addUnitsToCourse(
  //     {required String id,
  //     required int units,
  //     required Duration sessionTime}) async {
  //   try {
  //     for (int i = 0; i < units; i++) {
  //       final unitNum = i + 1;
  //       final newUnit = UnitModel(
  //           name: 'Unit $unitNum', order: unitNum, sessionTime: sessionTime);
  //       await firebaseCrud.addUnitToCourse(newUnit: newUnit, courseID: id);
  //     }
  //     return 1;
  //   } catch (e) {
  //     logger.e('Error adding units: $e');
  //     return null;
  //   }
  // }

  // Future<int?> addRevisionsToCourse(
  //     {required String id,
  //     required int revisions,
  //     required Duration sessionTime}) async {
  //   try {
  //     for (int i = 0; i < revisions; i++) {
  //       final revisionNum = i + 1;
  //       final newUnit = UnitModel(
  //           name: 'Revision $revisionNum',
  //           order: revisionNum,
  //           sessionTime:
  //               doubleToDuration((durationToDouble(sessionTime) * 1.5)));
  //       await firebaseCrud.addRevisionToCourse(newUnit: newUnit, courseID: id);
  //     }
  //     return 1;
  //   } catch (e) {
  //     logger.e('Error adding units: $e');
  //     return null;
  //   }
  // }

  int addCourseScreen3() {
    try {
      final courses = instanceManager.sessionStorage.activeCourses;
      final weights = instanceManager.sessionStorage.courseWeightArray;
      logger.i(weights);
      for (int i = 0; i < courses.length; i++) {
        courses[i].weight = weights[i];
        logger.i('New weight for course: ${courses[i].name}: ${weights[i]}');
      }
      return 3;
    } catch (e) {
      logger.e('Error in addCourseScreen3: $e');
      return -1;
    }
  }

  int addCourseScreen2(GlobalKey<FormBuilderState> unitsFormKey) {
    //returns index of page the addCourse flow goes through
    // -1 = error
    // 2 = course priority page
    // 3 = finish successfully
    try {
      List<UnitModel> units = instanceManager.sessionStorage.courseToAdd.units;
      logger.i(unitsFormKey.currentState!.fields);
      for (UnitModel unit in units) {
        unit.name = unitsFormKey
            .currentState!.fields['Unit ${unit.order} name']!.value
            .toString();
        logger.i(
            'Name and time for unit ${unit.order}: ${unit.name}, ${formatDuration(unit.sessionTime)}');
      }
      if (instanceManager.sessionStorage.activeCourses.isNotEmpty) {
        return 2;
      } else {
        //save course to DB
        
        return 3;
      }
    } catch (e) {
      logger.e('Error addCourseScreen2: $e');
      return -1;
    }
  }

  int addCourseScreen1(GlobalKey<FormBuilderState> courseCreationFormKey, Duration sessionTime) {
    //returns index of page the addCourse flow goes through
    // -1 = error
    // 1 = unit session page
    // 2 = course priority page
    // 3 = finish successfully
    try {
      final examDate = DateTime.parse(courseCreationFormKey
          .currentState!.fields['examDate']!.value
          .toString());

      final name = courseCreationFormKey
          .currentState!.fields['courseName']!.value
          .toString();

      // final weight =
      //     courseCreationFormKey.currentState!.fields['weightSlider']!.value ??
      //         1.0;
      

      final Duration session =
          sessionTime;

      final int units = int.parse(
              courseCreationFormKey.currentState!.fields['units']!.value) ??
          1;

      final int revisions = int.parse(
              courseCreationFormKey.currentState!.fields['revisions']!.value) ??
          1;

      final bool orderMatters =
          courseCreationFormKey.currentState!.fields['orderMatters']!.value ??
              false;

      final bool applySessionTime = courseCreationFormKey
              .currentState!.fields['applySessionTime']!.value ??
          false;

      logger.i('Validation done');

      instanceManager.sessionStorage.courseToAdd = CourseModel(
          name: name,
          examDate: examDate,
          sessionTime: session,
          orderMatters: orderMatters);

      instanceManager.sessionStorage.courseToAdd!.units = <UnitModel>[];
      List<UnitModel> unitsList =
          instanceManager.sessionStorage.courseToAdd!.units;
      for (int i = 0; i < units; i++) {
        final unitNum = i + 1;
        final newUnit = UnitModel(
            name: 'Unit $unitNum', order: unitNum, sessionTime: session);
        unitsList!.add(newUnit);
      }

      instanceManager.sessionStorage.courseToAdd!.revisions = <UnitModel>[];
      List<UnitModel> revisionsList =
          instanceManager.sessionStorage.courseToAdd!.revisions;
      for (int i = 0; i < revisions; i++) {
        final revisionNum = i + 1;
        final newRevision = UnitModel(
            name: 'Revision $revisionNum',
            order: revisionNum,
            sessionTime: session);
        revisionsList!.add(newRevision);
      }

      if (units > 0 && !applySessionTime) {
        //logger.i(unitsList!.length);
        return 1;
      } else {
        if (instanceManager.sessionStorage.activeCourses.isNotEmpty) {
          return 2;
        }

        //save course to db

        return 3;
      }
    } catch (e) {
      logger.e('Error in addCourseScreen1: $e');
      return -1;
    }
  }

  Future<int> handleAddCourse() async {
    try {
      final courses = instanceManager.sessionStorage.activeCourses;
      final unitsForNewCourse =
          instanceManager.sessionStorage.courseToAdd.units;

      for (CourseModel course in courses) {
        CourseModel? alreadyInDB = await firebaseCrud.getCourse(course.id);
        if (alreadyInDB != null) {
          //update weight
          logger.i('Course ${course.name} found in DB! Updating...');

          await firebaseCrud.editCourseWeight(course);
          logger.i('Done!');

        } else {
          //add course
          logger.i('Course ${course.name} not found in DB! Adding...');

          String courseID =
              await firebaseCrud.addCourseToUser(newCourse: course);

          logger.i('Course added!');
          for (UnitModel unit in unitsForNewCourse) {
            await firebaseCrud.addUnitToCourse(
                newUnit: unit, courseID: courseID);
          }
          logger.i('Units added!');

          for (UnitModel revision in course.revisions) {
            await firebaseCrud.addRevisionToCourse(
                newUnit: revision, courseID: courseID);
          }
          logger.i('Revisions added!');
          logger.i('Done!');
        }
      }

      

      return 1;
    } catch (e) {
      logger.e('Error handling add course: $e');
      return -1;
    }
  }

  Future<void> getAllCourses() async {
    try {
      final courses = await firebaseCrud.getAllCourses();

      instanceManager.sessionStorage.savedCourses = courses;
      instanceManager.sessionStorage.activeCourses =
          filterActiveCourses(courses);
      instanceManager.sessionStorage.activeCourses
          .sort((CourseModel a, CourseModel b) => b.weight.compareTo(a.weight));
      instanceManager.sessionStorage.savedCourses
          .sort((CourseModel a, CourseModel b) => b.examDate.compareTo(a.examDate));
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
      } else if (revisions < currentRevisions) {
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
