import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy/main.dart';

import '../../common_widgets/scaffold.dart';
import '../sign_in/sign_in_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      await GoogleSignIn().signOut(); // Sign out from Google Sign-In
      Navigator.of(context).pushReplacement(
          fadePageRouteBuilder(SignInView()) // Navigate to SignInView
          );
    } catch (e) {
      print('Error signing out: $e');
      // Handle sign-out error (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return instanceManager.scaffold.getScaffold(
      context: context,
      activeIndex: 4,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _signOut(); // Call the sign-out function
                },
                child: Text('Log Out'),
              )
            ],
          )
        ],
      ),
    );
  }
}
