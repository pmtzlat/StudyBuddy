import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimeSlotCard extends StatefulWidget {
  final TimeSlot timeSlot;
  final Function updateAllParents;
  const TimeSlotCard(
      {super.key,
      required TimeSlot this.timeSlot,
      required this.updateAllParents});

  @override
  State<TimeSlotCard> createState() => _TimeSlotCardState();
}

class _TimeSlotCardState extends State<TimeSlotCard> {
  final _controller = instanceManager.calendarController;
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    final _localizations = AppLocalizations.of(context)!;

    Widget checkBox(bool checked) {
      return GestureDetector(
        onTap: () async {
          if (stripTime(DateTime.now()).isAfter(widget.timeSlot.date!)) {
            showRedSnackbar(
                context, _localizations.editUnitCompletionInCoursesPage);
            return;
          }
          if (widget.timeSlot.completed == false) {
            if (await _controller.markTimeSlotAsComplete(
                    instanceManager.sessionStorage.loadedCalendarDay.id,
                    widget.timeSlot) ==
                1)
              await _controller
                  .getCalendarDay(instanceManager.sessionStorage.currentDay);
          } else {
            if (await _controller.markTimeSlotAsIncomplete(
                    instanceManager.sessionStorage.loadedCalendarDay,
                    widget.timeSlot) ==
                1) {
              await _controller
                  .getCalendarDay(instanceManager.sessionStorage.currentDay);
            }
          }

          widget.updateAllParents();
        },
        child: (checked == true)
            ? Icon(Icons.check_box)
            : Icon(Icons.check_box_outline_blank),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Card(
        color: Colors.lightBlue,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          height: screenHeight * 0.1,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text(widget.timeSlot.courseName),
            Text(widget.timeSlot.unitName),
            Text(
                '${timeOfDayToStr(widget.timeSlot.startTime)} - ${timeOfDayToStr(widget.timeSlot.endTime)}'),
            checkBox(widget.timeSlot.completed)
          ]),
        ),
      ),
    );
  }
}
