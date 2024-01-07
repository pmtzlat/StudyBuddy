import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/common_widgets/loading_screen.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/modules/courses/controllers/courses_controller.dart';
import 'package:study_buddy/modules/loader/loader.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../common_widgets/course_card.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final _controller = instanceManager.courseController;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    final PageController _pageController = PageController(
        initialPage: instanceManager.sessionStorage.activeOrAllCourses);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showAddCourseSheet(context);
                  },
                  child: Text(_localizations.addCourse),
                ),
                ToggleSwitch(
                  initialLabelIndex:
                      instanceManager.sessionStorage.activeOrAllCourses,
                  totalSwitches: 2,
                  labels: [
                    _localizations.activeCourses,
                    _localizations.allCourses
                  ],
                  onToggle: (index) {
                    print('switched to: $index');
                    instanceManager.sessionStorage.activeOrAllCourses = index;
                    _pageController.animateToPage(index!,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.decelerate);
                  },
                ),
              ],
            ),
            instanceManager.sessionStorage.activeCourses == null
                ? loadingScreen()
                : Flexible(
                    child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        controller: _pageController,
                        children: [
                          getCourseList(
                              instanceManager.sessionStorage.activeCourses),
                          getCourseList(
                              instanceManager.sessionStorage.savedCourses)
                        ]),
                  )
          ],
        ));
    ;
  }

  void loadCourses() async {
    await _controller.getAllCourses();
    setState(() {});
  }

  Container getCourseList(List<CourseModel> courseList) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: courseList!.length,
        itemBuilder: (context, index) {
          final course = courseList![index];
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
                instanceManager.sessionStorage.activeCourses.remove(course);
                instanceManager.sessionStorage.savedCourses.remove(course);
              });

              await _controller.deleteCourse(
                  id: course.id, index: index, context: context);

              //await _controller.getAllCourses();
            },
            child: CourseCard(
                course: courseList![index], parentRefresh: loadCourses),
          );
        },
      ),
    );
  }

  void showAddCourseSheet(BuildContext context) {
    final courseCreationFormKey = GlobalKey<FormBuilderState>();
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      builder: (BuildContext context) {
        
        return WillPopScope(
          onWillPop: () async {return false;},
          child: Container(
            height: screenHeight * 0.9,
            child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.01, left: screenWidth * 0.01),
                        child: IconButton(
                            iconSize: screenWidth * 0.1,
                            onPressed: () {
                              logger.i('Closing... - Loading state: $loading');
                              if(loading != true) {
                                Navigator.pop(context);
                                }
                                else{
                                  logger.i('Can\'t close while its loading!');
                                }
                              
                            },
                            icon: Icon(Icons.close_rounded)),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        left: screenWidth * 0.05,
                        top: screenWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localizations.addCourse,
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 34.0, // Text size
                          ),
                        ),
                        Container(
                          height: screenHeight * 0.65,
                          child: Scrollbar(
                            isAlwaysShown: true,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: screenWidth * 0.06,
                                    bottom:
                                        MediaQuery.of(context).viewInsets.bottom),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
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
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              decoration: InputDecoration(
                                                labelText:
                                                    _localizations.courseName,
                                              ),
                                              style:
                                                  TextStyle(color: Colors.white),
        
                                              validator:
                                                  FormBuilderValidators.compose([
                                                FormBuilderValidators.required(),
                                              ]),
                                              scrollPadding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            FormBuilderDateTimePicker(
                                                name: 'examDate',
                                                autovalidateMode: AutovalidateMode
                                                    .onUserInteraction,
                                                inputType: InputType.date,
                                                enabled: true,
                                                decoration: InputDecoration(
                                                    labelText:
                                                        _localizations.examDate),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                validator: FormBuilderValidators
                                                    .compose([
                                                  FormBuilderValidators
                                                      .required(),
                                                ]),
                                                scrollPadding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom)),
                                            FormBuilderSlider(
                                              name: 'weightSlider',
                                              initialValue: 1.0,
                                              min: 0.0,
                                              max: 2.0,
                                              divisions: 20,
                                              decoration: InputDecoration(
                                                  labelText: _localizations
                                                      .courseWeight),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              validator:
                                                  FormBuilderValidators.compose([
                                                FormBuilderValidators.required(),
                                              ]),
                                            ),
                                            FormBuilderTextField(
                                                name: 'sessionTime',
                                                autovalidateMode: AutovalidateMode
                                                    .onUserInteraction,
                                                keyboardType:
                                                    TextInputType.number,
                                                initialValue: '2.0',
                                                decoration: InputDecoration(
                                                    labelText: _localizations
                                                        .sessionTime,
                                                    suffix: Text(
                                                        _localizations.hours)),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                validator: FormBuilderValidators
                                                    .compose([
                                                  FormBuilderValidators
                                                      .required(),
                                                  FormBuilderValidators.numeric()
                                                ]),
                                                scrollPadding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom)),
                                            FormBuilderTextField(
                                                name: 'units',
                                                autovalidateMode: AutovalidateMode
                                                    .onUserInteraction,
                                                keyboardType:
                                                    TextInputType.number,
                                                maxLength: 2,
                                                initialValue: '1',
                                                decoration: InputDecoration(
                                                  labelText: _localizations
                                                      .numberOfUnits,
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                validator: FormBuilderValidators
                                                    .compose([
                                                  FormBuilderValidators
                                                      .required(),
                                                  FormBuilderValidators.numeric()
                                                ]),
                                                scrollPadding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom)),
                                            FormBuilderTextField(
                                                name: 'revisions',
                                                autovalidateMode: AutovalidateMode
                                                    .onUserInteraction,
                                                keyboardType:
                                                    TextInputType.number,
                                                maxLength: 1,
                                                initialValue: '2',
                                                decoration: InputDecoration(
                                                  labelText: _localizations
                                                      .numberOfRevisions,
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                validator: FormBuilderValidators
                                                    .compose([
                                                  FormBuilderValidators
                                                      .required(),
                                                  FormBuilderValidators.numeric()
                                                ]),
                                                scrollPadding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom)),
                                            FormBuilderCheckbox(
                                                name: 'orderMatters',
                                                initialValue: false,
                                                title: Text(
                                                  _localizations.orderMatters,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ))
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                  Center(
                          child: AddButton(
                            controller: _controller,
                            courseCreationFormKey: courseCreationFormKey,
                            refresh: refresh,
                            lockClose: setLoading,
                            localizations: _localizations,
                          ),
                        )
                ]),
          ),
        );
      },
    );
  }

  void refresh() {
    setState(() {});
  }
  void setLoading(bool state){
    logger.i('Changing state of laoding to $state');
    setState(() {
      loading = state;
    });
  }


}

