import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/logging_service.dart';

class CoursesController {
  addCourse({
    required name,
    weight,
    required examDate,
    secondsStudied = 0,
    color = '#0000000',
    sessionTime = 3600,
  }) {
    try {
      final newCourse = CourseModel(
          name: name,
          examDate: examDate,
          weight: weight,
          secondsStudied: secondsStudied,
          color: color,
          sessionTime: sessionTime);
      final firebaseCrud = instanceManager.firebaseCrudService;
      final uid = instanceManager.localStorage.getString('uid') ?? '';

      return firebaseCrud.addCourseToUser(uid: uid, newCourse: newCourse);
    } catch (e) {
      logger.e('Error in CoursesController.addCourse: $e');
    }
  }

  Future<void> handleFormSubmission(
      GlobalKey<FormBuilderState> courseCreationFormKey,
      BuildContext context) async {
    if (courseCreationFormKey.currentState!.validate()) {
      courseCreationFormKey.currentState!.save();
      final name = courseCreationFormKey
          .currentState!.fields['courseName']!.value
          .toString();
      final examDate = courseCreationFormKey
          .currentState!.fields['examDate']!.value
          .toString();
      final weight =
          courseCreationFormKey.currentState!.fields['weightSlider']!.value;
      final session =
          int.parse(courseCreationFormKey.currentState!.fields['sessionTime']!.value)*3600;

      final res =
          await addCourse(name: name, examDate: examDate, weight: weight, sessionTime: session);
      logger.i(res);

      // Close the bottom sheet
      Navigator.of(context).pop();

      // Show a snackbar based on the value of 'res'
      final snackbar = SnackBar(
        content: Text(
          res == 1
              ? AppLocalizations.of(context)!.courseAddedCorrectly
              : AppLocalizations.of(context)!.errorAddingCourse,
        ),
        backgroundColor: res == 1
            ? Color.fromARGB(255, 0, 172, 6)
            : Color.fromARGB(255, 221, 15, 0),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } else {
      logger.e("Error validating fields!");
    }
  }
}
