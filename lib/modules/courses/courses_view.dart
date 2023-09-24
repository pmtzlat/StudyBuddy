import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/courses/courses_controller.dart';

import '../../services/logging_service.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final _controller = CoursesController();
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
                'Asignaturas',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showAddCourseSheet(context);
              },
              child: Text('Añadir Asignatura'),
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

  void showAddCourseSheet(BuildContext context) {
    /*- Course title
- exam date
- study start date
- Course importance
- minimum study time per day
- units: unit title, weight
*/
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.0)), // Rounded top corners
          child: Container(
            color: Colors.black, // Background color
            width: double.infinity, // Full screen width
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Añadir Asignatura',
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 18.0, // Text size
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final res = await _controller.addCourse(
                      name: 'test',
                      examDate: DateTime.now(),
                    );
                    logger.i(res);

                    // Close the bottom sheet
                    Navigator.of(context).pop();

                    // Show a snackbar based on the value of 'res'
                    final snackbar = SnackBar(
                      content: Text(
                        res == 1
                            ? 'Asignatura añadida con éxito!'
                            : 'Error al añadir asignatura. Inténtalo otra vez.',
                      ),
                      backgroundColor: res == 1 ? Color.fromARGB(255, 0, 172, 6) : Color.fromARGB(255, 221, 15, 0),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  },
                  child: Text('test add'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

final List<CourseModel> courses = <CourseModel>[];
