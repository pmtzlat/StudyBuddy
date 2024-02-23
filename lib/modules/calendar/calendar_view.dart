import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ntp/ntp.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/modules/calendar/calendar_day_times.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/modules/calendar/general_availability_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/utils/general_utils.dart';
import 'package:calendar_timeline/calendar_timeline.dart';

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
  final GlobalKey<CalendarDayTimesState> _timesKey = GlobalKey();
  DayModel day = instanceManager.sessionStorage.loadedCalendarDay;
  DateTime date = instanceManager.sessionStorage.selectedDate;
  Duration recalcTime = const Duration(milliseconds: 150);
  bool needsRecalc = instanceManager.sessionStorage.needsRecalculation;
  Color titleGrey = const Color.fromARGB(255, 92, 92, 92);
  Color backgroundColor = const Color.fromARGB(255, 250, 253, 253);
  bool dayLoaded = true;
  final PageController _pageController = PageController(initialPage: 0);

  bool scrollSheetIsUp = false;
  Duration scrollUpTime = const Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    autoRecalc = false;
    
    // Add a post frame callback to show the dialog after the page has been rendered.
    if (!instanceManager.sessionStorage.incompletePreviousDays.isEmpty
        //true
        ) {
      // var _now = stripTime(DateTime.now());
      // var startTime = TimeOfDay(hour: 0, minute: 0);
      // var endTime = TimeOfDay(hour: 1, minute: 0);

      // Map<String, List<TimeSlotModel>> _testingIncompleteDays = {
      //   _now.toString(): [
      //     TimeSlotModel(
      //         weekday: _now.weekday,
      //         startTime: startTime,
      //         endTime: endTime,
      //         examID: 'examID'),
      //     TimeSlotModel(
      //         weekday: _now.weekday,
      //         startTime: startTime,
      //         endTime: endTime,
      //         examID: 'examID'),
      //     TimeSlotModel(
      //         weekday: _now.weekday,
      //         startTime: startTime,
      //         endTime: endTime,
      //         examID: 'examID'),
      //     TimeSlotModel(
      //         weekday: _now.weekday,
      //         startTime: startTime,
      //         endTime: endTime,
      //         examID: 'examID'),
      //   ],
      //   _now.add(Duration(days: 1)).toString(): [
      //     TimeSlotModel(
      //         weekday: _now.weekday,
      //         startTime: startTime,
      //         endTime: endTime,
      //         examID: 'examID'),
      //     TimeSlotModel(
      //         weekday: _now.weekday,
      //         startTime: startTime,
      //         endTime: endTime,
      //         examID: 'examID'),
      //   ],
      //   _now.add(Duration(days: 2)).toString(): [
      //     TimeSlotModel(
      //         weekday: _now.weekday,
      //         startTime: startTime,
      //         endTime: endTime,
      //         examID: 'examID'),
      //   ]
      // };
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        final _localizations = AppLocalizations.of(context)!;
        await _showPrevDayCompletionDialog(
            instanceManager.sessionStorage.incompletePreviousDays
            //_testingIncompleteDays
            );
        if (autoRecalc)
          await handleScheduleCalculation(context, _localizations);
      });
    }
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
    );
  }

  void _showRecalculationAdvice(BuildContext context) async {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    await showDialog(
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
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(_localizations.keep),
            ),
            SizedBox(width: 10.0), // Add some spacing between buttons
            TextButton(
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

  Future<void> _showPrevDayCompletionDialog(
      Map<String, List<TimeSlotModel>> dictionary) async {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    List<String> keys = dictionary.keys.toList();
    bool leftDaysUnsaved = false;
    bool loadingButton1 = false;
    bool loadingButton2 = false;


    await showGeneralDialog(
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
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              constraints: BoxConstraints(
                minHeight: 50.0, // Set your minimum height here
                maxHeight: screenHeight * 0.87, // Set your maximum height here
              ),
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(_localizations.completePreviousDaysTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.07)),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    _localizations.completePreviousDaysDesc,
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: keys.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Return a widget for each page based on the array item
                        DateTime dateInQuestion = DateTime.parse(keys[index]);
                        return Container(
                          color: Colors.transparent,
                          width: screenWidth * 0.75,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: SingleChildScrollView(
                                    child: Container(
                                      //color: Colors.yellow.withOpacity(0.3),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Center(
                                                    child: Text(
                                                  formatDateTime(
                                                      context, dateInQuestion),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.05),
                                                )),
                                              ]),
                                          for (TimeSlotModel timeSlot
                                              in dictionary[
                                                  dateInQuestion.toString()]!)
                                            Card(
                                                elevation: 0,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 10),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        end: Alignment
                                                            .bottomLeft,
                                                        begin:
                                                            Alignment.topRight,
                                                        //stops: [ 0.1, 0.9],
                                                        colors: [
                                                          timeSlot.examColor,
                                                          darken(
                                                              timeSlot
                                                                  .examColor,
                                                              0.15)
                                                        ]),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.05,
                                                    vertical:
                                                        screenWidth * 0.03,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width:
                                                            screenWidth * 0.6,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                timeSlot
                                                                    .examName,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.05,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            Text(
                                                                timeSlot
                                                                    .unitName,
                                                                style: TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300))
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        if(loadingButton2) return;
                                        setState(() {
                                          loadingButton1 = true;
                                        });
                                        _controller
                                            .markDayAsNotified(dateInQuestion);

                                        leftDaysUnsaved = true;

                                        setState(() {
                                          loadingButton1 = false;
                                        });
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
                                              <String, List<TimeSlotModel>>{};

                                          if (leftDaysUnsaved) {
                                            _showRecalculationAdvice(context);
                                          } else {
                                            Navigator.pop(context);
                                          }

                                          setState(() {});
                                        }
                                      },
                                      child: loadingButton1 ? CircularProgressIndicator() : Text(_localizations.leaveAsIs)),
                                  TextButton(
                                      onPressed: () async {
                                        if(loadingButton1) return;
                                        setState(() {
                                          loadingButton2 = true;
                                        });
                                        _controller
                                            .markDayAsNotified(dateInQuestion);
                                        logger.i(dictionary[
                                            dateInQuestion.toString()]);
                                        instanceManager.calendarController
                                            .markTimeSlotListAsComplete(
                                                dictionary[
                                                    dateInQuestion.toString()]);
                                        setState(() {
                                          loadingButton1 = false;
                                        });
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
                                              <String, List<TimeSlotModel>>{};
                                          if (leftDaysUnsaved) {
                                            _showRecalculationAdvice(context);
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                      child:
                                          loadingButton2 ? CircularProgressIndicator() :Text(_localizations.markAsComplete)),
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
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: screenHeight * 0.1,
                    width: screenHeight * 0.1,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    )),
              ],
            ),
          ],
        );
      },
    );

    
    final result = await _controller.calculateSchedule();

    await _controller.getCalendarDay(stripTime(await NTP.now()));
    await _controller.getAllCalendarDaySessionNumbers();
    setState(() {
      date = instanceManager.sessionStorage.selectedDate;
    });
    Navigator.pop(context);
    switch (result) {
      case (1):
        showGreenSnackbar(context, _localizations.recalculationSuccessful);
        setState(() {
          instanceManager.sessionStorage.setNeedsRecalc(false);
        });

      case (-1):
        showRedSnackbar(context, 
            _localizations.recalcErrorBody);
        setState(() {
          instanceManager.sessionStorage.setNeedsRecalc(true);
        });

      case (0):
        await showErrorDialogForRecalc(
            context,
            _localizations.recalcNoTimeTitle,
            _localizations.recalcNoTimeBody,
            true);
        setState(() {
          instanceManager.sessionStorage.setNeedsRecalc(true);
        });
    }

    setState(() {
      _timesKey.currentState!.updateParent();
      needsRecalc = instanceManager.sessionStorage.needsRecalculation;
    });
  }

  void moveSheetUp() {
    _pageController.jumpToPage(0);
    _animationController.forward();
    setState(() {
      scrollSheetIsUp = true;
    });
  }

  void moveSheetDown() {
    _animationController.reverse();
    setState(() {
      scrollSheetIsUp = false;
      needsRecalc = instanceManager.sessionStorage.needsRecalculation;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    CalendarDayTimes events = CalendarDayTimes(
      key: _timesKey,
      needsRecalc: needsRecalc,
      updateParent: () {
        //logger.i(instanceManager.sessionStorage.needsRecalculation);
        day = instanceManager.sessionStorage.loadedCalendarDay;
        
          dayLoaded = !(instanceManager.sessionStorage.loadedCalendarDay.id ==
              'Placeholder');
        
      },
    );

    var availablitySlidingPage = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          //color: Colors.yellow,
          curve: Curves.decelerate,
          duration: scrollUpTime,
          height: scrollSheetIsUp ? screenHeight * 0.8 : 0,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              padding: EdgeInsets.only(top: 10),
              child: ClipShadowPath(
                shadow: const Shadow(
                    blurRadius: 10, color: Color.fromARGB(255, 222, 222, 222)),
                clipper: CustomShapeClipper(),
                child: Container(
                  height: screenHeight * 0.8,
                  width: screenWidth,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Container(
                          width: screenWidth / 6,
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.02,
                              left: screenWidth * 0.02,
                              right: screenWidth * 0.02),
                          child: RotationTransition(
                            turns: Tween<double>(begin: 0.0, end: 0.5)
                                .animate(_animationController),
                            child: Icon(Icons.keyboard_arrow_up),
                          ),
                        ),
                        onTap: () {
                          scrollSheetIsUp ? moveSheetDown() : moveSheetUp();
                        },
                      ),
                      Container(
                          padding: EdgeInsets.only(top: screenHeight * 0.04),
                          height: screenHeight * 0.73,
                          child: GeneralAvailabilityView(
                              pageController: _pageController))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 1,
        padding: false,
        body: Stack(
          children: [
            Container(
              //padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              height: screenHeight * 0.82,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 15),
                    child: CalendarTimeline(
                      initialDate: date,
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      onDateSelected: (newDate) async {
                        await loadDay(newDate, context, _localizations);
                      },
                      leftMargin: 20,
                      monthColor: Colors.blueGrey,
                      dayColor: Colors.teal[200],
                      activeDayColor: Colors.white,
                      activeBackgroundDayColor: Color.fromARGB(255, 33, 33, 33),
                      dotsColor: Color.fromARGB(255, 100, 100, 100),
                      locale: Localizations.localeOf(context).countryCode,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) async {
                        if (details.primaryVelocity! > 0) {
                          // Swiped right
                          await loadDay(instanceManager.sessionStorage.selectedDate.subtract(Duration(days:1)), context, _localizations);
                        } else if (details.primaryVelocity! < 0) {
                          // Swiped left
                          await loadDay(instanceManager.sessionStorage.selectedDate.add(Duration(days:1)), context, _localizations);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: dayLoaded
                            ? events
                            : Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                    horizontal: screenHeight * 0.007),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        child: Container(
                                      height: screenWidth * 0.1,
                                      width: screenWidth * 0.1,
                                      child: const CircularProgressIndicator(
                                        color: Colors.black12,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CalculatePlanButton(
                          recalcTime: recalcTime,
                          screenWidth: screenWidth,
                          backgroundColor: backgroundColor,
                          needsRecalc: needsRecalc,
                          titleGrey: titleGrey,
                          localizations: _localizations,
                          handleScheduleCalculation: () {
                            handleScheduleCalculation(context, _localizations);
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            logger.i('tapped');

                            moveSheetUp();
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         RestrictionsDetailView(),
                            //   ),
                            // );
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
                  ),
                ],
              ),
            ),
            availablitySlidingPage
          ],
        ));
  }

  Future<void> loadDay(DateTime newDate, BuildContext context, AppLocalizations _localizations) async {
    if (!dayLoaded) return;
    setState(() {
      dayLoaded = false;
      date = newDate;
    });
    
    if (!await _controller.getCalendarDay(newDate))
       showRedSnackbar(context, _localizations.errorLoadingDay);
    setState(() {
      dayLoaded = true;
      date = instanceManager.sessionStorage.selectedDate;
    });
    return;
  }
}

class CalculatePlanButton extends StatefulWidget {
  CalculatePlanButton({
    super.key,
    required this.recalcTime,
    required this.screenWidth,
    required this.backgroundColor,
    required this.needsRecalc,
    required this.titleGrey,
    required AppLocalizations localizations,
    required this.handleScheduleCalculation,
  }) : _localizations = localizations;

  final Duration recalcTime;
  final double screenWidth;
  final Color backgroundColor;
  final bool needsRecalc;
  final Color titleGrey;
  final AppLocalizations _localizations;
  final Function handleScheduleCalculation;

  @override
  State<CalculatePlanButton> createState() => _CalculatePlanButtonState();
}

class _CalculatePlanButtonState extends State<CalculatePlanButton> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!loading) {
          logger.i('tapped');
          setState(() {
            loading = true;
          });
          await widget.handleScheduleCalculation();
          //await Future.delayed(Duration(seconds: 5));
          setState(() {
            loading = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: widget.recalcTime,
        width: widget.screenWidth * 0.35,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
          // boxShadow: widget.needsRecalc
          //     ? [
          //         BoxShadow(
          //           color: Colors.grey.withOpacity(0.5), // Shadow color
          //           spreadRadius: 3, // Spread of the shadow
          //           blurRadius: 7, // Blur radius of the shadow
          //           offset: const Offset(0, 0), // Offset of the shadow
          //         ),
          //       ]
          //     : [],
        ),
        child: Row(
          children: [
            Container(
              width: widget.screenWidth * 0.12,
              height: widget.screenWidth * 0.12,
              child: !loading
                  ? Icon(Icons.calculate,
                      color:
                          widget.needsRecalc ? Colors.amber : widget.titleGrey,
                      size: widget.screenWidth * 0.12)
                  : Container(
                      padding: EdgeInsets.all(widget.screenWidth * 0.02),
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                      )),
            ),
            const SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                  widget.needsRecalc
                      ? widget._localizations.updatePlan
                      : widget._localizations.calculatePlan,
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: widget.needsRecalc
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: widget.needsRecalc ? Colors.amber : widget.titleGrey,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
