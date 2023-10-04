import 'package:flutter/material.dart';

class LoadedCalendarView extends StatefulWidget {
  const LoadedCalendarView({super.key});

  @override
  State<LoadedCalendarView> createState() => _LoadedCalendarViewState();
}

class _LoadedCalendarViewState extends State<LoadedCalendarView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Test')]),
    );
  }
}