class AddButton extends StatefulWidget {
  CoursesController controller;
  GlobalKey<FormBuilderState> courseCreationFormKey;
  Function refresh;
  Function lockClose;
  AppLocalizations localizations;

  AddButton(
      {super.key,
      required this.controller,
      required this.courseCreationFormKey,
      required this.refresh,
      required this.lockClose,
      required this.localizations});

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: loading == false
            ? ElevatedButton(
                onPressed: () async {
                  if (widget.courseCreationFormKey.currentState!.validate()) {
                    widget.courseCreationFormKey.currentState!.save();
                    setState(() {
                      loading = true;
                    });
                    widget.lockClose(true);
                    int res = await widget.controller
                        .handleAddCourse(widget.courseCreationFormKey, context);

                    late SnackBar snackbar;
                    switch (res) {
                      case (1):
                        snackbar = SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .courseAddedCorrectly),
                            backgroundColor: Color.fromARGB(255, 0, 172, 6));

                      case (0):
                        snackbar = SnackBar(
                            content:
                                Text(AppLocalizations.of(context)!.wrongDates),
                            backgroundColor: Color.fromARGB(255, 221, 15, 0));

                      default:
                        snackbar = SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.errorAddingCourse),
                          backgroundColor: Color.fromARGB(255, 221, 15, 0),
                        );
                    }

                    await widget.controller.getAllCourses();

                    widget.refresh();
                    //await Future.delayed(Duration(seconds: 5));
                    widget.lockClose(false);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  }
                },
                child: Text(widget.localizations.add),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
