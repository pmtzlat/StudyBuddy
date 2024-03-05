import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/common_widgets/gap_selector.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/general_utils.dart';

class HourPickerForm extends StatefulWidget {
  const HourPickerForm({super.key});

  @override
  State<HourPickerForm> createState() => _HourPickerFormState();
}

class _HourPickerFormState extends State<HourPickerForm> {
  final PageController _pageController =
      PageController(initialPage: instanceManager.sessionStorage.savedWeekday);

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var weekdays = [
      _localizations.monday,
      _localizations.tuesday,
      _localizations.wednesday,
      _localizations.thursday,
      _localizations.friday,
      _localizations.saturday,
      _localizations.sunday,
    ];
    List<Widget> dayFormWidgets = [];
    for (int i = 0; i < weekdays.length; i++) {
      dayFormWidgets.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: DayForm(
              dayNum: i,
              dayString: weekdays[i],
              pageController: _pageController,
              color: colorOptions[i]),
        ),
      );
    }

    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      children: dayFormWidgets,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class DayForm extends StatefulWidget {
  final String dayString;
  final PageController pageController;
  final Color color;
  final int dayNum;
  const DayForm(
      {super.key,
      required String this.dayString,
      required this.pageController,
      required this.dayNum,
      required this.color});

  @override
  State<DayForm> createState() => _DayFormState();
}

class _DayFormState extends State<DayForm> {
  final _controller = instanceManager.calendarController;
  late List<TimeSlotModel> timeSlotList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeSlotList = instanceManager.sessionStorage.weeklyGaps[widget.dayNum];
  }

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    final daysStrToNum = {
      _localizations.monday: 0,
      _localizations.tuesday: 1,
      _localizations.wednesday: 2,
      _localizations.thursday: 3,
      _localizations.friday: 4,
      _localizations.saturday: 5,
      _localizations.sunday: 6,
    };

    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final color = widget.color;
    final darkerColor = darken(color, 0.1);

    Future<void> showPopUp(int weekday, Function updateParent) async {
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
            color: color,
            day: DayModel(weekday: weekday, date: DateTime.now(), times: timeSlotList),
            updateParent: updateParent,
            generalOrCustomDay: 'general',
          );
        },
      );
    }

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.dayString != 'Monday'
                  ? IconButton(
                      onPressed: () {
                        instanceManager.sessionStorage.savedWeekday--;
                        setState(() {});
                        widget.pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      icon: Icon(Icons.chevron_left_rounded),
                    )
                  : IconButton(
                      onPressed: () {},
                      splashColor: Colors.transparent, // Disable splash effect
                      highlightColor:
                          Colors.transparent, // Disable highlight effect
                      icon:
                          Icon(Icons.chevron_left_rounded, color: Colors.white),
                    ),
              Text('${widget.dayString}'),
              widget.dayString != 'Sunday'
                  ? IconButton(
                      onPressed: () {
                        instanceManager.sessionStorage.savedWeekday++;
                        setState(() {});
                        widget.pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      icon: Icon(Icons.chevron_right_rounded),
                    )
                  : IconButton(
                      onPressed: () {},
                      splashColor: Colors.transparent, // Disable splash effect
                      highlightColor:
                          Colors.transparent, // Disable highlight effect
                      icon: Icon(Icons.chevron_right_rounded,
                          color: Colors.white),
                    ),
            ],
          ),
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: timeSlotList.isEmpty
                  ? Container(
                      key: Key('0'),
                      padding: EdgeInsets.only(top: screenWidth * 0.03),
                      child: Text(
                        _localizations.swipeToDelete,
                        style: TextStyle(
                            color: Colors.transparent,
                            fontSize: screenWidth * 0.035),
                      ))
                  : Container(
                      key: Key('1'),
                      padding: EdgeInsets.only(top: screenWidth * 0.03),
                      child: Text(
                        _localizations.swipeToDelete,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 165, 165, 165),
                            fontSize: screenWidth * 0.035),
                      ))),
          Flexible(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
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
                          await _controller.deleteGap(timeSlot);

                          if(!instanceManager.sessionStorage.gettingAllGaps){
                          instanceManager.sessionStorage.gettingAllGaps = true;
                          await Future.delayed(Duration(seconds:10));
                          await _controller.getGapsForDay(widget.dayNum+1);
                          instanceManager.sessionStorage.gettingAllGaps = false;

                          }
                          
                          
                        } catch (e) {
                          
                           showRedSnackbar(context, _localizations.errorDeletingGap);
                          await _controller.getGapsForDay(widget.dayNum+1);
                          
                        }
                        
                        
                        setState(() {
                          timeSlotList = instanceManager
                              .sessionStorage.weeklyGaps[widget.dayNum];
                        });
                      },
                      child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  end: Alignment.bottomLeft,
                                  begin: Alignment.topRight,
                                  //stops: [ 0.1, 0.9],
                                  colors: [color, darkerColor]),
                            ),
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
                  }),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.025,
          ),
          Center(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await showPopUp((daysStrToNum[widget.dayString])! + 1, () {
                  setState(() {
                    timeSlotList = instanceManager.sessionStorage
                        .weeklyGaps[daysStrToNum[widget.dayString]];
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

