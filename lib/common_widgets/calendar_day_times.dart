import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/time_slot_card.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarDayTimes extends StatefulWidget {
  final Day day;
  const CalendarDayTimes({super.key, required this.day});

  @override
  State<CalendarDayTimes> createState() => _CalendarDayTimesState();
}

class _CalendarDayTimesState extends State<CalendarDayTimes> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    final _localizations = AppLocalizations.of(context)!;
    final date = widget.day.date;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('${date.day} - ${date.month} - ${date.year}'),
        Container(
          height: screenHeight * 0.5,
          child: widget.day.times.isEmpty
              ? Center(child: Text(_localizations.noTimeSlotsInDay))
              : MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: ListView.builder(
                      itemCount: widget.day.times.length,
                      itemBuilder: (context, index) {
                        var timeSlot = widget.day.times[index];
                        return TimeSlotCard(timeSlot: timeSlot);
                      }),
                ),
        )
      ],
    );
  }
}
