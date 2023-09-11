import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/timer.dart';
import 'package:study_buddy/main.dart';

class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  @override
  Widget build(BuildContext context) {
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 0,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimerWidget(hours: 1, minutes: 1, seconds: 10,),
            ],
          )
        ]));
  }
}
