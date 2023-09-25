import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              children: [Text(AppLocalizations.of(context)!.calendarTitle)],
            )
          ],
        )
    
    );
  }
}

