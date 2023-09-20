import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/models/user_model.dart';

class AuthService {
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser =
        await instanceManager.googleSignIn.signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential).then(
      (value) {
        instanceManager.db
            .collection('users')
            .doc(value.user!.uid)
            .set(UserModel(uid: value.user!.uid).toJSON());
        instanceManager.localStorage.setString('uid', value.user!.uid);
        logger.i(
            'Saved the uid to localstorage! uid: ${instanceManager.localStorage.getString('uid')}');
      },
    ).catchError((err) => logger.e('Error saving to firebase: $err'));
  }

  Future<void> signOut() async {
    instanceManager.localStorage.setString('uid', '');
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    await instanceManager.googleSignIn
        .signOut(); // Sign out from Google Sign-In
  }
}
