import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ntp/ntp.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/modules/calendar/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/modules/start_error_page.dart';
import 'package:study_buddy/modules/sign_in/sign_in_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/general_utils.dart';
import 'firebase_options.dart';

var instanceManager;
var now;
String? status = null;
late ConnectivityResult connectivityResult;
Duration timeoutDuration = Duration(seconds: 10);

void main() async {
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  connectivityResult = await (Connectivity().checkConnectivity()); //this line
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  instanceManager = InstanceManager();

  await instanceManager.startDependantInstances();
  await handleAppStart();

  runApp(StudyBuddyApp());
}

Future<bool> handleAppStart() async {
  try {
    connectivityResult = await (Connectivity().checkConnectivity()); //this line
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet ||
        connectivityResult == ConnectivityResult.mobile) {
      now = await NTP.now();
      if (!await instanceManager.localStorageCustomOperations.isCorrectDate()) {
        status = 'Sync Error';
        return false;
      }

      instanceManager.localStorageCustomOperations.updateDateHandling();
      await instanceManager.calendarController.getIncompletePreviousDays(
          DateTime.parse(instanceManager.localStorage.getString('oldDate')));

      instanceManager.sessionStorage.initialExamsLoad =
          await instanceManager.examsController.getAllExams();
      instanceManager.sessionStorage.initialGapsLoad =
          await instanceManager.calendarController.getGaps();
      instanceManager.sessionStorage.initialCustomDaysLoad =
          await instanceManager.calendarController.getCustomDays();
      instanceManager.sessionStorage.initialDayLoad =
          await instanceManager.calendarController.getCalendarDay(now);
      instanceManager.sessionStorage.savedWeekday =
          instanceManager.sessionStorage.currentDate.weekday - 1;
      instanceManager.sessionStorage.initialCalendarDaySessions =
          await instanceManager.calendarController
              .getAllCalendarDaySessionNumbers();

      instanceManager.sessionStorage.needsRecalculation =
          await instanceManager.firebaseCrudService.getNeedsRecalc();

      return true;
    } else {
      logger.i('Not connected!');
      status = 'Connection Error';

      return false;
    }
  } catch (e) {
    logger.e('Error on start: $e');
    status = 'Start Error';
    return false;
  }
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
    if (status != null) {
      logger.i('Showing not connected');
      return MaterialApp(
        title: 'StudyBuddy',
        home: StartErrorPage(
            errorMsg: status!),
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

    return GestureDetector(
      onTap: () {
        logger.i('tapped outside');
        closeKeyboard(context);
      },
      child: MaterialApp(
        title: 'StudyBuddy',
        home: (user != null) ? CalendarView() : SignInView(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 46, 46, 46)),
          useMaterial3: true,
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Colors.transparent,
          ),
        ),
        supportedLocales: [Locale('es'), Locale('en')],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
      ),
    );
  }
}
