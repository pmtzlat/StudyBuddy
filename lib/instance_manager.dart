
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/modules/calendar/controllers/calendar_controller.dart';
import 'package:study_buddy/modules/calendar/controllers/study_planner.dart';
import 'package:study_buddy/services/auth_service.dart';
import 'package:study_buddy/services/firebase_crud_service.dart';
import 'package:study_buddy/services/local_storage_service.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/session_storage.dart';

import 'modules/exams/controllers/exams_controller.dart';

class InstanceManager {


  final MyScaffold scaffold = MyScaffold();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AuthService authService = AuthService();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseCrudService firebaseCrudService = FirebaseCrudService();
  late SharedPreferences localStorage;
  final connectivity = Connectivity();
  late ExamsController examController;
  late CalendarController calendarController;
  late StudyPlanner studyPlanner;
  late LocalStorageService localStorageCustomOperations;
  final SessionStorage sessionStorage = SessionStorage();

  
  
  
  InstanceManager(){}


  Future<void> startDependantInstances() async{
    localStorage =  await SharedPreferences.getInstance();
    examController = ExamsController();
    calendarController = CalendarController();
    studyPlanner = StudyPlanner(firebaseCrud: firebaseCrudService, uid: localStorage.getString('uid') ?? '');
    localStorageCustomOperations = LocalStorageService(localStorage: localStorage);



  }


  
  
}
