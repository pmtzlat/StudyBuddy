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
  DateTime date = instanceManager.sessionStorage.currentDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  bool loading = false;
  late DayModel customDay;
  late List<TimeSlotModel> timeSlotList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customDay = instanceManager.sessionStorage.customDays.firstWhere(
        (element) => element.date == date,
        orElse: () => DayModel(weekday: date.weekday, date: date, id: 'empty'));
    timeSlotList = customDay.times;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initStateGetGaps();
    });

    loading = true;
  }

  void initStateGetGaps() async {
    await customDay.getGaps();
    timeSlotList = customDay.times;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
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
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(_localizations.editCustomDays, style: TextStyle()),
            ),
            TableCalendar(
              focusedDay: date,
              firstDay: DateTime.now().subtract(Duration(days: 365)),
              lastDay: DateTime.now().add(Duration(days: 365)),
              calendarFormat: _calendarFormat,
              headerStyle: const HeaderStyle(formatButtonShowsNext: false),
              selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.

                // Using `isSameDay` is recommended to disregard
                // the time-part of compared DateTime objects.
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
                  customDay = instanceManager.sessionStorage.customDays
                      .firstWhere((element) => element.date == date,
                          orElse: () => DayModel(
                              weekday: date.weekday, date: date, id: 'empty'));
                  await customDay.getGaps();

                  setState(() {
                    timeSlotList = customDay.times;
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
            ),

            Container(
              width: screenWidth,
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: timeSlotList.isNotEmpty
                  ? Container(
                      child: !loading
                          ? MediaQuery.removePadding(
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
                                      key: Key(timeSlot.id),
                                      onDismissed: (direction) async {
                                        setState(() {
                                          timeSlotList.removeAt(index);
                                        });
                                        try {
                                          final res = await _controller
                                              .updateCustomDay(customDay, null);
                                          if (res != 1) {
                                            showRedSnackbar(
                                                context,
                                                _localizations
                                                    .errorDeletingGap);
                                          }
                                        } catch (e) {
                                          logger.e('error deleting gap: $e');
                                          showRedSnackbar(context,
                                              _localizations.errorDeletingGap);
                                        }
                                        await _controller.getCustomDays();
                                        

                                        customDay = instanceManager
                                            .sessionStorage.customDays
                                            .firstWhere(
                                                (element) =>
                                                    element.date == date,
                                                orElse: () => DayModel(
                                                    weekday: date.weekday,
                                                    date: date,
                                                    id: 'empty'));
                                        await customDay.getGaps();
                                        setState(() {
                                          timeSlotList = customDay.times;
                                        });
                                      },
                                      child: Card(
                                          elevation: 0,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 92, 107, 192)),
                                            child: Padding(
                                                padding: EdgeInsets.all(
                                                    screenWidth * 0.02),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        '${timeSlot.timeOfDayToString(timeSlot.startTime)} - ${timeSlot.timeOfDayToString(timeSlot.endTime)}',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.05,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300)),
                                                  ],
                                                )),
                                          )),
                                    );
                                  }))
                          : Container(
                              height: screenWidth * 0.1,
                              width: screenWidth * 0.1,
                              child: CircularProgressIndicator()))
                  : Center(
                      child: Text(
                        _localizations.nothingHereYet,
                        style: TextStyle(
                            fontSize: screenWidth * 0.05, color: Colors.grey),
                      ),
                    ),
            ),

            Center(
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  bool wrongDatesMessageShown = false;
                  final restraintFormKey = GlobalKey<FormBuilderState>();

                  await showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(context)
                        .modalBarrierDismissLabel,
                    barrierColor: Colors.black.withOpacity(0.5),

                    transitionDuration: Duration(milliseconds: 200),

                    // Create the dialog's content
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return GapSelector(
                        color: const Color.fromARGB(255, 0, 85, 150),
                        day: customDay,
                        updateParent: () async {
                          try {
                            customDay = instanceManager
                                .sessionStorage.customDays
                                .firstWhere((element) => element.date == date,
                                    orElse: () => DayModel(
                                        weekday: date.weekday, date: date));

                            customDay = instanceManager
                                            .sessionStorage.customDays
                                            .firstWhere(
                                                (element) =>
                                                    element.date == date,
                                                orElse: () => DayModel(
                                                    weekday: date.weekday,
                                                    date: date,
                                                    id: 'empty'));
                                        await customDay.getGaps();
                          } catch (e) {
                            logger.e('Error adding/editing custom day: $e');
                          }
                          

                          setState(() {
                            timeSlotList = customDay.times;
                          });
                        },
                        generalOrCustomDay: 'custom',
                      );
                    },
                  );
                },
              ),
            ),

            // Title(
            //   color: Colors.black,
            //   child: Text(_localizations.customDays),
            // ),
            // Center(
            //   child: IconButton(
            //     icon: Icon(Icons.add),
            //     onPressed: () {
            //       showGeneralDialog(
            //           context: context,
            //           barrierDismissible: true,
            //           barrierLabel: MaterialLocalizations.of(context)
            //               .modalBarrierDismissLabel,
            //           barrierColor: Colors.black.withOpacity(0.5),
            //           transitionDuration: Duration(milliseconds: 200),
            //           pageBuilder: (context, animation, secondaryAnimation) {
            //             return AddCustomDayView(refreshParent: refresh);
            //           });
            //     },
            //   ),
            // ),
            // Expanded(
            //     child: ListView.builder(
            //   scrollDirection: Axis.vertical,
            //   shrinkWrap: true,
            //   itemCount: instanceManager.sessionStorage.activeCustomDays.length,
            //   itemBuilder: (context, index) {
            //     var day = instanceManager.sessionStorage.activeCustomDays[index];
            //     return GestureDetector(
            //       onTap: () async {
            //         await _controller.getTimeSlotsForCustomDay(day);

            //         showGeneralDialog(
            //             context: context,
            //             barrierDismissible: true,
            //             barrierLabel: MaterialLocalizations.of(context)
            //                 .modalBarrierDismissLabel,
            //             barrierColor: Colors.black.withOpacity(0.5),
            //             transitionDuration: Duration(milliseconds: 200),
            //             pageBuilder: (context, animation, secondaryAnimation) {
            //               return CustomDayDetailView(
            //                 customDay: day,
            //               );
            //             });
            //       },
            //       child: Card(
            //         color: Colors.orange,
            //         child: Padding(
            //             padding:
            //                 EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text(DateFormat("d MMMM, y").format(day.date)),
            //                 IconButton(
            //                     onPressed: () async {
            //                       instanceManager.sessionStorage.activeCustomDays
            //                           .removeAt(index);
            //                       final res =
            //                           await _controller.deleteCustomDay(day.id);
            //                       if (res == -1) {
            //                         showRedSnackbar(context,
            //                             _localizations.errorDeletingCustomDay);
            //                       }

            //                       setState(() {});
            //                     },
            //                     icon: Icon(Icons.delete))
            //               ],
            //             )),
            //       ),
            //     );
            //   },
            // ))
          ],
        ),
      ),
    );
  }

  void refresh() async {
    await _controller.getCustomDays();
    setState(() {});
  }
}
