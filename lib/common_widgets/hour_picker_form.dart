import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';

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
        DayForm(
          day: weekdays[i],
          pageController: _pageController,
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
  const DayForm(
      {super.key, required String this.day, required this.pageController});

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
                      icon: Icon(Icons.arrow_left),
                    )
                  : SizedBox(),
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
                      icon: Icon(Icons.arrow_right),
                    )
                  : SizedBox(),
            ],
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
          Expanded(
            child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: instanceManager.sessionStorage
                        .weeklyGaps[daysStrToNum[widget.day]].length,
                    itemBuilder: (context, index) {
                      final timeSlot = instanceManager.sessionStorage
                          .weeklyGaps[daysStrToNum[widget.day]][index];

                      return Card(
                        color: Colors.orange,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '${timeSlot.timeOfDayToString(timeSlot.startTime)} - ${timeSlot.timeOfDayToString(timeSlot.endTime)}'),
                                IconButton(
                                    onPressed: () async {
                                      instanceManager.sessionStorage
                                          .weeklyGaps[daysStrToNum[widget.day]]
                                          .removeAt(index);
                                      setState(() {});
                                      final res =
                                          await _controller.deleteGap(timeSlot);
                                      if (res != 1) {
                                        showRedSnackbar(context,
                                            _localizations.errorDeletingGap);
                                      }
                                      await _controller.getGaps();
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.delete))
                              ],
                            )),
                      );
                    }),
          )
        ],
      ),
    );
  }
}
