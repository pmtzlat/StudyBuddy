import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:screen_state/screen_state.dart';
import 'package:study_buddy/common_widgets/pause_play_button.dart';
import 'package:study_buddy/common_widgets/reload_button.dart';
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
  late DayModel day;

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
    logger.d(instanceManager.sessionStorage.initialDayLoad);
    widget.updateParent();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015, horizontal: screenHeight * 0.007),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 236, 236, 236),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          instanceManager.sessionStorage.initialDayLoad
              ? TimeShower(
                  times: day.times,
                  updateAllParents: updateParent,
                )
              : ReloadButton(
                  updatePage: updateParent,
                  message: _localizations.reload)
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, DayModel day) async {
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
      await _controller
          .getCalendarDay(instanceManager.sessionStorage.currentDay);
      day = instanceManager.sessionStorage.loadedCalendarDay;
      updateParent();
    }
  }
}



class TimeShower extends StatefulWidget {
  TimeShower({super.key, required this.times, required this.updateAllParents});

  final List<TimeSlotModel> times;
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
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return widget.times.isEmpty
        ? Expanded(
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _localizations.noTimeSlotsInDay,
                    style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        letterSpacing: 1),
                  )
                ]),
          )
        : Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                  itemCount: widget.times.length,
                  itemBuilder: (context, index) {
                    var timeSlot = widget.times[index];
                    return TimeSlotCard(timeSlot: timeSlot);
                  }),
            ),
          );
  }
}
