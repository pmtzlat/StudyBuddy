import 'package:flutter/material.dart';
import 'package:study_buddy/modules/calendar/calendar_view.dart';

import '../../common_widgets/scaffold.dart';
import '../../main.dart';

class SignInController {
  Future<void> signIn(BuildContext context, Function updateParent) async {
    try {
      await instanceManager.authService.signInWithGoogle();
      await updateParent();
      if (await handleAppStart()!= true) throw Exception('Error handling app start');
      
      Navigator.of(context).pushReplacement(
        fadePageRouteBuilder(CalendarView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login fallido. Intentalo de nuevo.'),
        backgroundColor: const Color.fromARGB(255, 253, 96, 85),
      ));
    }
  }
}
