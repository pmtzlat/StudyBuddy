import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/timer_widget.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              TimerWidget(hours: 0, minutes: 0, seconds: 5,),
            ],
          )
        ]));
  }
}
