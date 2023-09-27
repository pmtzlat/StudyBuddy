import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/courses/courses_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../common_widgets/course_card.dart';
import '../../common_widgets/unit_card.dart';
import '../../services/logging_service.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final _controller = instanceManager.courseController;

  Future<List<CourseModel>?> _getActiveCourses() async {
    instanceManager.sessionStorage.savedCourses = await _controller.getAllCourses();
    return instanceManager.sessionStorage.savedCourses;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

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
                _localizations.coursesTitle,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showAddCourseSheet(context);
              },
              child: Text(_localizations.addCourse),
            ),
            instanceManager.sessionStorage.savedCourses == null
                ? loadCourses()
                : getCourseList()
          ],
        ));
    ;
  }

  FutureBuilder<void> loadCourses() {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: _getActiveCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while the Future is running
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // Display the error message and show the snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(_localizations.errorGettingCourses),
              ),
            );
            return Text('Error: ${snapshot.error}');
          } else {
            if (instanceManager.sessionStorage.savedCourses!.length == 0) {
              return Center(
                child: Text(_localizations.noCoursesYet),
              );
            }
            return getCourseList();
          }
        });
  }

  Expanded getCourseList() {
    logger.i('coursesList: $instanceManager.sessionStorage.savedCourses');
    return Expanded(
            child: Container(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: instanceManager.sessionStorage.savedCourses!.length,
                  itemBuilder: (context, index) {
                    final course = instanceManager.sessionStorage.savedCourses![index];
                    return CourseCard(course: course);
                  }),
            ),
          );
  }

  void showAddCourseSheet(BuildContext context) {
    final courseCreationFormKey = GlobalKey<FormBuilderState>();
    final _localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _localizations.addCourse,
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 18.0, // Text size
                  ),
                ),
                FormBuilder(
                    key: courseCreationFormKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        FormBuilderTextField(
                          // Name
                          name: 'courseName',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: _localizations.courseName,
                          ),
                          style: TextStyle(color: Colors.white),

                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FormBuilderDateTimePicker(
                          name: 'examDate',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputType: InputType.date,
                          enabled: true,
                          decoration: InputDecoration(
                              labelText: _localizations.examDate),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        FormBuilderDateTimePicker(
                          name: 'startStudy',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputType: InputType.date,
                          enabled: true,
                          decoration: InputDecoration(
                              labelText: _localizations.startStudy),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        FormBuilderSlider(
                          name: 'weightSlider',
                          initialValue: 1.0,
                          min: 0.0,
                          max: 2.0,
                          divisions: 20,
                          decoration: InputDecoration(
                              labelText: _localizations.courseWeight),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        FormBuilderTextField(
                          name: 'sessionTime',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          initialValue: '2',
                          decoration: InputDecoration(
                              labelText: _localizations.sessionTime,
                              suffix: Text(_localizations.hours)),
                          style: TextStyle(color: Colors.white),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric()
                          ]),
                        ),
                      ],
                    )),
                Center(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () async {
                        final res = await _controller.handleFormSubmission(
                            courseCreationFormKey, context);
                        logger.i('RES: $res');

                        final newList = await _getActiveCourses();
                        setState(() {
                          instanceManager.sessionStorage.savedCourses = newList;
                        });
                      },
                      child: Text(_localizations.add),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
