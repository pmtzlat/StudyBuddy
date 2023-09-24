import 'package:flutter/material.dart';

import '../../common_widgets/scaffold.dart';
import '../../main.dart';
import '../calendar/calendar_view.dart';

class SignInController {
  Future<void> signIn(BuildContext context) async {
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
  }
}
