import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return instanceManager.scaffold.getScaffold(context: context, activeIndex: 4, 
    body:
    Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Profile')],
            )
          ],
        )
    
    );;
  }
}