
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/modules/calendar/calendar_controller.dart';
import 'package:study_buddy/modules/calendar/study_planner.dart';
import 'package:study_buddy/services/auth_service.dart';
import 'package:study_buddy/services/firebase_crud_service.dart';
import 'package:study_buddy/session_storage.dart';

import 'modules/courses/courses_controller.dart';

class InstanceManager {

  
  final MyScaffold scaffold = MyScaffold();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AuthService authService = AuthService();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseCrudService firebaseCrudService = FirebaseCrudService();
  late SharedPreferences localStorage;
  final connectivity = Connectivity();
  late CoursesController courseController;
  late CalendarController calendarController;
  late StudyPlanner studyPlanner;
  final sessionStorage = SessionStorage();

  
  
  
  InstanceManager(){}


  Future<void> startDependantInstances() async{
    localStorage =  await SharedPreferences.getInstance();
    courseController = CoursesController();
    calendarController = CalendarController();
    studyPlanner = StudyPlanner(firebaseCrud: firebaseCrudService, uid: localStorage.getString('uid') ?? '');

  }


  
  
}
