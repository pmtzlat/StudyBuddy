
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/modules/calendar/calendar_view.dart';
import 'package:study_buddy/modules/sign_in/sign_in_view.dart';
import 'package:study_buddy/services/logging_service.dart';

import '../../common_widgets/scaffold.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    Future.delayed(Duration(seconds: 2));
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // User is already signed in, navigate to the home screen
        Navigator.of(context).pushReplacement(fadePageRouteBuilder(CalendarView())
          
        );
        logger.i('User logged in!');
      } else {
        // User is not signed in, navigate to the sign-in screen
        Navigator.of(context).pushReplacement(fadePageRouteBuilder(CalendarView())
        );
        logger.i('User not logged in!');
      }
    } catch (e) {
      logger.e('Error checking authentication status: $e');
    }
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




