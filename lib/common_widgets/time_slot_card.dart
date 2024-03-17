import 'dart:math';

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
  late bool checked;
  late TimeSlotModel timeSlot;
  bool changing = false;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    final timeSize = screenWidth * 0.04;
    final timeColor = Color.fromARGB(255, 109, 109, 109);
    final timeStyle = TextStyle(fontSize: timeSize, color: timeColor);
    

    timeSlot = instanceManager
        .sessionStorage.loadedCalendarDay.timeSlots[widget.index];
    logger.f('timeSlot loaded: ${durationToHours(timeSlot.duration)}');
    if (!changing) checked = timeSlot.completed;

    void update() {
      setState(() {});
    }

    Future<void> checkBox(bool checked) async {
      try {
        if (stripTime(DateTime.now()).isAfter(timeSlot.date!)) {
          showRedSnackbar(
              context, _localizations.editUnitCompletionInExamsPage);
          return;
        }
        if (instanceManager.sessionStorage.needsRecalculation) {
          showRedSnackbar(context, _localizations.cantWithNeedsUpdate);
          return;
        }

        await timeSlot.changeCompleteness(checked);
      } catch (e) {
        logger.e('Error changing completeness: $e');
        showRedSnackbar(context, _localizations.error);
      }

      instanceManager.sessionStorage.loadedCalendarDay.timeSlots[widget.index] =
          await _controller.getTimeSlot(timeSlot.id, timeSlot.dayID);

      setState(() {
        timeSlot = instanceManager
            .sessionStorage.loadedCalendarDay.timeSlots[widget.index];
      });
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: max(screenHeight * 0.18,
                    screenHeight * 0.18 * durationToHours(timeSlot.duration)) +
                screenHeight * 0.01,
            padding: EdgeInsets.symmetric(
                vertical: 20, horizontal: screenWidth * 0.025),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeOfDayToStr(timeSlot.startTime),
                  style: timeStyle,
                ),
                Text(timeOfDayToStr(timeSlot.endTime), style: timeStyle)
              ],
            ),
          ),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                  height: max(screenHeight * 0.18,
                      screenHeight * 0.18 * durationToHours(timeSlot.duration)),
                  padding: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        end: Alignment.bottomLeft,
                        begin: Alignment.topRight,
                        //stops: [ 0.1, 0.9],
                        colors: [
                          increaseColorSaturation(timeSlot.examColor, .2),
                          darken(timeSlot.examColor, 0.15)
                        ]),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.01,
                        right: screenWidth * 0.03,
                        left: screenWidth * 0.03),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: screenWidth * 0.5,
                                    child: Text(timeSlot.examName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.056,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    width: screenWidth * 0.4,
                                    child: Text(timeSlot.unitName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.04,
                                        )),
                                  ),
                                ],
                              ),
                              Container(
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.01),
                                child: Transform.scale(
                                  scale: 2.0,
                                  child: Checkbox(
                                      visualDensity: VisualDensity(
                                          horizontal: -4, vertical: -4),
                                      activeColor: Colors.black,
                                      checkColor: Colors
                                          .white, // Color of the checkmark
                                      fillColor: MaterialStateProperty.all(
                                          Colors.white.withOpacity(0.3)),
                                      value: checked,
                                      onChanged: (bool? newValue) async {
                                        setState(() {
                                          changing = true;
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
                                          changing = false;
                                          checked = timeSlot.completed;
                                        });
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12)),
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
                                          logger.i(timeSlot.getString());
                                          await showTimerDialog(
                                              context, timeSlot, widget.index);

                                          //after closing timer

                                          setState(() {
                                            timeSlot = instanceManager
                                                .sessionStorage
                                                .loadedCalendarDay
                                                .timeSlots[widget.index];
                                            checked = timeSlot.completed;
                                          });
                                        } catch (e) {
                                          logger
                                              .e('Error updating timeSlot: $e');
                                          showRedSnackbar(context,
                                              _localizations.errorSaving);
                                        }

                                        //logger.i(newTimeSlot.getString());
                                      },
                                      icon: Icon(Icons.timer_outlined,
                                          color: Colors.white),
                                      label: Text(
                                        formatDurationNoWords(
                                            timeSlot.timeStudied),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.05),
                                      )),
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     // Text(_localizations.completed,
                              //     //     style: TextStyle(
                              //     //         color: Colors.white,
                              //     //         fontSize: screenWidth * 0.05,
                              //     //         fontWeight: FontWeight.w400)),
                              //     Container(
                              //       padding: EdgeInsets.symmetric(horizontal: screenWidth*0.03, vertical: screenHeight*0.01),
                              //       child: sizex
                              //     )
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
