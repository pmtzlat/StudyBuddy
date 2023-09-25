import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/courses/courses_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final courseCreationFormKey = GlobalKey<FormBuilderState>();
    final _localizations = AppLocalizations.of(context)!;
    /*- Course title
- exam date
- study start date
- Course importance
- minimum study time per day
- units: unit title, weight
*/
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      FormBuilderTextField(
                        // Name
                        name: 'courseName',
                        decoration: InputDecoration(
                            labelText: _localizations.courseName,
                        ),
                        style: TextStyle(color:Colors.white),

                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FormBuilderDateTimePicker(
                        name: 'examDate',
                        inputType: InputType.date,
                        enabled: true,
                        decoration: InputDecoration(
                            labelText: _localizations.examDate,
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal)),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  )),
              Center(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _controller.handleFormSubmission(
                          courseCreationFormKey, context);
                    },
                    child: Text(_localizations.add),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

final List<CourseModel> courses = <CourseModel>[];
