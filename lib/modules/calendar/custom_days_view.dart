import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/common_widgets/gap_selector.dart';
import 'package:study_buddy/common_widgets/hour_picker_form.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/utils/general_utils.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomDaysView extends StatefulWidget {
  PageController pageController;
  CustomDaysView({super.key, required this.pageController});

  @override
  State<CustomDaysView> createState() => _CustomDaysViewState();
}

class _CustomDaysViewState extends State<CustomDaysView> {
  final _controller = instanceManager.calendarController;
  DateTime date = instanceManager.sessionStorage.selectedDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  bool loading = false;
  late DayModel customDay;
  late List<TimeSlotModel> timeSlotList;
  static GlobalKey<NavigatorState> navKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customDay = instanceManager.sessionStorage.customDays.firstWhere(
        (element) => element.date == date,
        orElse: () => DayModel(weekday: date.weekday, date: date, id: 'empty'));
    timeSlotList = customDay.timeSlots;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initStateGetGaps();
    });

    loading = true;
  }

  void initStateGetGaps() async {
    await customDay.getGaps();
    timeSlotList = customDay.timeSlots;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    var timeSlotsListView = MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: timeSlotList.length,
            itemBuilder: (context, index) {
              final timeSlot = timeSlotList[index];

              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) async {
                  setState(() {
                    timeSlotList.removeAt(index);
                  });
                  

                  try {
                    if (await _controller.updateCustomDay(customDay, null) ==
                        -1) {
                      throw Exception;
                    }

                    if (!instanceManager.sessionStorage.gettingAllCustomDays) {
                      instanceManager.sessionStorage.gettingAllCustomDays =
                          true;

                      await Future.delayed(Duration(seconds: 5));
                      await _controller.getCustomDays();
                      await refreshCustomDay();

                      instanceManager.sessionStorage.gettingAllCustomDays =
                          false;
                    }
                  } catch (e) {
                    logger.e('Error updating custom day after dismissing: $e');
                    showRedSnackbar(context, _localizations.errorDeletingGap);
                    
                    await _controller.getCustomDays();
                    await refreshCustomDay();
                    
                   
                    
                  }

                  // Move the state update inside the try-catch block to ensure it happens after async operations
                  setState(() {
                    timeSlotList = customDay.timeSlots;
                  });
                  
                },
                child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 92, 107, 192)),
                      child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '${timeSlot.timeOfDayToString(timeSlot.startTime)} - ${timeSlot.timeOfDayToString(timeSlot.endTime)}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w300)),
                            ],
                          )),
                    )),
              );
            }));
    var tableCalendar = TableCalendar(
      focusedDay: date,
      firstDay: DateTime.now().subtract(Duration(days: 365)),
      lastDay: DateTime.now().add(Duration(days: 365)),
      calendarFormat: _calendarFormat,
      headerStyle: const HeaderStyle(formatButtonShowsNext: false),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          if (containsDayWithDate(
              instanceManager.sessionStorage.customDays, day)) {
            // Style for the 6th day of the month
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.04),
                ),
              ),
            );
          } else {
            // Default styling for other days
            return Container(
              margin: const EdgeInsets.all(4.0),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            );
          }
        },
        todayBuilder: (context, day, events) {
          if (isSameDay(day, DateTime.now())) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: !containsDayWithDate(
                      instanceManager.sessionStorage.customDays, day)
                  ? BoxDecoration(
                      color: const Color.fromARGB(255, 92, 107, 192)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.0),
                    )
                  : BoxDecoration(
                      color: Colors.orange.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !containsDayWithDate(
                              instanceManager.sessionStorage.customDays, day)
                          ? Color.fromARGB(255, 92, 107, 192)
                          : Colors.white),
                ),
              ),
            );
          }
        },
      ),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) async {
        if (!isSameDay(_selectedDay, selectedDay)) {
          // Call `setState()` when updating the selected day
          setState(() {
            _selectedDay = selectedDay;
            date = stripTime(focusedDay);
            loading = true;
          });

          customDay = instanceManager.sessionStorage.customDays.firstWhere(
              (element) => element.date == date,
              orElse: () =>
                  DayModel(weekday: date.weekday, date: date, id: 'empty'));

          try {
            await customDay.getGaps();
          } catch (e) {
            customDay = instanceManager.sessionStorage.customDays.firstWhere(
                (element) => element.date == date,
                orElse: () =>
                    DayModel(weekday: date.weekday, date: date, id: 'empty'));
          }

          setState(() {
            timeSlotList = customDay.timeSlots;
            loading = false;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          // Call `setState()` when updating calendar format
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        // No need to call `setState()` here
        date = focusedDay;
      },
    );
    var iconButton = IconButton(
      icon: Icon(Icons.add),
      onPressed: () async {
        bool wrongDatesMessageShown = false;
        final restraintFormKey = GlobalKey<FormBuilderState>();

        await showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black.withOpacity(0.5),

          transitionDuration: Duration(milliseconds: 200),

          // Create the dialog's content
          pageBuilder: (context, animation, secondaryAnimation) {
            return GapSelector(
              color: const Color.fromARGB(255, 0, 85, 150),
              day: customDay,
              updateParent: () async {
                try {
                  setState(() {
                    loading = true;
                  });

                  customDay = instanceManager.sessionStorage.customDays
                      .firstWhere((element) => element.date == date,
                          orElse: () => DayModel(
                              weekday: date.weekday, date: date, id: 'empty'));
                  await customDay.getGaps();
                } catch (e) {
                  logger.e('Error adding/editing custom day: $e');
                }

                setState(() {
                  timeSlotList = customDay.timeSlots;
                  loading = false;
                });
              },
              generalOrCustomDay: 'custom',
            );
          },
        );
      },
    );
    var loader = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: screenWidth * 0.1,
                  width: screenWidth * 0.1,
                  child: CircularProgressIndicator()),
            ],
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 8),
                child: ColoredLastTwoWords(
                    inputString: _localizations.editCustomDays,
                    firstColor: Colors.black,
                    lastTwoColor: Colors.orange),
              ),
              tableCalendar,
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.01),
                width: screenWidth,
                padding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.05,
                    horizontal: screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    Text(
                      formatDateTime(context, date),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.05,
                          color: Colors.grey),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    timeSlotList.isNotEmpty
                        ? Container(
                            child: Column(
                            children: [
                              Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    _localizations.swipeToDelete,
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: screenWidth * 0.035),
                                  )),
                              !loading ? timeSlotsListView : loader,
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),
                              Center(
                                child: iconButton,
                              ),
                            ],
                          ))
                        : Container(
                            child: Column(
                            children: [
                              !loading
                                  ? Center(
                                      child: Text(
                                        _localizations.nothingHereYet,
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.05,
                                            color: Colors.grey),
                                      ),
                                    )
                                  : loader,
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),
                              Center(
                                child: iconButton,
                              ),
                            ],
                          )),
                  ],
                ),
              ),
              TextButton(
                  onPressed: () async {
                    List<TimeSlotModel> preChangeTimeSlots = List.from(customDay.timeSlots);
                    try {
                      setState(() {
                        loading = true;
                      });

                      customDay.timeSlots = instanceManager.sessionStorage
                          .weeklyGaps[customDay.date.weekday - 1];
                      if(await _controller.updateCustomDay(customDay, null) == -1) throw Exception;
                      await _controller.getCustomDays();

                      customDay = instanceManager.sessionStorage.customDays
                          .firstWhere((element) => element.date == date,
                              orElse: () => DayModel(
                                  weekday: date.weekday,
                                  date: date,
                                  id: 'empty'));

                      await customDay.getGaps();
                    } catch (e) {
                      logger.e('Error adding/editing custom day: $e');
                      customDay.timeSlots = preChangeTimeSlots;
                      showRedSnackbar(context, _localizations.errorResettingToDefault);
                    }

                    setState(() {
                      timeSlotList = customDay.timeSlots;
                      loading = false;
                    });
                  },
                  child: Text(_localizations.resetToDefault))
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 15),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                  onTap: () {
                    widget.pageController.previousPage(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.decelerate);
                  },
                  child: Text(_localizations.backToWeeklyAvailability,
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> refreshCustomDay() async {
    customDay = instanceManager.sessionStorage.customDays.firstWhere(
        (element) => element.date == date,
        orElse: () => DayModel(weekday: date.weekday, date: date, id: 'empty'));
    await customDay.getGaps();
  }

  void refresh() async {
    await _controller.getCustomDays();
    setState(() {});
  }
}

class ColoredLastTwoWords extends StatelessWidget {
  final String inputString;
  final Color firstColor;
  final Color lastTwoColor;

  ColoredLastTwoWords({
    required this.inputString,
    required this.firstColor,
    required this.lastTwoColor,
  });

  @override
  Widget build(BuildContext context) {
    List<String> words = inputString.split(' ');

    if (words.length < 2) {
      // Handle cases where the string has fewer than two words
      return Text(inputString);
    }

    String firstPart = words.sublist(0, words.length - 3).join(' ');
    String lastTwoWords = words.sublist(words.length - 3).join(' ');

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: firstPart,
            style: TextStyle(color: firstColor),
          ),
          TextSpan(
            text: ' $lastTwoWords',
            style: TextStyle(color: lastTwoColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
