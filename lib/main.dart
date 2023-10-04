import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_buddy/modules/calendar/calendar_view.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/modules/progress/progress_view.dart';
import 'package:study_buddy/modules/loader/loader.dart';
import 'package:study_buddy/modules/profile/profile_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_buddy/modules/sign_in/sign_in_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'modules/courses/courses_view.dart';
import 'modules/timer/timer_view.dart';

var instanceManager;


void main() async {

  
    
  
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  instanceManager = InstanceManager();
  await instanceManager.startDependantInstances();

  await instanceManager.courseController.getAllCourses();
  await instanceManager.calendarController.checkIfRestraintsExist();
  
  
  

  runApp(
    StudyBuddyApp(
    
  ));
}

class StudyBuddyApp extends StatefulWidget {
  StudyBuddyApp({super.key});

  @override
  State<StudyBuddyApp> createState() => _StudyBuddyAppState();
}

class _StudyBuddyAppState extends State<StudyBuddyApp> {
  final User? user = FirebaseAuth.instance.currentUser;

  
  
  @override
  void initState(){
    super.initState();
  }

  final uid = instanceManager.localStorage.getString('uid');

  
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    logger.i('uid found on boot: $uid');
    logger.i('Got all courses! ${instanceManager.sessionStorage.activeCourses}');
  
    return MaterialApp(
      title: 'StudyBuddy',
      home: (user != null) ? CalendarView() : SignInView(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 46, 46, 46)),
        useMaterial3: true,
      ),
      supportedLocales: [
        Locale('es'),
        Locale('en')
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,

        FormBuilderLocalizations.delegate,
      ],
    );
  }

  

  
}
