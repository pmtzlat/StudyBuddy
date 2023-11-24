import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/common_widgets/pause_play_button.dart';
import 'package:study_buddy/common_widgets/time_slot_card.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/modules/loader/loader.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/common_widgets/timer_widget.dart';

class CalendarDayTimes extends StatefulWidget {
  Function updateParent;
  CalendarDayTimes({
    required Key key,
    required this.updateParent,
  }) : super(key: key);

  @override
  State<CalendarDayTimes> createState() => CalendarDayTimesState();
}

class CalendarDayTimesState extends State<CalendarDayTimes> {
  final _controller = instanceManager.calendarController;
  final dayFormKey = GlobalKey<FormBuilderState>();
  late Day day;

  @override
  void initState() {
    super.initState();
    day = instanceManager.sessionStorage.loadedCalendarDay;
  }

  void updateParent() {
    logger.i('Calendar Day Times: updateParents');
    setState(() {
      day = instanceManager.sessionStorage.loadedCalendarDay;
    });
    widget.updateParent();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () async {
                instanceManager.sessionStorage.currentDay = instanceManager
                    .sessionStorage.currentDay
                    .subtract(Duration(days: 1));

                await _controller
                    .getCalendarDay(instanceManager.sessionStorage.currentDay);
                day = instanceManager.sessionStorage.loadedCalendarDay;
                setState(() {});
              },
              icon: Icon(Icons.arrow_left),
            ),
            GestureDetector(
              child: Text(
                  '${day.date.day} - ${day.date.month} - ${day.date.year}'),
              onTap: () {
                logger.i(day.date);
                _showDatePicker(context, day);
              },
            ),
            IconButton(
              onPressed: () async {
                instanceManager.sessionStorage.currentDay = instanceManager
                    .sessionStorage.currentDay
                    .add(Duration(days: 1));

                await _controller
                    .getCalendarDay(instanceManager.sessionStorage.currentDay);
                day = instanceManager.sessionStorage.loadedCalendarDay;
                setState(() {});
              },
              icon: Icon(Icons.arrow_right),
            )
          ],
        ),
        TimeShower(
          screenHeight: screenHeight,
          localizations: _localizations,
          times: day.times,
          updateAllParents: updateParent,
        )
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context, Day day) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: day.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      instanceManager.sessionStorage.currentDay = selectedDate;

      await _controller
          .getCalendarDay(instanceManager.sessionStorage.currentDay);
      day = instanceManager.sessionStorage.loadedCalendarDay;
      updateParent();
    }
  }
}

class TimeShower extends StatefulWidget {
  const TimeShower(
      {super.key,
      required this.screenHeight,
      required AppLocalizations localizations,
      required this.times,
      required this.updateAllParents})
      : _localizations = localizations;

  final double screenHeight;
  final AppLocalizations _localizations;
  final List<TimeSlot> times;
  final Function updateAllParents;

  @override
  State<TimeShower> createState() => _TimeShowerState();
}

class _TimeShowerState extends State<TimeShower> {
  final _controller = instanceManager.calendarController;

  void updateParents() {
    logger.i('TimeShower: updateParents');
    widget.updateAllParents();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.screenHeight * 0.5,
      child: widget.times.isEmpty
          ? Center(child: Text(widget._localizations.noTimeSlotsInDay))
          : MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                  itemCount: widget.times.length,
                  itemBuilder: (context, index) {
                    var timeSlot = widget.times[index];
                    return GestureDetector(
                        onTap: () {
                          _showTimerDialog(context, timeSlot);
                        },
                        child: TimeSlotCard(
                          timeSlot: timeSlot,
                          updateAllParents: updateParents,
                        ));
                  }),
            ),
    );
  }

  void _showTimerDialog(BuildContext context, TimeSlot timeSlot) { //NEEDS TESTING!!
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    Future<void> closeTimer( Duration time, BuildContext context) async {
            
            timeSlot.timeStudied = time;
            if (timeSlot.timeStudied >= Duration(seconds: 5)) {
              timeSlot.completed = true;
              
               _controller.markTimeSlotAsComplete(
                  timeSlot.dayID, timeSlot);
            } else {
              timeSlot.completed = false;
              
               _controller.markTimeSlotAsIncomplete(
                  await instanceManager.firebaseCrudService
                      .getCalendarDayByID(timeSlot.dayID),
                  timeSlot);
            }
            updateParents();
            Navigator.pop(context);
            await _controller.saveTimeStudied(timeSlot);
            await _controller
                .getCalendarDay(instanceManager.sessionStorage.currentDay);
            updateParents();
          }

    TimerWidget timer = TimerWidget(
      hours: timeSlot.timeStudied.inHours,
      minutes: timeSlot.timeStudied.inMinutes,
      seconds: timeSlot.timeStudied.inSeconds,
      sessionTime: Duration(seconds: 5), //timeSlot.duration,
      completeAndClose: closeTimer,
    );
    if (timeSlot.date != stripTime(DateTime.now()))
      return showRedSnackbar(context, _localizations.cantStartSessionForFuture);

    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: const Color.fromARGB(97, 0, 0, 0),
        transitionDuration: Duration(milliseconds: 200),

        // Create the dialog's content
        pageBuilder: (context, animation, secondaryAnimation) {
          final int duration = timeSlot.duration.inSeconds;
          int initialValue = timeSlot.timeStudied.inSeconds;

          

          return Center(
            child: Card(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () async {
                          await closeTimer(timer.timerTime, context);
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                Container(
                  width: screenWidth * 0.8,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          timer,
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )),
          );
        });
  }
}
