import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/common_widgets/time_slot_card.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/modules/loader/loader.dart';
import 'package:study_buddy/services/logging_service.dart';

class CalendarDayTimes extends StatefulWidget {
  CalendarDayTimes({
    required Key key,
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

  void update() {
    setState(() {
      day = instanceManager.sessionStorage.loadedCalendarDay;
    });
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
            times: day.times)
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
      setState(() {});
    }
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
