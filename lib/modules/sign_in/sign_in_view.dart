import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/modules/calendar/calendarView.dart';
import 'package:study_buddy/services/auth_service.dart';

import '../../common_widgets/scaffold.dart';
import '../../main.dart';
import '../../services/logging_service.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 44, 44),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SignInButton(
                Buttons.Google,
                onPressed: () async{
                  await instanceManager.authService.signInWithGoogle();
                  
                  Navigator.of(context).pushReplacement(fadePageRouteBuilder(
                          CalendarView()) // Navigate to SignInView
                      );
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

