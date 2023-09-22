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
/*
class _SignInViewState extends State<SignInView> {

  bool isLocalStorageReady(){

    if(instanceManager.localStorage == null) isLocalStorageReady();

    return true;
  }

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
                onPressed: () async {
                  try {
                    await instanceManager.authService.signInWithGoogle();

                    Navigator.of(context).pushReplacement(fadePageRouteBuilder(
                            CalendarView()) // Navigate to SignInView
                        );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Login fallido. Intentalo de nuevo.'),
                    ));
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
*/

class _SignInViewState extends State<SignInView> {
  Future<bool> isLocalStorageReady() async {
    // Simulate a delay, you should replace this with your actual initialization logic
    await Future.delayed(Duration(seconds: 2));

    // Replace this condition with your actual logic to check if local storage is ready
    if (instanceManager.localStorage == null) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 44, 44),
      body: Center(
        child: FutureBuilder<bool>(
          future: isLocalStorageReady(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for the future to complete, show a loading indicator
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // If there was an error, display an error message
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == true) {
              // If local storage is ready, show your content
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SignInButton(
                        Buttons.Google,
                        onPressed: () async {
                          try {
                            await instanceManager.authService.signInWithGoogle();

                            Navigator.of(context).pushReplacement(
                              fadePageRouteBuilder(CalendarView()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Login fallido. Intentalo de nuevo.'),
                            ));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            } else {
              // If local storage is not ready yet, you can show a different loading indicator or message
              return CircularProgressIndicator(); // Replace with your preferred loading indicator
            }
          },
        ),
      ),
    );
  }
}