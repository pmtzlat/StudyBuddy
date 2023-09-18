import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:study_buddy/modules/calendar/calendarView.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/modules/graphs/graphsView.dart';
import 'package:study_buddy/modules/loader/loader.dart';
import 'package:study_buddy/modules/profile/profileView.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'modules/courses/coursesView.dart';
import 'modules/timer/timerView.dart';

var instanceManager;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  instanceManager = Instancemanager();
  

  

  runApp(StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  StudyBuddyApp({super.key});
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'StudyBuddy',
      home: LoadingScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 46, 46, 46)),
        useMaterial3: true,
      ),
    );
  }
}
