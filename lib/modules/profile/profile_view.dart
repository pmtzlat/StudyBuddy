import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/modules/profile/profile_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common_widgets/scaffold.dart';
import '../sign_in/sign_in_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _controller = ProfileController();

  

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
                  _controller.signOut(context); // Call the sign-out function
                },
                child: Text(AppLocalizations.of(context)!.logOut),
              )
            ],
          )
        ],
      ),
    );
  }
}
