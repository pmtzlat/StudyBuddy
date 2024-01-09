import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/courses/controllers/courses_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/services/logging_service.dart';

class AddButton extends StatefulWidget {
  CoursesController controller;
  GlobalKey<FormBuilderState>? formKey;
  Function? refresh;
  Function? lockClose;
  Function? updatePage2;
  Function? updatePage3;
  int screen;
  PageController? pageController;
  Duration? sessionTime;

  AddButton(
      {super.key,
      required this.controller,
      this.formKey,
      this.refresh,
      this.lockClose,
      this.updatePage2,
      this.updatePage3,
      required this.screen,
      this.sessionTime,
      this.pageController});

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  bool loading = false;
  late SnackBar snackbar;

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    switch (widget.screen) {
      case (0):
        return Center(
          child: Container(
            margin: EdgeInsets.all(20),
            child: loading == false
                ? ElevatedButton(
                    onPressed: () async {
                      if (widget.formKey!.currentState!.validate()) {
                        widget.formKey!.currentState!.save();
                        setState(() {
                          loading = true;
                        });
                        widget.lockClose!(true);

                        // int res = await widget.controller
                        //     .handleAddCourse(widget.courseCreationFormKey);
                        switch (await widget.controller
                            .addCourseScreen1(widget.formKey!, widget.sessionTime!)) {
                          case (1):
                            await moveToPage2();

                          case (2):
                            moveToPage3();

                          case (3):
                            saveCourses(context);

                          case (-1):
                            await closeError(context);
                        }
                      }
                    },
                    child: Text(_localizations.next),
                  )
                : CircularProgressIndicator(),
          ),
        );

      case (1):
        return Center(
          child: Container(
            margin: EdgeInsets.all(20),
            child: loading == false
                ? ElevatedButton(
                    onPressed: () async {
                      
                      if (widget.formKey!.currentState!.validate()) {
                        widget.formKey!.currentState!.save();
                        
                        setState(() {
                          loading = true;
                        });
                        widget.lockClose!(true);

                        
                        switch (await widget.controller
                            .addCourseScreen2(widget.formKey!)) {
                          case (2):
                            await moveToPage3();

                          case (3):
                           
                            saveCourses(context);

                          case (-1):
                            closeError(context);
                        }
                      }
                    },
                    child: Text(_localizations.next),
                  )
                : CircularProgressIndicator(),
          ),
        );

      case (2):
        return Center(
          child: Container(
            child: loading == false
                ? ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      widget.lockClose!(true);

                      // int res = await widget.controller
                      //     .handleAddCourse(widget.courseCreationFormKey);
                      switch (await widget.controller.addCourseScreen3()) {
                        // change to screen3
                        case (3):
                          saveCourses(context);

                        case (-1):
                          closeError(context);
                      }
                    },
                    child: Text(_localizations.add),
                  )
                : CircularProgressIndicator(),
          ),
        );

      default:
        return Center();
    }
  }

  void saveCourses(BuildContext context) async {
    if(!instanceManager.sessionStorage.activeCourses.contains(instanceManager.sessionStorage.courseToAdd)){
      instanceManager.sessionStorage.activeCourses.add(instanceManager.sessionStorage.courseToAdd);

    }
     

    if(await widget.controller.handleAddCourse() == 1){
      
      await closeSuccess(context);
    }

    else{
      await closeError(context);
    }
   

    
  }

  Future<void> closeError(BuildContext context) async {
    snackbar = SnackBar(
      content: Text(AppLocalizations.of(context)!.errorAddingCourse),
      backgroundColor: Color.fromARGB(255, 221, 15, 0),
    );
    setState(() {
      loading = false;
    });
    await closeModal(context, snackbar);
  }

  Future<void> closeSuccess(BuildContext context) async {
    snackbar = SnackBar(
        content: Text(AppLocalizations.of(context)!.courseAddedCorrectly),
        backgroundColor: Color.fromARGB(255, 0, 172, 6));
    await closeModal(context, snackbar);
  }

  Future<void> moveToPage2() async {
    //await Future.delayed(Duration(seconds: 5));
    setState(() {
      loading = false;
    });
    await widget.refresh!();
    widget.lockClose!(false);
    widget.updatePage2!();
    widget.pageController!.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  Future<void> moveToPage3() async {
    List<double> generateDescendingList(int n) {
      List<double> resultList = [];

      for (int i = 0; i < n; i++) {
        double value = 2.0 - (2.0/n)*i;
        resultList.add(double.parse(value.toStringAsFixed(3)));
      }

      return resultList;
    }

    setState(() {
      loading = false;
    });
    var courses = instanceManager.sessionStorage.activeCourses;
    courses.insert(0, instanceManager.sessionStorage.courseToAdd);
    courses
        .sort((CourseModel a, CourseModel b) => b.weight.compareTo(a.weight));
    for(CourseModel course in courses){
      logger.i(course.name + ',  ${course.weight}');
    }
    instanceManager.sessionStorage.courseWeightArray =
        generateDescendingList(courses.length);
    
    await widget.refresh!();
    widget.lockClose!(false);
    widget.updatePage3!();
    widget.pageController!.animateToPage(2,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  Future<void> closeModal(BuildContext context, SnackBar snackbar) async {
    instanceManager.sessionStorage.courseToAdd =  CourseModel(examDate: DateTime.now(), name: '');

    await widget.controller.getAllCourses();

    widget.refresh!();
    //await Future.delayed(Duration(seconds: 5));
    widget.lockClose!(false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
