import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/calendar_day_times.dart';
import 'package:study_buddy/main.dart';

class DayEventsWidget extends StatefulWidget {
  const DayEventsWidget({super.key});

  @override
  State<DayEventsWidget> createState() => _DayEventsWidgetState();
}

class _DayEventsWidgetState extends State<DayEventsWidget> {
  PageController _pageController = PageController(initialPage: 1);

  List<Widget> pages = [
    CalendarDayTimes(
        day: instanceManager.sessionStorage.loadedCalendarDays[0]),
    CalendarDayTimes(
        day: instanceManager.sessionStorage.loadedCalendarDays[1]),
    CalendarDayTimes(
        day: instanceManager.sessionStorage.loadedCalendarDays[2]),
  ];
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      children: pages,
    );
  }
}
