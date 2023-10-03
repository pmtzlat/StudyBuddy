import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/hour_picker_form.dart';
import 'package:study_buddy/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';




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

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

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
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.decelerate);
                      setState(() {});
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
                    onPressed: () {
                      _controller.moveToStageThree();
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.decelerate);
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

    
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 2,
        body: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [page1, page2, LoadingSchedule(page3:page3)]));
  }
}

class LoadingSchedule extends StatefulWidget {
  final Widget page3;
  LoadingSchedule({required this.page3});
  @override
  _LoadingScheduleState createState() => _LoadingScheduleState();
}

class _LoadingScheduleState extends State<LoadingSchedule> {
  bool isLoading = true; 
  final _controller = instanceManager.calendarController;
  Future<void> yourFunction() async {
    await Future.delayed(Duration(seconds: 5)); 
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading
          ? widget.page3 
          : ScheduleExistsPage();
  }
}

class ScheduleExistsPage extends StatefulWidget {
  const ScheduleExistsPage({super.key});

  @override
  State<ScheduleExistsPage> createState() => _ScheduleExistsPageState();
}

class _ScheduleExistsPageState extends State<ScheduleExistsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [Text('TODO: Here goes the regular calendar view')]),);
  }
}
