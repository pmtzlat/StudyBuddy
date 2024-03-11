import 'dart:async';
import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:screen_state/screen_state.dart';

import 'package:study_buddy/common_widgets/pause_play_button.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/modules/calendar/controllers/calendar_controller.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:flutter/services.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';

import '../main.dart';

Color foregroundColor = Colors.black;

class TimerWidget extends StatefulWidget {
  final int hours;
  final int minutes;
  final int seconds;
  Duration timerTime;
  TimeSlotModel timeSlot;
  Duration sessionTime;
  Function completeAndClose;

  TimerWidget(
      {super.key,
      this.hours = 0,
      this.minutes = 0,
      this.seconds = 0,
      required this.timeSlot,
      required this.sessionTime,
      required this.completeAndClose})
      : timerTime = Duration(hours: hours, minutes: minutes, seconds: seconds);

  @override
  State<TimerWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> with WidgetsBindingObserver {
  bool play = true;
  bool timerWasRunning = false;
  late Screen _screen;
  late StreamSubscription<ScreenStateEvent>? _subscription;
  bool loading = false;
  bool continueTimer = false;
  bool screenOn = true;
  DateTime? preLockTimeStamp;
  DateTime? postLockTimeStamp;

  void onData(ScreenStateEvent event) {
    if (event == ScreenStateEvent.SCREEN_OFF) {
      screenOn = false;
    } else {
      screenOn = true;
    }
  }

  void startListening() {
    _screen = new Screen();
    try {
      _subscription = _screen.screenStateStream?.listen(onData);
    } on ScreenStateException catch (exception) {
      logger.e('Error listening to screen state: $exception');
    }
  }

  void stopListening() {
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
    if (state == AppLifecycleState.paused) {
      await Future.delayed(Duration(seconds: 1));
      if (!screenOn) {
        preLockTimeStamp = DateTime.now();
      }

      stopTimer();

      //}
    } else if (state == AppLifecycleState.resumed) {
      if (timerWasRunning) {
        if (preLockTimeStamp != null) {
          postLockTimeStamp = DateTime.now();
          Duration timePassed =
              postLockTimeStamp!.difference(preLockTimeStamp!);
          widget.timerTime += timePassed;
          preLockTimeStamp = null;
          postLockTimeStamp = null;
        }

        startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    double iconSize = screenWidth * 0.16;
    double textSize = screenWidth * 0.04;
    double timeSize = screenWidth * 0.125;
    int hoursShown = widget.timerTime.inHours % 23;
    int minutesShown =
        (widget.timerTime.inMinutes - Duration(hours: hoursShown).inMinutes) %
            60;
    int secondsShown = (widget.timerTime.inSeconds -
            Duration(hours: hoursShown, minutes: minutesShown).inSeconds) %
        60;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                Text(
                  _localizations.hoursCapitalized,
                  style: TextStyle(fontSize: textSize),
                ),
                Text(
                  '${hoursShown < 10 ? '0${hoursShown}' : hoursShown}',
                  style: TextStyle(fontSize: timeSize),
                )
              ],
            ),
            Text(' : ', style: TextStyle(fontSize: timeSize)),
            Column(
              children: [
                Text(
                  _localizations.minutesCapitalized,
                  style: TextStyle(fontSize: textSize),
                ),
                Text(
                  '${minutesShown < 10 ? '0${minutesShown}' : minutesShown}',
                  style: TextStyle(fontSize: timeSize),
                )
              ],
            ),
            Text(' : ', style: TextStyle(fontSize: timeSize)),
            Column(
              children: [
                Text(
                  _localizations.secondsCapitalized,
                  style: TextStyle(fontSize: textSize),
                ),
                Text(
                  '${secondsShown < 10 ? '0${secondsShown}' : secondsShown}',
                  style: TextStyle(fontSize: timeSize),
                )
              ],
            ),
          ],
        ),
        SizedBox(
          height: screenHeight * 0.03,
        ),
        Text(
            '${_localizations.goal}: ${formatDuration(widget.timeSlot.duration)}',
            style: TextStyle(fontSize: screenWidth * 0.05)),
        SizedBox(
          height: screenHeight * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
                onPressed: play
                    ? () {
                        startTimer();
                        timerWasRunning = true;
                      }
                    : () {
                        stopTimer();
                        timerWasRunning = false;
                      },
                icon: Icon(
                  play ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: iconSize,
                )),
            SizedBox(width: screenWidth * 0.3),
            IconButton(
              icon: Icon(
                Icons.replay_rounded,
                color: Colors.white,
                size: iconSize,
              ),
              onPressed: () {
                resetTimer();
              },
            ),
          ],
        ),
        SizedBox(
          height: screenHeight * 0.03,
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
          var screenHeight = MediaQuery.of(context).size.height;
          var screenWidth = MediaQuery.of(context).size.width;
          final _localizations = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(_localizations.sessionCompleted),
            content: Text(_localizations.sessionCompletedBody),
            actions: [
              TextButton(
                  onPressed: () {
                    result = true;
                    Navigator.pop(context);
                  },
                  child: Text(_localizations.continueTimer,
                      style: TextStyle(
                          color: widget.timeSlot.examColor,
                          fontSize: screenWidth * 0.05))),
              TextButton(
                  onPressed: () {
                    result = false;
                    Navigator.pop(context);
                  },
                  child: Text(_localizations.completeSession,
                      style: TextStyle(
                          color: widget.timeSlot.examColor,
                          fontSize: screenWidth * 0.05)))
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
    while (stopwatch.isRunning) {
      await Future.delayed(Duration(seconds: 1));
      updatetimer();
      if (widget.timerTime >= widget.timeSlot.duration && continueTimer == false) {
        continueTimer = await showContinueDialog();
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
  }

  void resetTimer() {
    stopwatch.stop();
    stopwatch.reset();
    widget.timerTime = Duration(hours: 0, minutes: 0, seconds: 0);
    setState(() {
      play = true;
      continueTimer = false;
    });
    updatetimer();
  }

  void pauseTimer() {
    stopwatch.stop();
  }
}

Future<void> showTimerDialog(
    BuildContext context, TimeSlotModel timeSlot, int index) async {
  await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Color.fromARGB(208, 0, 0, 0),
      transitionDuration: Duration(milliseconds: 200),

      // Create the dialog's content
      pageBuilder: (context, animation, secondaryAnimation) {
        final int duration = timeSlot.duration.inSeconds;
        int initialValue = timeSlot.timeStudied.inSeconds;

        return TimerDialog(timeSlot: timeSlot, index: index);
      });
}

class TimerDialog extends StatefulWidget {
  TimerDialog({
    super.key,
    required this.index,
    required this.timeSlot,
  });

  TimeSlotModel timeSlot;
  int index;

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  bool loading = false;
  CalendarController controller = instanceManager.calendarController;

  List<int> formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = (duration.inMinutes - Duration(hours: hours).inMinutes) % 60;
    int seconds = (duration.inSeconds -
            Duration(hours: hours, minutes: minutes).inSeconds) %
        60;

    return [hours, minutes, seconds];
  }

  late List<int> formattedDuration;
  final GlobalKey<TimerWidgetState> timerKey = GlobalKey<TimerWidgetState>();

  late TimerWidget timer;

  Future<void> saveChangesToTimeSlot(
      Duration time, BuildContext context) async {
    widget.timeSlot.timeStudied = time;
    if (widget.timeSlot.timeStudied >= widget.timeSlot.duration &&
        widget.timeSlot.completed == false) {
      await widget.timeSlot.changeCompleteness(true);
    } else if (widget.timeSlot.timeStudied < widget.timeSlot.duration &&
        widget.timeSlot.completed == true) {
      await widget.timeSlot.changeCompleteness(false);
    }
  }

  Future<void> completeAndClose(Duration time, BuildContext context) async {
    setState(() {
      loading = true;
    });
    //await Future.delayed(Duration(seconds:15));
    await saveChangesToTimeSlot(time, context);
    await controller.saveTimeStudied(widget.timeSlot);
    instanceManager.sessionStorage.loadedCalendarDay.timeSlots[widget.index] =
        await controller.getTimeSlot(widget.timeSlot.id, widget.timeSlot.dayID);
    logger.i(
        'Completed and closed!\n ${getStringFromTimeSlotList(instanceManager.sessionStorage.loadedCalendarDay.timeSlots)}');
    setState(() {
      loading = false;
    });
    Navigator.pop(context, widget.timeSlot);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formattedDuration = formatDuration(widget.timeSlot.timeStudied);
    timer = TimerWidget(
      key: timerKey,
      hours: formattedDuration[0],
      minutes: formattedDuration[1],
      seconds: formattedDuration[2],
      sessionTime: widget.timeSlot.duration, //timeSlot.duration,
      completeAndClose: completeAndClose,
      timeSlot: widget.timeSlot,
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    final lighterColor = lighten(widget.timeSlot.examColor, .05);
    final darkerColor = darken(widget.timeSlot.examColor, .15);

    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          height: screenHeight*0.45,
          width: screenWidth*0.91,
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(
                end: Alignment.bottomLeft,
                begin: Alignment.topRight,
                //stops: [ 0.1, 0.9],
                colors: [lighterColor, darkerColor]),
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 10),
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: screenWidth * 0.5,
                            child: Text(
                              _localizations.dontCloseApp,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ))
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        timer,
                      ],
                    )
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () async {
                        timerKey.currentState?.stopListening();
                        timerKey.currentState?.stopTimer();

                        await completeAndClose(timer.timerTime, context);

                       
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: screenWidth * 0.1,
                        color: Colors.black,
                      )),
                ],
              ),
              loading ? Container(
                color: Colors.black.withOpacity(0.3),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                //mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                      height: screenHeight*0.1,
                      width: screenHeight*0.1,
                      child: CircularProgressIndicator(color: Colors.white))],
                  )
                ],),
              ) : SizedBox()
            
            ],
          ),
        ),
      ),
    );
  }
}
