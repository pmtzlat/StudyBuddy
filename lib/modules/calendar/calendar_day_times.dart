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
  bool needsRecalc;
  CalendarDayTimes({
    required Key key,
    required this.updateParent,
    required this.needsRecalc,
  }) : super(key: key);

  @override
  State<CalendarDayTimes> createState() => CalendarDayTimesState();
}

class CalendarDayTimesState extends State<CalendarDayTimes> {
  final _controller = instanceManager.calendarController;
  final dayFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
  }

  void updateParent() {
    logger.i('Calendar Day Times: updateParents');

    //logger.d(instanceManager.sessionStorage.initialDayLoad);
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
        color: widget.needsRecalc
            ? Colors.amber
            : Color.fromARGB(255, 236, 236, 236),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: widget.needsRecalc ? screenHeight * 0.09 : 0,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              reverse: true,
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.black,
                        size: screenHeight * 0.05,
                      ),
                      Container(
                          width: screenWidth * 0.6,
                          child: Text(
                            _localizations.needsRecalculationInfo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.03,
                            ),
                          )),
                      Icon(Icons.warning_rounded,
                          color: Colors.black, size: screenHeight * 0.05),
                    ],
                  )),
            ),
          ),
          instanceManager.sessionStorage.initialDayLoad
              ? TimeShower(
                  times: instanceManager.sessionStorage.loadedCalendarDay.times,
                  updateAllParents: updateParent,
                )
              : ReloadButton(
                  updateParent: updateParent,
                  buttonAction: () async {
                    await instanceManager.calendarController
                        .getCalendarDay(DateTime.now());
                  },
                  bodyMessage: _localizations.errorLoadingDay,
                  buttonMessage: _localizations.reload)
        ],
      ),
    );
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
