import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ntp/ntp.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/modules/calendar/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_buddy/modules/desync_page.dart';
import 'package:study_buddy/modules/sign_in/sign_in_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var instanceManager;
var now;
var synced;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  instanceManager = InstanceManager();
  now = await NTP.now();
  await instanceManager.startDependantInstances();

  synced =
      await instanceManager.localStorageCustomOperations.updateDateHandling();
  if (synced == 1) {
    await instanceManager.calendarController.getIncompletePreviousDays(
        DateTime.parse(instanceManager.localStorage.getString('oldDate')));
  }

  await instanceManager.examController.getAllExams();
  await instanceManager.calendarController.getGaps();
  await instanceManager.calendarController.getCustomDays();
  await instanceManager.calendarController.getCalendarDay(now);

  runApp(StudyBuddyApp());
}

class StudyBuddyApp extends StatefulWidget {
  StudyBuddyApp({super.key});

  @override
  State<StudyBuddyApp> createState() => _StudyBuddyAppState();
}

class _StudyBuddyAppState extends State<StudyBuddyApp> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  final uid = instanceManager.localStorage.getString('uid');

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    logger.i('uid found on boot: $uid');
    logger.i('Got all exams! ${instanceManager.sessionStorage.savedExams}');

    if (synced != 1) {
      return MaterialApp(
        title: 'StudyBuddy',
        home: DesyncView(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 46, 46, 46)),
          useMaterial3: true,
        ),
        supportedLocales: [Locale('es'), Locale('en')],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
      );
    }

    return  MaterialApp(
        title: 'StudyBuddy',
        home: (user != null) ? CalendarView() : SignInView(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 46, 46, 46)),
          useMaterial3: true,
        ),
        supportedLocales: [Locale('es'), Locale('en')],
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
