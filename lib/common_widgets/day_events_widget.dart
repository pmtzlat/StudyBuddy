import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/calendar_day_times.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';

class DayEventsWidget extends StatefulWidget {
  const DayEventsWidget({super.key});

  @override
  State<DayEventsWidget> createState() => _DayEventsWidgetState();
}

class _DayEventsWidgetState extends State<DayEventsWidget> {
  final _controller = instanceManager.calendarController;


  @override
  Widget build(BuildContext context) {
    return  CalendarDayTimes();
       
  }
}
