import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/pause_play_button.dart';
import 'package:study_buddy/services/logging_service.dart';

class TimerWidget extends StatefulWidget {
  final int hours;
  final int minutes;
  final int seconds;
  Duration timerTime;

  TimerWidget({super.key, this.hours = 0, this.minutes = 0, this.seconds = 0})
      : timerTime = Duration(hours: hours, minutes: minutes, seconds: seconds);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  bool play = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int hoursShown = widget.timerTime.inHours % 23;
    int minutesShown =
        (widget.timerTime.inMinutes - Duration(hours: hoursShown).inMinutes) %
            60;
    int secondsShown = (widget.timerTime.inSeconds -
            Duration(hours: hoursShown, minutes: minutesShown).inSeconds) %
        60;
    return Column(
      children: [
        Text('${hoursShown < 10 ? '0${hoursShown}' : hoursShown} : '
            '${minutesShown < 10 ? '0${minutesShown}' : minutesShown} : '
            '${secondsShown < 10 ? '0${secondsShown}' : secondsShown}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                IconButton(
                    onPressed: play
                        ? () {
                          logger.i('Pressed play!');
                            startTimer();
                            setState(() {
                              play = false;
                            });
                          }
                        : () {
                            logger.i('Pressed pause!');
                            endTimer();
                            setState(() {
                              play = true;
                            });
                          },
                    icon: play
                        ? const Icon(Icons.play_arrow_rounded)
                        : const Icon(Icons.pause_rounded)),
                IconButton(
                  icon: Icon(Icons.restart_alt_rounded),
                  onPressed: () {
                    //restart counter
                    logger.i('Pressed restart!');
                    resetTimer();
                  },
                )
              ],
            ),
          ],
        )
      ],
    );
  }

  final stopwatch = Stopwatch();

  void updatetimer() {
    setState(() {
      if (stopwatch.isRunning) {
        widget.timerTime = widget.timerTime + Duration(seconds: 1);
      }
    });
  }

  void startTimer() async {
    
    stopwatch.start();
    while (stopwatch.isRunning) {
      
      await Future.delayed(Duration(seconds: 1));
      updatetimer();
    }
  }

  void endTimer() {
    stopwatch.stop();
  }

  void resetTimer() {
    stopwatch.stop();
    stopwatch.reset();
    widget.timerTime = Duration(
        hours: 0, minutes: 0, seconds: 0);
    setState(() {
      play = true;
    });
    updatetimer();
  }

  void pauseTimer() {
    stopwatch.stop();
  }
}
