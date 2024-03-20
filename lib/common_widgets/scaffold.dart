
import 'package:flutter/material.dart';
import 'package:study_buddy/modules/calendar/calendar_view.dart';
import 'package:study_buddy/modules/exams/exams_view.dart';
import 'package:study_buddy/modules/profile/profile_view.dart';

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

class SlidePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  SlidePageRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(1.0, 0.0); // Slide from the right
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}

class MyScaffold {
  Widget getScaffold(
      {required int activeIndex,
      required Widget body,
      required BuildContext context,
      bool padding = true}) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // Disable back button
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomNavBar(activeIndex: activeIndex),
          body: Container(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.08,
                  left:  0,
                  right:  0),
              child: body)),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final activeIndex;
  const BottomNavBar({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.08,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color.fromARGB(255, 197, 197, 197),
              blurRadius: 10,
            ),
          ],
        ),
        child:BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: activeIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Color.fromARGB(255, 73, 73, 73),
        unselectedItemColor: Color.fromARGB(255, 179, 179, 179),
        onTap: (index) {
          if (index != activeIndex) {
            switch (index) {
              case 0:
                Navigator.of(context)
                    .pushReplacement(fadePageRouteBuilder(ExamsView()));
    
                break;
              case 1:
                Navigator.of(context)
                    .pushReplacement(fadePageRouteBuilder(CalendarView()));
    
                break;
    
              case 2:
                Navigator.of(context)
                    .pushReplacement(fadePageRouteBuilder(ProfileView()));
    
                break;
            }
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
