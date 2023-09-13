import 'package:flutter/material.dart';
import 'package:study_buddy/modules/calendar/calendarView.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/modules/graphs/graphsView.dart';
import 'package:study_buddy/modules/profile/profileView.dart';
import 'package:study_buddy/modules/loader/loader_view.dart';
import 'modules/courses/coursesView.dart';
import 'modules/timer/timerView.dart';

var instanceManager;

void main() async {
  instanceManager = Instancemanager();

  runApp(StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  StudyBuddyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 46, 46, 46)),
        useMaterial3: true,
      ),
      title: 'StudyBuddy',
      home: FutureBuilder(
        future:
            performBackgroundLogic(), // Call your background logic function here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Background logic has completed, navigate to the homepage
            return CalendarView();
          } else {
            // Show the loading screen while waiting for background logic
            return LoaderView();
          }
        },
      ),
    );
  }
}

Future<void> performBackgroundLogic() async {
  // Your background logic here
  await Future.delayed(Duration(seconds: 3)); // Simulate a delay
}
