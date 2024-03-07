import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/modules/sign_in/sign_in_controller.dart';
import 'package:study_buddy/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../common_widgets/scaffold.dart';
import '../../main.dart';
import '../../services/logging_service.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  bool loading = false;

  Future<bool> isLocalStorageReady() async {
    await Future.delayed(Duration(seconds: 2));

    if (instanceManager.localStorage == null) {
      return false;
    }

    return true;
  }

  final _controller = SignInController();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    var circularProgressIndicator = const CircularProgressIndicator();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 44, 44),
      body: Center(
        child: FutureBuilder<bool>(
          future: isLocalStorageReady(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == true) {
              
              return loading
                  ? circularProgressIndicator
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                children: [
                                  Text('StudyBuddy',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          letterSpacing: screenWidth * 0.025,
                                          fontFamily: 'ITCAvantGardeStd-Md'))
                                ],
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SignInButton(
                              Buttons.Google,
                              onPressed: () => _controller.signIn(context, 
                              ()async {
                                logger.i('loading to true');
                                
                                setState(() {
                                  loading = true;
                                });
                                await Future.delayed(Duration(seconds:5));
                              }
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
            }
            else{
              return circularProgressIndicator;

            }
          },
        ),
      ),
    );
  }
}
