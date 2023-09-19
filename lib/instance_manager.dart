
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/services/auth_service.dart';
import 'package:study_buddy/services/firebase_crud_service.dart';

class InstanceManager {

  
  late MyScaffold scaffold = MyScaffold();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AuthService authService = AuthService();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseCrudService firebaseCrudService = FirebaseCrudService();
  
  

  
  
}
