import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';


class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  @override
  Widget build(BuildContext context) {
    return instanceManager.scaffold.getScaffold(context: context, activeIndex: 2, 
    body:
    Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Calendar')],
            )
          ],
        )
    
    );
  }
}

