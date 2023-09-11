import 'dart:math';

import 'package:flutter/material.dart';

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
          children: [
            ElevatedButton(onPressed: () => startTimer(), child: Text('Start')),
            ElevatedButton(onPressed: () => pauseTimer(), child: Text('Stop')),
            ElevatedButton(onPressed: () => resetTimer(), child: Text('Reset'))
          ],
        )
      ],
    );
  }

  final stopwatch = Stopwatch();

  void updatetimer() {
    
    setState(() {
      if (stopwatch.isRunning) {
        widget.timerTime = widget.timerTime - Duration(seconds: 1);
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
        hours: widget.hours, minutes: widget.minutes, seconds: widget.seconds);
    updatetimer();
  }

  void pauseTimer() {
    stopwatch.stop();
  }
}
