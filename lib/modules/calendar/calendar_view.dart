import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final _controller = instanceManager.calendarController;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 2,
        body: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(
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
                                _controller.moveToStageTwo(
                                    controller: _pageController);
                              },
                              child: Text('Move to stage 2')),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            _controller.moveToStageOne(
                                controller: _pageController);
                          },
                          child: Text('Move to stage 1')),
                    ],
                  ),
                ],
              )
            ]));
  }
}
