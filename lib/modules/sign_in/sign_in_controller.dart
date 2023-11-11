import 'package:flutter/material.dart';
import 'package:study_buddy/modules/calendar/calendar_view.dart';

import '../../common_widgets/scaffold.dart';
import '../../main.dart';

class SignInController {
  Future<void> signIn(BuildContext context) async {
    try {
      await instanceManager.authService.signInWithGoogle();

      await instanceManager.startDependantInstances();

      await instanceManager.courseController.getAllCourses();
      await instanceManager.calendarController.getGaps();
      await instanceManager.calendarController.getCustomDays();
      await instanceManager.calendarController.getCalendarDay(now);
      await instanceManager.localStorageCustomOperations.updateDateHandling();

      Navigator.of(context).pushReplacement(
        fadePageRouteBuilder(CalendarView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login fallido. Intentalo de nuevo.'),
        backgroundColor: const Color.fromARGB(255, 253, 96, 85),
      ));
    }
  }
}
