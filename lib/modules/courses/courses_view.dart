import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/common_widgets/loading_screen.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import '../../common_widgets/course_card.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final _controller = instanceManager.courseController;

  
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 0,
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
            instanceManager.sessionStorage.activeCourses == null
                ? loadingScreen()
                : getCourseList()
          ],
        ));
    ;
  }

  void loadCourses() async {
    await _controller.getAllCourses();
    setState(() {});
  }

  Expanded getCourseList() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: instanceManager.sessionStorage.activeCourses!.length,
          itemBuilder: (context, index) {
            final course = instanceManager.sessionStorage.activeCourses![index];
            return Dismissible(
              key: Key(course.id),
              background: Container(
                color: const Color.fromARGB(255, 255, 77, 65),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
              ),
              onDismissed: (direction) async {
                setState(() {
                  instanceManager.sessionStorage.activeCourses.removeAt(index);
                });

                await _controller.deleteCourse(
                    id: course.id, index: index, context: context);

                await _controller.getAllCourses();
              },
              child: CourseCard(
                  course: instanceManager.sessionStorage.activeCourses![index],
                  parentRefresh: loadCourses),
            );
          },
        ),
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
                          initialValue: '2.0',
                          decoration: InputDecoration(
                              labelText: _localizations.sessionTime,
                              suffix: Text(_localizations.hours)),
                          style: TextStyle(color: Colors.white),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric()
                          ]),
                        ),
                        FormBuilderTextField(
                          name: 'units',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          initialValue: '1',
                          decoration: InputDecoration(
                            labelText: _localizations.numberOfUnits,
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric()
                          ]),
                        ),
                        FormBuilderTextField(
                          name: 'revisions',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          initialValue: '2',
                          decoration: InputDecoration(
                            labelText: _localizations.numberOfRevisions,
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric()
                          ]),
                        ),
                        FormBuilderCheckbox(
                            name: 'orderMatters',
                            initialValue: false,
                            title: Text(_localizations.orderMatters))
                      ],
                    )),
                Center(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () async {
                        final res = await _controller.handleAddCourse(
                            courseCreationFormKey, context);
                        await _controller.getAllCourses();

                        setState(() {});
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

  void refresh() {
    setState(() {});
  }
}
