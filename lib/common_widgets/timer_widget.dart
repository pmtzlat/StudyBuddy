import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:screen_lock_check/screen_lock_check.dart';

import 'package:study_buddy/common_widgets/pause_play_button.dart';
import 'package:study_buddy/services/logging_service.dart';

class TimerWidget extends StatefulWidget {
  final int hours;
  final int minutes;
  final int seconds;
  Duration timerTime;
  Duration sessionTime;
  Function completeAndClose;

  TimerWidget(
      {super.key,
      this.hours = 0,
      this.minutes = 0,
      this.seconds = 0,
      required this.sessionTime,
      required this.completeAndClose})
      : timerTime = Duration(hours: hours, minutes: minutes, seconds: seconds);

  @override
  State<TimerWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> with WidgetsBindingObserver {
  bool play = true;
  bool timerWasRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      bool locked = await ScreenLockCheck().isScreenLockEnabled;
      logger.i(state);
      if (locked) stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      if (!timerWasRunning) {
        startTimer();
      }
    }
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
                          }
                        : () {
                            logger.i('Pressed pause!');
                            stopTimer();
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

  Future<bool> showContinueDialog() async {
    bool result = false;
    final _localizations = AppLocalizations.of(context)!;
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(_localizations.sessionCompleted),
            content: Text(_localizations.sessionCompletedBody),
            actions: [
              TextButton(
                  onPressed: () {
                    result = true;
                    Navigator.pop(context);
                  },
                  child: Text(_localizations.continueTimer)),
              TextButton(
                  onPressed: () {
                    result = false;
                    Navigator.pop(context);
                  },
                  child: Text(_localizations.completeSession))
            ],
          );
        });
    return result;
  }

  final stopwatch = Stopwatch();

  void updatetimer() async {
    setState(() {
      if (stopwatch.isRunning) {
        widget.timerTime = widget.timerTime + Duration(seconds: 1);
      }
    });
  }

  void startTimer() async {
    timerWasRunning = true;
    setState(() {
      play = false;
    });
    stopwatch.start();
    while (stopwatch.isRunning) {
      await Future.delayed(Duration(seconds: 1));
      updatetimer();
      if (widget.timerTime == widget.sessionTime) {
        bool continueTimer = await showContinueDialog();
        if (!continueTimer) {
          widget.completeAndClose(widget.timerTime, context);
          return;
        }
      }
    }
  }

  void stopTimer() {
    setState(() {
      play = true;
    });
    timerWasRunning = false;
    stopwatch.stop();
  }

  void resetTimer() {
    stopwatch.stop();
    stopwatch.reset();
    widget.timerTime = Duration(hours: 0, minutes: 0, seconds: 0);
    setState(() {
      play = true;
    });
    updatetimer();
  }

  void pauseTimer() {
    stopwatch.stop();
  }
}
