import 'package:flutter/material.dart';

class DayEventsWidget extends StatefulWidget {
  const DayEventsWidget({super.key});

  @override
  State<DayEventsWidget> createState() => _DayEventsWidgetState();
}

class _DayEventsWidgetState extends State<DayEventsWidget> {

  PageController _pageController =
      PageController(initialPage: 0);

  List<Widget> pages = [];
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      children: pages,

    );
  }
}