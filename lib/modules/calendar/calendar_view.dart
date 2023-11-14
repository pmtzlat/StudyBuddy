import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ntp/ntp.dart';
import 'package:study_buddy/modules/calendar/calendar_day_times.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/modules/calendar/restrictions_detail_view.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final _controller = instanceManager.calendarController;
  GlobalKey<CalendarDayTimesState> _timesKey = GlobalKey();
  late CalendarDayTimes events = CalendarDayTimes(key: _timesKey);

  @override
  void initState() {
    super.initState();
    // Add a post frame callback to show the dialog after the page has been rendered.
    if(!instanceManager.sessionStorage.incompletePreviousDays.isEmpty) {WidgetsBinding.instance?.addPostFrameCallback((_) {
      _showDialog();
    });}
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Page Rendered'),
          content: Text('The page has finished rendering.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 1,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: screenHeight * 0.15,
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestrictionsDetailView(),
                              ),
                            );
                          },
                          icon: Icon(Icons.settings),
                          label: Text(_localizations.changeScheduleGaps)),
                      instanceManager.sessionStorage.needsRecalculation
                          ? Text(
                              _localizations.needsRecalculationInfo,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 219, 164, 0)),
                            )
                          : const SizedBox(),
                      ElevatedButton.icon(
                          onPressed: () async {
                            final result =
                                await _controller.calculateSchedule();
                            switch (result) {
                              case (1):
                                showGreenSnackbar(context,
                                    _localizations.recalculationSuccessful);

                              case (-1):
                                showErrorDialogForRecalc(
                                    context,
                                    _localizations.recalcErrorTitle,
                                    _localizations.recalcErrorBody,
                                    false);

                              case (0):
                                showErrorDialogForRecalc(
                                    context,
                                    _localizations.recalcNoTimeTitle,
                                    _localizations.recalcNoTimeBody,
                                    true);
                            }

                            await _controller
                                .getCalendarDay(stripTime(await NTP.now()));

                            setState(() {
                              _timesKey.currentState!.update();
                            });
                          },
                          icon:
                              instanceManager.sessionStorage.needsRecalculation
                                  ? const Icon(
                                      Icons.warning_amber_outlined,
                                      color: Colors.black,
                                    )
                                  : const Icon(Icons.calculate),
                          label:
                              instanceManager.sessionStorage.needsRecalculation
                                  ? Text(
                                      _localizations.needsRecalculation,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(_localizations.calculateSchedule),
                          style:
                              instanceManager.sessionStorage.needsRecalculation
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber)
                                  : ElevatedButton.styleFrom()),
                    ],
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                  height: screenHeight * 0.584,
                  width: screenWidth * 0.8,
                  child: events),
            )
          ],
        ));
  }
}
