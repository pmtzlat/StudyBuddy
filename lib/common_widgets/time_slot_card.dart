import 'package:flutter/material.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class TimeSlotCard extends StatefulWidget {
  final TimeSlot timeSlot;
  const TimeSlotCard({super.key, required TimeSlot this.timeSlot});

  @override
  State<TimeSlotCard> createState() => _TimeSlotCardState();
}

class _TimeSlotCardState extends State<TimeSlotCard> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Card(
          color: Colors.lightBlue,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            height: screenHeight * 0.1,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(widget.timeSlot.courseName),
                  Text(widget.timeSlot.unitName),
                  Text(
                      '${timeOfDayToStr(widget.timeSlot.startTime)} - ${timeOfDayToStr(widget.timeSlot.endTime)}')
                ]),
          ),
        ),
      ),
    );
    ;
  }
}
