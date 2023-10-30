import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/modules/calendar/restrictions_detail_view.dart';

class LoadedCalendarView extends StatefulWidget {
  const LoadedCalendarView({super.key});

  @override
  State<LoadedCalendarView> createState() => _LoadedCalendarViewState();
}

class _LoadedCalendarViewState extends State<LoadedCalendarView> {
  final _controller = instanceManager.calendarController;
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 2,
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(screenWidth * 0.05),
              child: Text(
                _localizations.calendarTitle,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RestrictionsDetailView(), 
                    ),
                  );
                },
                icon: Icon(Icons.settings),
                label: Text(_localizations.changeScheduleGaps)),
            (instanceManager.sessionStorage.activeCourses.length != 0) && (instanceManager.sessionStorage.weeklyGaps != null)
                ? ElevatedButton.icon(
                    onPressed: () async {
                      await _controller.calculateSchedule();
                    },
                    icon: Icon(Icons.calculate),
                    label: Text('calculate schedule'))
                : SizedBox()
          ],
        ));
  }
}
