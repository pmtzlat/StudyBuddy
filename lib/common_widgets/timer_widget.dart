import 'dart:async';
import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:screen_state/screen_state.dart';

import 'package:study_buddy/common_widgets/pause_play_button.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:flutter/services.dart';

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
  bool paused = false;
  late Screen _screen;
  late StreamSubscription<ScreenStateEvent>? _subscription;
  bool screenOn = true;
  DateTime? preLockTimeStamp;
  DateTime? postLockTimeStamp;

  void onData(ScreenStateEvent event) {
    //logger.i('$paused , $event, $timerWasRunning');
    if ( //paused &&
        event == ScreenStateEvent.SCREEN_OFF //&&timerWasRunning == true
        ) {
      screenOn = false;
      // logger.i('starting from onData');
      // startTimer();
      // paused = false;
    } else {
      screenOn = true;
    }
  }

  void startListening() {
    //logger.i('Listening to screen state...)');
    _screen = new Screen();
    try {
      _subscription = _screen.screenStateStream?.listen(onData);
    } on ScreenStateException catch (exception) {
      logger.e('Error listening to screen state: $exception');
    }
  }

  void stopListening() {
    //logger.i('cancelling screen listener...');
    _subscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startListening();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    //logger.i('$paused , $state, $timerWasRunning');
    if (state == AppLifecycleState.paused) {
      //await isDeviceLocked();
      //if (timerWasRunning) {
      await Future.delayed(Duration(seconds: 1)); //tighten this up a lil bit
      //logger.i('screenOn: $screenOn');
      if (!screenOn) {
        //logger.i('screen is off');
        preLockTimeStamp = DateTime.now();
      }

      //logger.i('pausing...');
      stopTimer();
      paused = true; // is 'paused' redundant?
      

      //}
    } else if (state == AppLifecycleState.resumed) {
      if (timerWasRunning && paused == true) {
        //logger.i('starting from didChangeAppLifecycleState. preLockTImeStamp: $preLockTimeStamp');
        if (preLockTimeStamp != null) {
          postLockTimeStamp = DateTime.now();
          Duration timePassed =
              postLockTimeStamp!.difference(preLockTimeStamp!);
          //logger.i('preLock: $preLockTimeStamp, postLock: $postLockTimeStamp, timePassed: $timePassed\n widget.timerTime: ${widget.timerTime}, result: ${widget.timerTime + timePassed}');
          widget.timerTime += timePassed;
          preLockTimeStamp = null;
          postLockTimeStamp = null;
        }
        startTimer();
      }
    }
  }

  // Future<bool> isDeviceLocked() async {
  //   try {
  //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  //     if (androidInfo != null) {
  //       LocalAuthentication localAuth = LocalAuthentication();
  //       bool canCheckBiometrics = await localAuth.canCheckBiometrics;

  //       if (canCheckBiometrics) {
  //         return !(await localAuth.authenticate(
  //           localizedReason: 'Authenticate to check device lock status',
  //         ));
  //       }
  //     }
  //   } on PlatformException catch (e) {
  //     print('Error checking device lock status: $e');
  //   }

  //   // Default to true if an error occurs (considering the device as locked)
  //   return true;
  //}

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
                            //logger.i('Pressed play!');

                            //logger.i('starting from onPressed play');
                            startTimer();
                            timerWasRunning = true;
                          }
                        : () {
                            //logger.i('Pressed pause!');
                            stopTimer();
                            timerWasRunning = false;
                          },
                    icon: play
                        ? const Icon(Icons.play_arrow_rounded)
                        : const Icon(Icons.pause_rounded)),
                IconButton(
                  icon: Icon(Icons.restart_alt_rounded),
                  onPressed: () {
                    //restart counter
                    //logger.i('Pressed restart!');
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
    setState(() {
      play = false;
    });
    stopwatch.start();
    //logger.i('Started timer!');
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

    stopwatch.stop();
    //logger.i('Paused timer!');
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
