import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/modules/courses/courses_view.dart';
import 'package:study_buddy/modules/progress/progress_view.dart';
import 'package:study_buddy/modules/profile/profile_view.dart';
import 'package:study_buddy/modules/timer/timer_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import '../modules/calendar/calendar_view.dart';

PageRouteBuilder<dynamic> fadePageRouteBuilder(
  Widget page,
) {
  return PageRouteBuilder<dynamic>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

class MyScaffold {
  Widget getScaffold(
      {required int activeIndex,
      required Widget body,
      required BuildContext context}) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType
              .fixed, // This is important to show all 5 icons
          currentIndex: activeIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            if (index != activeIndex) {
              switch (index) {
                case 0:
                logger.i('Moved to Timer page');
                  Navigator.of(context).push(fadePageRouteBuilder(TimerView()));

                  break;
                case 1:
                  Navigator.of(context)
                      .push(fadePageRouteBuilder(CoursesView()));

                  break;
                case 2:
                  Navigator.of(context)
                      .push(fadePageRouteBuilder(CalendarView()));

                  break;
                case 3:
                  Navigator.of(context)
                      .push(fadePageRouteBuilder(GraphsView()));

                  break;
                case 4:
                  Navigator.of(context)
                      .push(fadePageRouteBuilder(ProfileView()));

                  break;
              }
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'Timer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph),
              label: 'Graph',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'User',
            ),
          ],
        ),
        body: Container(
            padding: EdgeInsets.only(
                top: screenHeight * 0.08,
                left: screenWidth * 0.03,
                right: screenWidth * 0.03),
            child: body));
  }
}
