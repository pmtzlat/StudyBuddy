import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/modules/calendar/restrictions_detail_view.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(screenWidth * 0.05),
              child: Text(
                _localizations.calendarTitle,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Container(
              height: screenHeight*0.15,
              child: Column(
                children: [
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
                      : SizedBox(),
                ],
              ),
            ),
            Center(
              child: Container(
                height: screenHeight*0.55,
                width: screenWidth*0.8,
                color: Colors.yellow,
            
              ),
            )
              


          ],
        ));
  }
}
