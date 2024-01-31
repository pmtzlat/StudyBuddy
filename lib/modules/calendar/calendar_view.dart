import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:study_buddy/common_widgets/reload_button.dart';
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
import 'package:study_buddy/utils/general_utils.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with SingleTickerProviderStateMixin {
  late bool autoRecalc;
  late AnimationController _animationController;
  final _controller = instanceManager.calendarController;
  GlobalKey<CalendarDayTimesState> _timesKey = GlobalKey();
  DayModel day = instanceManager.sessionStorage.loadedCalendarDay;
  Duration recalcTime = Duration(milliseconds: 150);
  bool needsRecalc = instanceManager.sessionStorage.needsRecalculation;
  Color titleGrey = Color.fromARGB(255, 92, 92, 92);
  Color backgroundColor = Color.fromARGB(255, 250, 253, 253);
  bool dayLoaded = true;

  bool scrollSheetIsUp = false;
  Duration scrollUpTime = Duration(milliseconds: 400);

  late CalendarDayTimes events = CalendarDayTimes(
    key: _timesKey,
    updateParent: () {
      //logger.i(instanceManager.sessionStorage.needsRecalculation);
      day = instanceManager.sessionStorage.loadedCalendarDay;
      if (instanceManager.sessionStorage.initialDayLoad) {
        dayLoaded = !(instanceManager.sessionStorage.loadedCalendarDay.id ==
            'Placeholder');
      }
    },
  );

  @override
  void initState() {
    super.initState();
    autoRecalc = false;
    // dayLoaded = instanceManager.sessionStorage.initialDayLoad;
    // Add a post frame callback to show the dialog after the page has been rendered.
    if (!instanceManager.sessionStorage.incompletePreviousDays.isEmpty) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showPrevDayCompletionDialog(
            instanceManager.sessionStorage.incompletePreviousDays);
      });
    }
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
    );
  }

  void _showRecalculationAdvice(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.amber,
                size: 40.0,
              ),
              SizedBox(width: 10.0),
              Text(_localizations.warning),
            ],
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_localizations.keepOrRecalc),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(_localizations.keep),
            ),
            SizedBox(width: 10.0), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () {
                //Navigator.of(context).pop();
                setState(() {
                  autoRecalc = true;
                });
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(_localizations.recalc),
            ),
          ],
        );
      },
    );
  }

  void _showPrevDayCompletionDialog(
      Map<String, List<TimeSlotModel>> dictionary) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    List<String> keys = dictionary.keys.toList();
    bool leftDaysUnsaved = false;
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
                    width: screenWidth * 0.8,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: keys.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Return a widget for each page based on the array item
                        DateTime dateInQuestion = DateTime.parse(keys[index]);
                        return Container(
                          width: screenWidth * 0.75,
                          child: Column(
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
                                            _controller.markDayAsNotified(
                                                dateInQuestion);

                                            leftDaysUnsaved = true;
                                            if (index < keys.length - 1) {
                                              dateInQuestion = dateInQuestion
                                                  .add(Duration(days: 1));
                                              pageController.nextPage(
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut);
                                            } else {
                                              instanceManager.sessionStorage
                                                      .incompletePreviousDays =
                                                  <String,
                                                      List<TimeSlotModel>>{};

                                              if (leftDaysUnsaved) {
                                                _showRecalculationAdvice(
                                                    context);
                                              } else {
                                                Navigator.pop(context);
                                              }

                                              setState(() {});
                                            }
                                          },
                                          child:
                                              Text(_localizations.leaveAsIs)),
                                      ElevatedButton(
                                          onPressed: () async {
                                            _controller.markDayAsNotified(
                                                dateInQuestion);
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
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut);
                                            } else {
                                              instanceManager.sessionStorage
                                                      .incompletePreviousDays =
                                                  <String,
                                                      List<TimeSlotModel>>{};
                                              if (leftDaysUnsaved) {
                                                _showRecalculationAdvice(
                                                    context);
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            }
                                          },
                                          child: Text(
                                              _localizations.markAsComplete)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
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
        setState(() {
          instanceManager.sessionStorage.needsRecalculation = false;
        });

      case (-1):
        showErrorDialogForRecalc(context, _localizations.recalcErrorTitle,
            _localizations.recalcErrorBody, false);
        setState(() {
          instanceManager.sessionStorage.needsRecalculation = true;
        });

      case (0):
        showErrorDialogForRecalc(context, _localizations.recalcNoTimeTitle,
            _localizations.recalcNoTimeBody, true);
        setState(() {
          instanceManager.sessionStorage.needsRecalculation = true;
        });
    }

    await _controller.getCalendarDay(stripTime(await NTP.now()));

    setState(() {
      _timesKey.currentState!.updateParent();
    });
  }

  void moveSheetUp() {
    _animationController.forward();
    setState(() {
      scrollSheetIsUp = true;
    });
  }

  void moveSheetDown() {
    _animationController.reverse();
    setState(() {
      scrollSheetIsUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    if (autoRecalc) {
      handleScheduleCalculation(context, _localizations);
      autoRecalc = false;
    }

    logger.i(
        'Day: ${instanceManager.sessionStorage.loadedCalendarDay.getString()}');

    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 1,
        padding: false,
        body: Stack(
          children: [
            Container(
              //padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Column(
                children: [
                  Container(
                    height: screenHeight * 0.07,
                    width: screenWidth * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (!dayLoaded) return;
                              setState(() {
                                dayLoaded = false;
                              });

                              if (!await _controller.getCalendarDay(
                                  instanceManager.sessionStorage.currentDay
                                      .subtract(Duration(days: 1))))
                                showRedSnackbar(
                                    context, _localizations.errorLoadingDay);
                              setState(() {
                                dayLoaded = true;
                              });
                            },
                            icon: Icon(
                              Icons.chevron_left_rounded,
                              color: titleGrey.withOpacity(0.3),
                              size: screenWidth * 0.1,
                            )),
                        Text(
                          DateFormat('dd MMM. yyyy', Intl.defaultLocale).format(
                              instanceManager.sessionStorage.currentDay),
                          style: TextStyle(
                              fontSize: screenWidth * 0.08, color: titleGrey),
                        ),
                        IconButton(
                            onPressed: () async {
                              if (!dayLoaded) return;
                              setState(() {
                                dayLoaded = false;
                              });

                              if (!await _controller.getCalendarDay(
                                  instanceManager.sessionStorage.currentDay
                                      .add(Duration(days: 1))))
                                showRedSnackbar(
                                    context, _localizations.errorLoadingDay);
                              setState(() {
                                dayLoaded = true;
                              });
                            },
                            icon: Icon(Icons.chevron_right_rounded,
                                color: titleGrey.withOpacity(0.3),
                                size: screenWidth * 0.1)),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: recalcTime,
                    height: needsRecalc ? screenHeight * 0.09 : 0,
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      reverse: true,
                      child: Container(
                          width: double.infinity,
                          color: Colors.amber,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.black,
                                size: screenHeight * 0.05,
                              ),
                              Container(
                                  width: screenWidth * 0.6,
                                  child: Text(
                                    _localizations.needsRecalculationInfo,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  )),
                              Icon(Icons.warning_rounded,
                                  color: Colors.black,
                                  size: screenHeight * 0.05),
                            ],
                          )),
                    ),
                  ),
                  AnimatedContainer(
                    duration: recalcTime,
                    height: needsRecalc ? screenHeight * 0.02 : 0,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      children: [
                        Center(
                          child: AnimatedContainer(
                              duration: recalcTime,
                              width: double.infinity,
                              height: needsRecalc
                                  ? screenHeight * 0.5
                                  : screenHeight * 0.61,
                              child: dayLoaded
                                  ? events
                                  : Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.015,
                                          horizontal: screenHeight * 0.007),
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 236, 236, 236),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                              child: Container(
                                            height: screenWidth * 0.1,
                                            width: screenWidth * 0.1,
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.black12,
                                            ),
                                          )),
                                        ],
                                      ),
                                    )),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                logger.i('tapped');
                                handleScheduleCalculation(
                                    context, _localizations);
                              },
                              child: AnimatedContainer(
                                duration: recalcTime,
                                width: screenWidth * 0.35,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: needsRecalc
                                      ? [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(
                                                0.5), // Shadow color
                                            spreadRadius:
                                                3, // Spread of the shadow
                                            blurRadius:
                                                7, // Blur radius of the shadow
                                            offset: Offset(
                                                0, 0), // Offset of the shadow
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calculate,
                                      color: needsRecalc
                                          ? Colors.amber
                                          : titleGrey,
                                      size: screenWidth * 0.12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      child: Text(
                                          needsRecalc
                                              ? _localizations.updatePlan
                                              : _localizations.calculatePlan,
                                          maxLines: 2,
                                          softWrap: true,
                                          style: TextStyle(
                                              fontWeight: needsRecalc
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: needsRecalc
                                                  ? Colors.amber
                                                  : titleGrey)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                logger.i('tapped');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RestrictionsDetailView(),
                                  ),
                                );
                              },
                              child: Container(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: screenWidth * 0.22,
                                        child: Text(
                                            _localizations.changeAvailability,
                                            maxLines: 2,
                                            textAlign: TextAlign.end,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: titleGrey)),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.settings,
                                        color: titleGrey,
                                        size: screenWidth * 0.12,
                                      )
                                    ]),
                              ),
                            )
                          ],
                        ),
                        TextButton(
                            style: TextButton.styleFrom(
                              padding:
                                  EdgeInsets.all(0), // Set your desired padding
                            ),
                            onPressed: () {
                              setState(() {
                                needsRecalc = !needsRecalc;
                              });
                            },
                            child: Text('needsrecalc')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     AnimatedContainer(
            //       //color: Colors.yellow,
            //       curve: Curves.decelerate,
            //       duration: scrollUpTime,
            //       height: scrollSheetIsUp
            //           ? screenHeight * 0.73
            //           : screenHeight * 0.12,
            //       child: SingleChildScrollView(
            //         physics: NeverScrollableScrollPhysics(),
            //         child: Container(
            //           padding: EdgeInsets.only(top: 10),
            //           child: ClipShadowPath(
            //             shadow: const Shadow(
            //                 blurRadius: 10,
            //                 color: Color.fromARGB(255, 222, 222, 222)),
            //             clipper: CustomShapeClipper(),
            //             child: Container(
            //               height: screenHeight * 0.8,
            //               width: screenWidth,
            //               color: const Color.fromARGB(255, 255, 255, 255),
            //               child: Column(
            //                 children: [
            //                   GestureDetector(
            //                     child: Container(
            //                       width: screenWidth / 6,
            //                       padding: EdgeInsets.only(
            //                           top: screenWidth * 0.02,
            //                           left: screenWidth * 0.02,
            //                           right: screenWidth * 0.02),
            //                       child: RotationTransition(
            //                         turns: Tween<double>(begin: 0.0, end: 0.5)
            //                             .animate(_animationController),
            //                         child: Icon(Icons.keyboard_arrow_up),
            //                       ),
            //                     ),
            //                     onTap: () {
            //                       scrollSheetIsUp
            //                           ? moveSheetDown()
            //                           : moveSheetUp();
            //                     },
            //                   ),
            //                   TextButton(
            //                       style: TextButton.styleFrom(
            //                         padding: EdgeInsets.all(
            //                             0), // Set your desired padding
            //                       ),
            //                       onPressed: () {
            //                         setState(() {
            //                           needsRecalc = !needsRecalc;
            //                         });
            //                       },
            //                       child: Text('needsrecalc')),
            //                   // Container(

            //                   //   child:
            //                   //   TextButton(
            //                   //     onPressed: () {
            //                   //     scrollSheetIsUp
            //                   //         ? moveSheetDown()
            //                   //         : moveSheetUp();
            //                   //     },
            //                   //     child: Text(_localizations.viewMonth,
            //                   //     style: TextStyle(
            //                   //         fontSize: screenWidth * 0.04,
            //                   //         color: Color.fromARGB(255, 92, 92, 92)),)
            //                   //   ),
            //                   // )
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // )
          ],
        ));
  }
}
