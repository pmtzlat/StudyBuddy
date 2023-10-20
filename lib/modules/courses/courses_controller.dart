import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/common_widgets/course_card.dart';
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
      orderMatters = false,
      revisions = 2}) {
    try {
      final newCourse = CourseModel(
          name: name,
          examDate: examDate,
          weight: weight,
          secondsStudied: secondsStudied,
          color: color,
          sessionTime: sessionTime,
          orderMatters: orderMatters,
          revisions: revisions);

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
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  dynamic addUnitsToCourse(
      {required String id, required int units, required int sessionTime}) {
    try {
      for (int i = 0; i < units; i++) {
        final unitNum = i + 1;
        final newUnit = UnitModel(
            name: 'Unit $unitNum', order: unitNum, hours: sessionTime);
        firebaseCrud.addUnitToCourse(newUnit: newUnit, courseID: id);
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
        final session = int.parse(courseCreationFormKey
                .currentState!.fields['sessionTime']!.value) *
            3600;

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
            revisions: revisions);

        if (res != null) {
          res = await addUnitsToCourse(
              id: res, units: units, sessionTime: session);
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
      final hours = int.parse(unitFormKey.currentState!.fields['hours']!.value);

      final updatedUnit =
          UnitModel(name: name, order: oldUnit.order, hours: hours * 3600);

      dynamic res = await firebaseCrud.editUnit(
          course: course, unitID: oldUnit.id, updatedUnit: updatedUnit);

      return res;
    } else {
      logger.e('Error validating unit keys!');
    }
  }

  Future<int?> handleEditCourse(
      GlobalKey<FormBuilderState> courseFormKey, CourseModel course, ) async {
    
      if (courseFormKey.currentState!.validate()) {
        courseFormKey.currentState!.save();
        final name =
            courseFormKey.currentState!.fields['courseName']!.value.toString();
        final weight =
            courseFormKey.currentState!.fields['weightSlider']!.value;
        final sessionTime =
            int.parse(courseFormKey.currentState!.fields['sessionTime']!.value);
        final examDate = courseFormKey.currentState!.fields['examDate']!.value ?? course.examDate;
        final orderMatters =
            courseFormKey.currentState!.fields['orderMatters']!.value;
        final revisions =
            int.parse(courseFormKey.currentState!.fields['revisions']!.value);

        if(examDate.isAfter(DateTime.now())){
        final updatedCourse = CourseModel(
            id: course.id,
            name: name,
            examDate: examDate,
            weight: weight,
            sessionTime: sessionTime*3600,
            orderMatters: orderMatters,
            revisions: revisions);
        


        final res = await firebaseCrud.editCourse(updatedCourse);
        return res;
        }
        return -2;



      } else {
        logger.e('Error validating edited course!');
      }
    
  }
}
