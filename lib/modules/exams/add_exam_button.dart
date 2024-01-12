import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/exams/controllers/exams_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/general_utils.dart';

class AddButton extends StatefulWidget {
  ExamsController controller;
  GlobalKey<FormBuilderState>? formKey;
  Function? refresh;
  Function? lockClose;
  Function? updatePage2;
  Function? updatePage3;
  int screen;
  PageController? pageController;
  Duration? sessionTime;
  Function? removePage;
  Duration? revisionTime;

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
      this.pageController,
      this.removePage,
      this.revisionTime});

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
                        //     .handleAddExam(widget.examCreationFormKey);
                        switch (await widget.controller.addExamScreen1(
                            widget.formKey!,
                            widget.sessionTime!,
                            widget.revisionTime!)) {
                          case (1):
                            await moveToPage2();

                          case (2):
                            moveToPage3(skipPage2: true);

                          case (3):
                            saveExams(context);

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
                            .addExamScreen2(widget.formKey!)) {
                          case (2):
                            await moveToPage3();

                          case (3):
                            saveExams(context);

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
                      //     .handleAddExam(widget.examCreationFormKey);
                      
                      switch (await widget.controller.applyWeights(instanceManager.sessionStorage.activeExams)) {
                        // change to screen3
                        case (3):
                          saveExams(context);

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

  void saveExams(BuildContext context) async {
    if (!instanceManager.sessionStorage.activeExams
        .contains(instanceManager.sessionStorage.examToAdd)) {
      instanceManager.sessionStorage.activeExams
          .add(instanceManager.sessionStorage.examToAdd);
    }

    if (await widget.controller.handleAddExam() == 1) {
      await closeSuccess(context);
    } else {
      await closeError(context);
    }
  }

  Future<void> closeError(BuildContext context) async {
    snackbar = SnackBar(
      content: Text(AppLocalizations.of(context)!.errorAddingExam),
      backgroundColor: Colors.red,
    );
    setState(() {
      loading = false;
    });
    await closeModal(context, snackbar);
  }

  Future<void> closeSuccess(BuildContext context) async {
    snackbar = SnackBar(
        content: Text(AppLocalizations.of(context)!.examAddedCorrectly),
        backgroundColor: Colors.greenAccent[700]);
    await closeModal(context, snackbar);
  }

  Future<void> moveToPage2() async {
    //await Future.delayed(Duration(seconds: 5));
    setState(() {
      loading = false;
    });
    //await widget.refresh!();
    widget.lockClose!(false);
    widget.updatePage2!();
    widget.pageController!.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  Future<void> moveToPage3({bool skipPage2 = false}) async {
    var exams = instanceManager.sessionStorage.activeExams;
    exams.insert(0, instanceManager.sessionStorage.examToAdd);
    
    widget.controller.applyWeights(instanceManager.sessionStorage.activeExams);

    
    widget.lockClose!(false);
    setState(() {
      loading = false;
    });
    if (skipPage2) {
      widget.removePage!(1);
      widget.pageController!.animateToPage(1,
          duration: Duration(milliseconds: 500), curve: Curves.decelerate);
    } else {
      widget.pageController!.animateToPage(2,
          duration: Duration(milliseconds: 500), curve: Curves.decelerate);
    }
  }

  Future<void> closeModal(BuildContext context, SnackBar snackbar) async {
    instanceManager.sessionStorage.examToAdd =
        ExamModel(examDate: DateTime.now(), name: '');

    await widget.controller.getAllExams();

    widget.refresh!();
    //await Future.delayed(Duration(seconds: 5));
    widget.lockClose!(false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
