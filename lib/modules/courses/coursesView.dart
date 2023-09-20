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
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            height: screenHeight * 0.1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(
                                        left: screenWidth * 0.02,
                                        right: screenWidth * 0.04),
                                    child: Icon(
                                      courses[index].icon,
                                      size: screenWidth * 0.12,
                                    )),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: screenWidth * 0.6,
                                      child: Text(
                                        courses[index].name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
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
final List<CourseModel> courses = <CourseModel>[
  CourseModel(
      name: 'Diseño de sistemas operativos',
      examDate: DateTime.now(),
      weight: 2.0,
      units: units,
      secondsStudied: 4000),
  CourseModel(name: 'Test', examDate: DateTime.now()),
  CourseModel(name: 'Test', examDate: DateTime.now()),
  CourseModel(name: 'Test', examDate: DateTime.now()),
  CourseModel(
      name: 'Diseño de sistemas operativos',
      examDate: DateTime.now(),
      weight: 2.0,
      units: units,
      secondsStudied: 4000),
  CourseModel(name: 'Test', examDate: DateTime.now()),
  CourseModel(name: 'Test', examDate: DateTime.now()),
  CourseModel(name: 'Test', examDate: DateTime.now())
];

final List<UnitModel> units = <UnitModel>[
  UnitModel(name: 'unitname'),
  UnitModel(name: 'unitname'),
  UnitModel(name: 'unitname'),
  UnitModel(name: 'unitname')
];
