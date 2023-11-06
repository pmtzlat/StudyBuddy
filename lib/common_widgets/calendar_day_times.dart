import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/time_slot_card.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/modules/loader/loader.dart';
import 'package:study_buddy/services/logging_service.dart';

class CalendarDayTimes extends StatefulWidget {
  Day day;

  CalendarDayTimes({super.key, required this.day});

  @override
  State<CalendarDayTimes> createState() => _CalendarDayTimesState();
}

class _CalendarDayTimesState extends State<CalendarDayTimes> {
  final _controller = instanceManager.calendarController;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
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
                widget.day = instanceManager.sessionStorage.loadedCalendarDay;
                setState(() {
                });
              },
              icon: Icon(Icons.arrow_left),
            ),
            Text(
                '${widget.day.date.day} - ${widget.day.date.month} - ${widget.day.date.year}'),
            IconButton(
              onPressed: () async {
                instanceManager.sessionStorage.currentDay = instanceManager
                    .sessionStorage.currentDay
                    .add(Duration(days: 1));

                await _controller
                    .getCalendarDay(instanceManager.sessionStorage.currentDay);
                widget.day = instanceManager.sessionStorage.loadedCalendarDay;
                setState(() {
                });
              },
              icon: Icon(Icons.arrow_right),
            )
          ],
        ),
        TimeShower(
            screenHeight: screenHeight,
            localizations: _localizations,
            times: widget.day.times)
      ],
    );
  }
}

class TimeShower extends StatefulWidget {
  const TimeShower(
      {super.key,
      required this.screenHeight,
      required AppLocalizations localizations,
      required this.times})
      : _localizations = localizations;

  final double screenHeight;
  final AppLocalizations _localizations;
  final List<TimeSlot> times;

  @override
  State<TimeShower> createState() => _TimeShowerState();
}

class _TimeShowerState extends State<TimeShower> {
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
                    return TimeSlotCard(timeSlot: timeSlot);
                  }),
            ),
    );
  }
}
