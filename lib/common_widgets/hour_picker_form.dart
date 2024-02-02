import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
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
  PageController _pageController =
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
              color: color, weekday: weekday, updateParent: updateParent);
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
                      icon:
                          Icon(Icons.chevron_left_rounded, color: Colors.white),
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
                          final res = await _controller.deleteGap(timeSlot);
                          if (res != 1) {
                            showRedSnackbar(
                                context, _localizations.errorDeletingGap);
                          }
                        } catch (e) {
                          logger.e('error deleting gap: $e');
                          showRedSnackbar(
                              context, _localizations.errorDeletingGap);
                        }
                        await _controller.getGaps();
                        setState(() {
                          timeSlotList = timeSlotList = instanceManager
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

class GapSelector extends StatefulWidget {
  int weekday;
  Function updateParent;
  Color color;
  GapSelector(
      {super.key,
      required this.weekday,
      required this.color,
      required this.updateParent});

  @override
  State<GapSelector> createState() => _GapSelectorState();
}

class _GapSelectorState extends State<GapSelector> {
  bool wrongDatesMessageShown = false;
  final restraintFormKey = GlobalKey<FormBuilderState>();
  final shakeKey = GlobalKey<ShakeWidgetState>();
  final _controller = instanceManager.calendarController;
  bool loading = false;

  bool handleInputDates(GlobalKey<FormBuilderState> key) {
    final startTime =
        dateTimeToTimeOfDay(key.currentState!.fields['startTime']!.value);
    var endTime =
        dateTimeToTimeOfDay(key.currentState!.fields['endTime']!.value);

    if (endTime.hour == 0 && endTime.minute == 0) {
      endTime = const TimeOfDay(hour: 23, minute: 59);
    }

    if (!isTimeBefore(startTime, endTime)) {
      return false;
    }
    return true;
  }

  Future<void> showWrongDatesMessage() async {
    setState(() {
      wrongDatesMessageShown = true;
    });

    await Future.delayed(Duration(seconds: 3), () {
      setState(() {
        wrongDatesMessageShown = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    Color color = widget.color;
    int weekday = widget.weekday;

    return Center(
      child: Card(
        color: Colors.white,
        child: Container(
          //padding: EdgeInsets.all(10),
          height: screenHeight * 0.28,
          width: screenWidth * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.zero, // Remove padding from the container
                      child: IconButton(
                        icon: Icon(Icons.cancel, color: Colors.grey),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        padding: EdgeInsets
                            .zero, // Remove padding from the IconButton
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_localizations.addGap,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w300)),
                            ],
                          ),
                          FormBuilder(
                            key: restraintFormKey,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 5, left: 7),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenWidth * 0.04))),
                                    width: screenWidth * 0.27,
                                    child: Center(
                                      child: FormBuilderDateTimePicker(
                                        name: 'startTime',
                                        inputType: InputType.time,
                                        format: DateFormat("HH:mm"),
                                        validator:
                                            FormBuilderValidators.required(),
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.09,
                                            color: color,
                                            fontWeight: FontWeight.bold),
                                        decoration:
                                            const InputDecoration.collapsed(
                                                hintText: '00:00',
                                                hintStyle: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 181, 181, 181))),
                                      ),
                                    ),
                                  ),
                                  Text(' - ',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: screenWidth * 0.1)),
                                  Container(
                                    width: screenWidth * 0.25,
                                    child: FormBuilderDateTimePicker(
                                      name: 'endTime',
                                      inputType: InputType.time,
                                      format: DateFormat("HH:mm"),
                                      validator:
                                          FormBuilderValidators.required(),
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.09,
                                          color: color,
                                          fontWeight: FontWeight.bold),
                                      decoration:
                                          const InputDecoration.collapsed(
                                              hintText: '00:00',
                                              hintStyle: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 181, 181, 181))),
                                    ),
                                  ),
                                ]),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: screenWidth * 0.4,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: wrongDatesMessageShown
                                      ? Text(
                                          key: Key('0'),
                                          _localizations.wrongInputGap,
                                          softWrap: true,
                                          maxLines: 2,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            color: Colors.redAccent,
                                          ))
                                      : Text(
                                          key: Key('1'),
                                          _localizations.wrongInputGap,
                                          softWrap: true,
                                          maxLines: 2,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            color: Colors.transparent,
                                          )),
                                ),
                              ),
                              IconButton(
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  onPressed: loading
                                      ? () {}
                                      : () async {
                                          if (restraintFormKey.currentState!
                                              .validate()) {
                                            restraintFormKey.currentState!
                                                .save();
                                            if (handleInputDates(
                                                restraintFormKey)) {
                                              setState(() {
                                                loading = true;
                                              });
                                              int res =
                                                  await _controller.addGap(
                                                      restraintFormKey,
                                                      weekday,
                                                      instanceManager
                                                              .sessionStorage
                                                              .weeklyGaps[
                                                          weekday - 1],
                                                      'generalGaps');
                                              logger.i('Added gap!');
                                              await _controller.getGaps();
                                              widget.updateParent();

                                              setState(() {
                                                loading = false;
                                              });
                                              Navigator.of(context).pop();
                                              if (res != 1) {
                                                showRedSnackbar(
                                                    context,
                                                    _localizations
                                                        .errorAddingGap);
                                              }
                                            } else {
                                              //shake

                                              showWrongDatesMessage();
                                              shakeKey.currentState?.shake();
                                            }
                                          }
                                        },
                                  icon: !loading
                                      ? ShakeMe(
                                          key: shakeKey,
                                          shakeOffset: 10,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.lightGreen,
                                            size: screenWidth * 0.1,
                                          ),
                                        )
                                      : CircularProgressIndicator(
                                          color: color,
                                        )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
