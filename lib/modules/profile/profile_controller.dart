import 'package:flutter/material.dart';

import '../../common_widgets/scaffold.dart';
import '../../main.dart';
import '../../services/logging_service.dart';
import '../sign_in/sign_in_view.dart';

class ProfileController{

  Future<void> signOut(BuildContext context) async {
    try {
      await instanceManager.authService.signOut();

      Navigator.of(context).pushReplacement(
          fadePageRouteBuilder(SignInView()) // Navigate to SignInView
          );
    } catch (e) {
      logger.i('Error signing out: $e');
      // Handle sign-out error (e.g., show an error message)
    }
  }


}