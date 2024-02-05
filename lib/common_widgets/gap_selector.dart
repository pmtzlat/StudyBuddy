import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GapSelector extends StatefulWidget {
  Function updateParent;
  Color color;
  String generalOrCustomDay;
  DayModel day;
  GapSelector(
      {super.key,
      required this.day,
      required this.generalOrCustomDay,
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
                                          try {
                                            if (restraintFormKey.currentState!
                                                .validate()) {
                                              restraintFormKey.currentState!
                                                  .save();
                                              if (handleInputDates(
                                                  restraintFormKey)) {
                                                setState(() {
                                                  loading = true;
                                                });
                                                int res = 1;
                                                if (widget.generalOrCustomDay ==
                                                    'general') {
                                                  res =
                                                      await _controller.addGap(
                                                          restraintFormKey,
                                                          widget.day.weekday,
                                                          widget.day.times,);
                                                  logger.i('Added gap!');
                                                  await _controller.getGaps();
                                                } else {
                                                  res = await _controller
                                                      .updateCustomDay(widget.day,
                                                          restraintFormKey
                                                          );
                                                  logger.i('Added gap!');
                                                  await _controller
                                                      .getCustomDays();
                                                }
                                                

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
                                          } catch (e) {
                                            logger.e(
                                                'Error in gapSelector.done: $e');
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
