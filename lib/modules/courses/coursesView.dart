import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 1,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(screenWidth * 0.05),
              child: Text(
                'Courses',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: courses.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.all(screenHeight * 0.005),
                      child: Card(
                        color: Colors.amber[colorCodes[index]],
                        child: Container(
                            padding: EdgeInsets.all(screenHeight * 0.01),
                            height: screenHeight * 0.1,
                            child: Text(courses[index].name)),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ));
    ;
  }
}

final List<String> entries = <String>[
  'A',
  'B',
  'C',
  'A',
  'B',
  'C',
  'A',
  'B',
  'C',
  'A',
  'B',
  'C'
];
final List<int> colorCodes = <int>[
  600,
  500,
  100,
  600,
  500,
  100,
  600,
  500,
  100,
  600,
  500,
  100
];
final List<Course> courses = <Course>[
  Course(name: 'Test', examDate: DateTime.now()),
  Course(name: 'Test', examDate: DateTime.now()),
  Course(name: 'Test', examDate: DateTime.now()),
  Course(name: 'Test', examDate: DateTime.now())
];
