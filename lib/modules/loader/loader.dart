import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_buddy/modules/calendar/calendarView.dart';
import 'package:study_buddy/modules/sign_in/sign_in_view.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // Simulate a delay for 2 seconds
    Timer(Duration(seconds: 2), () {
      // Perform your condition check here
      bool conditionMet = true; // Change this to your actual condition

      if (conditionMet) {
        // Navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
