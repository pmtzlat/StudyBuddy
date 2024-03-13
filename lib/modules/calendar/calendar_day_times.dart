import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/common_widgets/exam_time_slot_card.dart';
import 'package:study_buddy/common_widgets/reload_button.dart';
import 'package:study_buddy/common_widgets/time_slot_card.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/general_utils.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarDayTimes extends StatefulWidget {
  Function updateParent;
  bool needsRecalc;
  CalendarDayTimes({
    required Key key,
    required this.updateParent,
    required this.needsRecalc,
  }) : super(key: key);

  @override
  State<CalendarDayTimes> createState() => CalendarDayTimesState();
}

class CalendarDayTimesState extends State<CalendarDayTimes> {
  final _controller = instanceManager.calendarController;
  final dayFormKey = GlobalKey<FormBuilderState>();
  final backgroundColor = Colors.transparent;
  late Color? dayHasExam;
  // late List<double>? colorStops;
  // late List<Color> colorsGradient;

  @override
  void initState() {
    super.initState();
    dayHasExam = instanceManager.examsController
        .getExamColorIfDateMatches(instanceManager.sessionStorage.selectedDate);
  }

  void updateParent() {
    logger.i('Calendar Day Times: updateParents');

    widget.updateParent();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015, horizontal: screenHeight * 0.007),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
            // stops: colorStops,
            // colors: colorsGradient),
            stops: const [0.2, 0.3],
            colors: widget.needsRecalc
                ? [Colors.amber, Colors.white.withOpacity(0.0)]
                : [backgroundColor, backgroundColor]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: widget.needsRecalc ? screenHeight * 0.09 : 0,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              reverse: true,
              child: Container(
                  width: double.infinity,
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
                          color: Colors.black, size: screenHeight * 0.05),
                    ],
                  )),
            ),
          ),
          TimeShower(
            updateAllParents: updateParent,
          )
        ],
      ),
    );
  }
}

class TimeShower extends StatefulWidget {
  TimeShower({super.key, required this.updateAllParents});

  final Function updateAllParents;

  @override
  State<TimeShower> createState() => _TimeShowerState();
}

class _TimeShowerState extends State<TimeShower> {
  final _controller = instanceManager.calendarController;

  void updateParents() {
    logger.i('TimeShower: updateParents');
    widget.updateAllParents();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    List<ExamModel> examsInDay = filterExamsByDate(
        instanceManager.sessionStorage.savedExams,
        instanceManager.sessionStorage.selectedDate);

    return (instanceManager
                .sessionStorage.loadedCalendarDay.timeSlots.isEmpty &&
            examsInDay.isEmpty)
        ? Expanded(
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _localizations.noTimeSlotsInDay,
                    style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        letterSpacing: 1),
                  )
                ]),
          )
        : Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                  itemCount: instanceManager
                          .sessionStorage.loadedCalendarDay.timeSlots.length +
                      examsInDay.length,
                  itemBuilder: (context, index) {
                    if (index < examsInDay.length) {
                      // Display dynamic entries at the start
                      ExamModel examToShow = examsInDay[index];
                      return ExamTimeSlotCard(exam: examToShow);
                    } else {
                      // Display original list entries after dynamic entries
                      final originalIndex = index - examsInDay.length;
                      return TimeSlotCard(index: originalIndex);
                    }
                  }),
            ),
          );
  }
}
