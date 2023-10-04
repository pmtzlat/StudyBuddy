import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/main.dart';

class LoadedCalendarView extends StatefulWidget {
  final Function notifyParent;
  const LoadedCalendarView({super.key, required Function this.notifyParent});

  @override
  State<LoadedCalendarView> createState() => _LoadedCalendarViewState();
}

class _LoadedCalendarViewState extends State<LoadedCalendarView> {
  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        Title(color: Colors.black, child: Text(_localizations.calendarTitle)),
        ElevatedButton.icon(
            onPressed: () {
              instanceManager.sessionStorage.schedulePresent = null;
              widget.notifyParent();
            },
            icon: Icon(Icons.settings),
            label: Text(_localizations.changeScheduleRestrictions))
      ],
    );
  }
}
