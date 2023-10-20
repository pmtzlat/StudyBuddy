import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/hour_picker_form.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/modules/calendar/loaded_calendar_view.dart';
import 'package:study_buddy/services/logging_service.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final _controller = instanceManager.calendarController;
  final page = 0;
  PageController _pageController = PageController(
      initialPage: instanceManager.sessionStorage.calendarBeginPage);
  final schedulePresent = instanceManager.sessionStorage.schedulePresent;

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    setState(() {});

    Widget page1 = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(AppLocalizations.of(context)!.calendarTitle),
                ElevatedButton(
                    onPressed: () {
                      _controller.moveToStageTwo();
                      nextPage();
                    },
                    child: Text(_localizations.configureCalendar)),
              ],
            ),
          ],
        )
      ],
    );

    Widget page2 = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(_localizations.chooseFreeSchedule),
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.6,
                    child: HourPickerForm()),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                    onPressed: () async {
                      _controller.moveToStageThree();
                      nextPage();

                      await _controller.addScheduleRestraints();
                      setState(() {});
                    },
                    icon: Icon(Icons.done),
                    label: Text(_localizations.calculateSchedule))
              ],
            ),
          ],
        ),
      ],
    );

    Widget page3 = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16.0),
          Text(
            _localizations.loadingSchedule,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );

    Widget page4 = LoadedCalendarView(notifyParent: refresh);

    switch (instanceManager.sessionStorage.schedulePresent) {
      case null:
        return instanceManager.scaffold.getScaffold(
            context: context,
            activeIndex: 2,
            body: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [page1, page2, page3, page4]));

      case -1:
        return instanceManager.scaffold.getScaffold(
            context: context,
            activeIndex: 2,
            body: Column(
              children: [
                Text('Error generating schedule.'),
                ElevatedButton.icon(
                    onPressed: () {
                      instanceManager.sessionStorage.schedulePresent = null;
                      setState(() {});
                      ;
                    },
                    icon: Icon(Icons.restart_alt),
                    label: Text(_localizations.tryAgain))
              ],
            ));
    }
    switch (instanceManager.sessionStorage.activeCourses.length) {
      case 0:
        return instanceManager.scaffold.getScaffold(
            context: context,
            activeIndex: 2,
            body: Title(
                color: Colors.black,
                child: Text(_localizations.inactiveCalendar)));
    }
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 2,
        body: LoadedCalendarView(notifyParent: refresh));
  }

  void nextPage() {
    _pageController.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    setState(() {});
  }

  void refresh() {
    setState(() {});
  }
}
