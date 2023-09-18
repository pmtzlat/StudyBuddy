
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';

class InstanceManager {
  late MyScaffold scaffold = MyScaffold();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  
  

  
  
}
