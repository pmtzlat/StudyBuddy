import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
  var checkboxMatrix = instanceManager.sessionStorage.checkboxMatrix;

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
          checkboxList: checkboxMatrix[i],
        ),
      );
    }

    return PageView(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
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
  final List<bool> checkboxList;
  const DayForm(
      {super.key,
      required String this.day,
      required this.pageController,
      required this.checkboxList});

  @override
  State<DayForm> createState() => _DayFormState();
}

class _DayFormState extends State<DayForm> {
  List<FormBuilderFieldOption<String>> hourOptions = [];

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    List<Widget> hourWidgets = [];
    for (int hour = 0; hour < 24; hour++) {
      String hourString = hour.toString().padLeft(2, '0') + ":00";
      hourWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
              value: widget.checkboxList[hour],
              onChanged: (newValue) {
                setState(() {
                  widget.checkboxList[hour] = newValue!;
                });
              }),
          SizedBox(
            width: 20,
          ),
          Text(hourString)
        ],
      ));
    }
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: hourWidgets),
            ),
          )
        ],
      ),
    );
  }
}
