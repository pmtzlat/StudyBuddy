import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
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
              day: weekdays[i],
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
  final String day;
  final PageController pageController;
  final Color color;
  const DayForm(
      {super.key,
      required String this.day,
      required this.pageController,
      required this.color});

  @override
  State<DayForm> createState() => _DayFormState();
}

class _DayFormState extends State<DayForm> {
  final restraintFormKey = GlobalKey<FormBuilderState>();
  final _controller = instanceManager.calendarController;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    void showPopUp(int weekday) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.5),

        transitionDuration: Duration(milliseconds: 200),

        // Create the dialog's content
        pageBuilder: (context, animation, secondaryAnimation) {
          return Center(
            child: Card(
              color: Colors.orange,
              child: Container(
                padding: EdgeInsets.all(10),
                height: screenHeight * 0.28,
                width: screenWidth * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    Text(_localizations.addGap),
                    FormBuilder(
                      key: restraintFormKey,
                      child: Row(children: [
                        Expanded(
                          child: FormBuilderDateTimePicker(
                            name: 'startTime',
                            inputType: InputType.time,
                            format: DateFormat("HH:mm"),
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                        Text(' - '),
                        Expanded(
                          child: FormBuilderDateTimePicker(
                            name: 'endTime',
                            inputType: InputType.time,
                            format: DateFormat("HH:mm"),
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                      ]),
                    ),
                    IconButton(
                        onPressed: () async {
                          final res = await _controller.addGap(
                              restraintFormKey,
                              weekday,
                              instanceManager
                                  .sessionStorage.weeklyGaps[weekday - 1],
                              'generalGaps');
                          setState(() {});
                          if (res == -1) {
                            showRedSnackbar(
                                context, _localizations.errorAddingGap);
                          } else if (res == 0) {
                            showRedSnackbar(
                                context, _localizations.wrongInputGap);
                          }

                          await _controller.getGaps();
                          setState(() {});
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.check))
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    final daysStrToNum = {
      _localizations.monday: 0,
      _localizations.tuesday: 1,
      _localizations.wednesday: 2,
      _localizations.thursday: 3,
      _localizations.friday: 4,
      _localizations.saturday: 5,
      _localizations.sunday: 6,
    };

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.day != 'Monday'
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
              Text('${widget.day}'),
              widget.day != 'Sunday'
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
          SizedBox(
            height: screenHeight * 0.025,
          ),
          Flexible(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: instanceManager.sessionStorage
                      .weeklyGaps[daysStrToNum[widget.day]].length,
                  itemBuilder: (context, index) {
                    final timeSlot = instanceManager.sessionStorage
                        .weeklyGaps[daysStrToNum[widget.day]][index];
                    final color = widget.color;
                    final darkerColor = darken(color, 0.1);

                    return Card(
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
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.05),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${timeSlot.timeOfDayToString(timeSlot.startTime)} - ${timeSlot.timeOfDayToString(timeSlot.endTime)}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.05)),
                                  IconButton(
                                      onPressed: () async {
                                        instanceManager
                                            .sessionStorage
                                            .weeklyGaps[
                                                daysStrToNum[widget.day]]
                                            .removeAt(index);
                                        setState(() {});
                                        final res = await _controller
                                            .deleteGap(timeSlot);
                                        if (res != 1) {
                                          showRedSnackbar(context,
                                              _localizations.errorDeletingGap);
                                        }
                                        await _controller.getGaps();
                                        setState(() {
                                          instanceManager.sessionStorage
                                              .needsRecalculation = true;
                                        });
                                      },
                                      icon: Icon(Icons.delete,
                                          color: Colors.white))
                                ],
                              )),
                        ));
                  }),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.025,
          ),
          Center(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => showPopUp((daysStrToNum[widget.day])! + 1),
            ),
          ),
        ],
      ),
    );
  }
}
