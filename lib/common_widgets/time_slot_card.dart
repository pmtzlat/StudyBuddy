import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/timer_widget.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimeSlotCard extends StatefulWidget {
  int index;

  TimeSlotCard({
    super.key,
    required this.index,
  });

  @override
  State<TimeSlotCard> createState() => _TimeSlotCardState();
}

class _TimeSlotCardState extends State<TimeSlotCard> {
  final _controller = instanceManager.calendarController;
  final openTime = Duration(milliseconds: 200);
  bool open = false;
  late bool checked;
  late TimeSlotModel timeSlot;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeSlot = instanceManager
        .sessionStorage.loadedCalendarDay.timeSlots[widget.index];
    checked = timeSlot.completed;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    final cardColor = timeSlot.examColor;
    final lighterColor = lighten(cardColor, .05);
    final darkerColor = darken(cardColor, .15);

    void update() {
      setState(() {});
    }

    Future<void> checkBox(bool checked) async {
      if (stripTime(DateTime.now()).isAfter(timeSlot.date!)) {
        showRedSnackbar(context, _localizations.editUnitCompletionInExamsPage);
        return;
      }
      try {
        await timeSlot.changeCompleteness(checked);
      } catch (e) {
        logger.e('Error changing completeness: $e');
      }

      instanceManager.sessionStorage.loadedCalendarDay.timeSlots[widget.index] =
          await _controller.getTimeSlot(timeSlot.id, timeSlot.dayID);

     

      setState(() {
        timeSlot = instanceManager
            .sessionStorage.loadedCalendarDay.timeSlots[widget.index];
      });
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: AnimatedContainer(
          duration: openTime,
          curve: Curves.decelerate,
          height: open ? screenHeight * 0.185 : screenHeight * 0.095,
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                end: Alignment.bottomLeft,
                begin: Alignment.topRight,
                //stops: [ 0.1, 0.9],
                colors: [cardColor, darkerColor]),
          ),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                GestureDetector(
                    onTap: () {
                      
                      setState(() {
                        open = !open;
                      });
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        color: Colors.transparent,
                        height: screenHeight * 0.08,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(timeSlot.examName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.06,
                                            fontWeight: FontWeight.bold)),
                                    Text(timeSlot.unitName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400))
                                  ],
                                ),
                                Column(
                                  // this column
                                  children: [
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.002),
                                        child: AnimatedSwitcher(
                                          duration: openTime,
                                          child: timeSlot.completed && !open
                                              ? Container(
                                                  key: ValueKey<int>(0),
                                                  width: screenWidth * 0.215,
                                                  height: screenHeight * 0.06,
                                                  // margin:
                                                  //     EdgeInsets.only(bottom: screenHeight * 0.005),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.done,
                                                        size:
                                                            screenWidth * 0.1,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  key: ValueKey<int>(1),
                                                  width: screenWidth * 0.215,
                                                  height: screenHeight * 0.06,
                                                  child: Text(
                                                      '${timeOfDayToStr(timeSlot.startTime)} - ${timeOfDayToStr(timeSlot.endTime)}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white)),
                                                ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ))),
                Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.03),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20.0)),
                          child: TextButton.icon(
                              onPressed: () async {
                                if (instanceManager
                                        .sessionStorage.selectedDate !=
                                    stripTime(DateTime.now())) {
                                  return showRedSnackbar(
                                      context,
                                      _localizations
                                          .cantStartSessionForFuture);
                                }
                                //bool completenessBefore = timeSlot.completed;
                                try {
                                  await showTimerDialog(context, timeSlot, widget.index);

                                  //after closing timer

                                  setState(() {
                                    timeSlot = instanceManager
                                        .sessionStorage
                                        .loadedCalendarDay
                                        .timeSlots[widget.index];
                                    checked = timeSlot.completed;
                                  });
                                  

                                  // try {
                                  //   await _controller
                                  //       .saveTimeStudied(timeSlot);
                                  //   if(timeSlot.completed != completenessBefore ) await _controller
                                  //       .updateTimeSlotCompleteness(
                                  //           timeSlot);
                                  // } catch (e) {
                                  //   logger.e(
                                  //       'Error saving timeSlot new data: $e');
                                  //   showRedSnackbar(
                                  //       context, _localizations.errorSaving);
                                  // }

                                  // newTimeSlot = await _controller.getTimeSlot(
                                  //     timeSlot.id,
                                  //     timeSlot.dayID);

                                  // setState(() {
                                  //   timeSlot = newTimeSlot;
                                  //   checked = timeSlot.completed;
                                  // });
                                } catch (e) {
                                  logger.e('Error updating timeSlot: $e');
                                  showRedSnackbar(
                                      context, _localizations.errorSaving);
                                }

                                //logger.i(newTimeSlot.getString());
                              },
                              icon: Icon(Icons.timer_outlined,
                                  color: Colors.white),
                              label: Text(
                                formatDurationNoWords(timeSlot.timeStudied),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05),
                              )),
                        ),
                        Row(
                          children: [
                            Text(_localizations.completed,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w400)),
                            Container(
                              padding: EdgeInsets.all(1),
                              child: Checkbox(
                                  visualDensity: VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  activeColor: Colors.black,
                                  checkColor: timeSlot
                                      .examColor, // Color of the checkmark
                                  fillColor:
                                      MaterialStateProperty.all(Colors.white),
                                  value: checked,
                                  onChanged: (bool? newValue) async {
                                    
                                    setState(() {
                                      checked = !checked;
                                    });
                                    try {
                                      await checkBox(newValue!);
                                    } catch (e) {
                                      logger.e(
                                          'Error changing timeslot state: $e');
                                      showRedSnackbar(
                                          context,
                                          _localizations
                                              .errorChangingTimeSlotCompletion);
                                    }

                                    setState(() {
                                      checked = timeSlot.completed;
                                    });
                                  }),
                            )
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          )),
    );
  }
}
