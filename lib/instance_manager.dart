
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/services/auth_service.dart';
import 'package:study_buddy/services/firebase_crud_service.dart';

class InstanceManager {

  
  final MyScaffold scaffold = MyScaffold();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AuthService authService = AuthService();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseCrudService firebaseCrudService = FirebaseCrudService();
  late SharedPreferences localStorage;

  
  
  
  InstanceManager(){}


  Future<void> startLocalStorage() async{
    localStorage =  await SharedPreferences.getInstance();

  }


  
  
}
