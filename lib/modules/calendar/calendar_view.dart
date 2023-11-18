import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ntp/ntp.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/modules/calendar/calendar_day_times.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/modules/calendar/restrictions_detail_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late bool needsUpdate;
  final _controller = instanceManager.calendarController;
  GlobalKey<CalendarDayTimesState> _timesKey = GlobalKey();
  late CalendarDayTimes events = CalendarDayTimes(
    key: _timesKey,
    updateParent: () {
      logger.i(instanceManager.sessionStorage.needsRecalculation);
      setState(() {
        needsUpdate = instanceManager.sessionStorage.needsRecalculation;
      });
    },
  );

  @override
  void initState() {
    super.initState();

    // Add a post frame callback to show the dialog after the page has been rendered.
    if (!instanceManager.sessionStorage.incompletePreviousDays.isEmpty) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showPrevDayCompletionDialog(
            instanceManager.sessionStorage.incompletePreviousDays);
      });
    }
    needsUpdate = instanceManager.sessionStorage.needsRecalculation;
  }

  void _showPrevDayCompletionDialog(Map<String, List<TimeSlot>> dictionary) {
    // TODO: show dialog to mark past days as complete or not complete
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    List<String> keys = dictionary.keys.toList();
    logger.i(dictionary);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: const Color.fromARGB(97, 0, 0, 0),

      transitionDuration: Duration(milliseconds: 200),

      // Create the dialog's content
      pageBuilder: (context, animation, secondaryAnimation) {
        PageController pageController = PageController(initialPage: 0);

        return Center(
          child: Card(
            child: Container(
              height: screenHeight * 0.7,
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenWidth * 0.1),
              child: Column(
                children: [
                  Text(_localizations.completePreviousDaysTitle),
                  Text(_localizations.completePreviousDaysDesc),
                  Container(
                    height: screenHeight * 0.4,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: keys.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Return a widget for each page based on the array item
                        DateTime dateInQuestion = DateTime.parse(keys[index]);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Center(
                                      child: Text(dateInQuestion.toString())),
                                ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          instanceManager.sessionStorage
                                              .needsRecalculation = true;
                                          if (index < keys.length - 1) {
                                            dateInQuestion = dateInQuestion
                                                .add(Duration(days: 1));
                                            pageController.nextPage(
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.easeInOut);
                                          } else {
                                            instanceManager.sessionStorage
                                                    .incompletePreviousDays =
                                                <String, List<TimeSlot>>{};
                                            Navigator.pop(context);
                                            setState(() {});
                                          }
                                        },
                                        child: Text(_localizations.leaveAsIs)),
                                    ElevatedButton(
                                        onPressed: () async {
                                          logger.i(dictionary[
                                              dateInQuestion.toString()]);
                                          instanceManager.calendarController
                                              .markTimeSlotListAsComplete(
                                                  dictionary[dateInQuestion
                                                      .toString()]);
                                          if (index < keys.length - 1) {
                                            dateInQuestion = dateInQuestion
                                                .add(Duration(days: 1));
                                            pageController.nextPage(
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.easeInOut);
                                          } else {
                                            Navigator.pop(context);
                                            instanceManager.sessionStorage
                                                    .incompletePreviousDays =
                                                <String, List<TimeSlot>>{};
                                            setState(() {});
                                          }
                                        },
                                        child: Text(
                                            _localizations.markAsComplete)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> handleScheduleCalculation(
      BuildContext context, AppLocalizations _localizations) async {
    final result = await _controller.calculateSchedule();
    switch (result) {
      case (1):
        showGreenSnackbar(context, _localizations.recalculationSuccessful);

      case (-1):
        showErrorDialogForRecalc(context, _localizations.recalcErrorTitle,
            _localizations.recalcErrorBody, false);

      case (0):
        showErrorDialogForRecalc(context, _localizations.recalcNoTimeTitle,
            _localizations.recalcNoTimeBody, true);
    }

    await _controller.getCalendarDay(stripTime(await NTP.now()));

    setState(() {
      _timesKey.currentState!.updateParent();
    });
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
                            handleScheduleCalculation(context, _localizations);
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
