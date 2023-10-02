import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/unit_model.dart';
import '../../services/logging_service.dart';

class CoursesController {
  final firebaseCrud = instanceManager.firebaseCrudService;
  final uid = instanceManager.localStorage.getString('uid') ?? '';

  addCourse(
      {required name,
      weight,
      required examDate,
      secondsStudied = 0,
      color = '#0000000',
      sessionTime = 3600,
      startStudy = ''}) {
    try {
      final newCourse = CourseModel(
          name: name,
          examDate: examDate,
          weight: weight,
          secondsStudied: secondsStudied,
          color: color,
          sessionTime: sessionTime,
          startStudy: startStudy);

      return firebaseCrud.addCourseToUser(uid: uid, newCourse: newCourse);
    } catch (e) {
      logger.e('Error in CoursesController.addCourse: $e');
    }
  }

  Future<void> deleteCourse(
      {required String id,
      required int index,
      required BuildContext context}) async {
    final res = await firebaseCrud.deleteCourse(courseId: id);
    instanceManager.sessionStorage.savedCourses.removeAt(index);
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
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  dynamic addUnitsToCourse({required String id, required int units}) {
    try {
      for (int i = 0; i < units; i++) {
        final unitNum = i + 1;
        final newUnit = UnitModel(name: 'Unit $unitNum', order: unitNum);
        firebaseCrud.addUnitToCourse(newUnit: newUnit, courseID: id);
      }
      return 1;
    } catch (e) {
      logger.e('Error adding units: $e');
      return null;
    }
  }

  Future<int?> handleFormSubmission(
      GlobalKey<FormBuilderState> courseCreationFormKey,
      BuildContext context) async {
    int? res;
    if (courseCreationFormKey.currentState!.validate()) {
      courseCreationFormKey.currentState!.save();
      dynamic snackbar;
      final examDate = DateTime.parse(courseCreationFormKey
          .currentState!.fields['examDate']!.value
          .toString());
      final startStudy = DateTime.parse(courseCreationFormKey
          .currentState!.fields['startStudy']!.value
          .toString());
      if (examDate.isAfter(startStudy)) {
        final name = courseCreationFormKey
            .currentState!.fields['courseName']!.value
            .toString();

        final weight =
            courseCreationFormKey.currentState!.fields['weightSlider']!.value;
        final session = int.parse(courseCreationFormKey
                .currentState!.fields['sessionTime']!.value) *
            3600;

        final int units = int.parse(
            courseCreationFormKey.currentState!.fields['units']!.value);

        dynamic res = await addCourse(
            name: name,
            examDate: examDate,
            weight: weight,
            sessionTime: session,
            startStudy: startStudy);

        if (res != null) {
          res = await addUnitsToCourse(id: res, units: units);
        }

        // Close the bottom sheet
        Navigator.of(context).pop();

        // Show a snackbar based on the value of 'res'
        snackbar = SnackBar(
          content: Text(
            res != null
                ? AppLocalizations.of(context)!.courseAddedCorrectly
                : AppLocalizations.of(context)!.errorAddingCourse,
          ),
          backgroundColor: res != null
              ? Color.fromARGB(255, 0, 172, 6)
              : Color.fromARGB(255, 221, 15, 0),
        );
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
  }

  Future<void> getAllCourses() async {
    try {
      final courses = await firebaseCrud.getAllCourses(uid: uid);

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

  Future<void> handleEditUnit(GlobalKey<FormBuilderState> unitFormKey,
      CourseModel course, UnitModel oldUnit) async {
    if (unitFormKey.currentState!.validate()) {
      unitFormKey.currentState!.save();

      final name =
          unitFormKey.currentState!.fields['unitName']!.value.toString();
      final weight = unitFormKey.currentState!.fields['weightSlider']!.value;

      final updatedUnit =
          UnitModel(name: name, order: oldUnit.order, weight: weight);

      dynamic res = await firebaseCrud.editUnit(
          course: course, unitID: oldUnit.id, updatedUnit: updatedUnit);
      
    } else {
      logger.e('Error validating unit keys!');
    }
  }
}
