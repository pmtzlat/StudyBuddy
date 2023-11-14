import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class TimeSlotCard extends StatefulWidget {
  final TimeSlot timeSlot;
  final Function updateParent;
  const TimeSlotCard(
      {super.key, required TimeSlot this.timeSlot, required this.updateParent});

  @override
  State<TimeSlotCard> createState() => _TimeSlotCardState();
}

class _TimeSlotCardState extends State<TimeSlotCard> {
  final _controller = instanceManager.calendarController;
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    Widget checkBox(bool checked) {
      return GestureDetector(
        onTap: () async {
          if (widget.timeSlot.completed == false) {
            if (await _controller.markTimeSlotAsComplete(
                instanceManager.sessionStorage.loadedCalendarDay.id,
                widget.timeSlot)==1)
              await _controller
                  .getCalendarDay(instanceManager.sessionStorage.currentDay);
          } else {
            if (await _controller.markTimeSlotAsIncomplete(
                instanceManager.sessionStorage.loadedCalendarDay,
                widget.timeSlot)==1)
              await _controller
                  .getCalendarDay(instanceManager.sessionStorage.currentDay);
          }

          widget.updateParent();
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
