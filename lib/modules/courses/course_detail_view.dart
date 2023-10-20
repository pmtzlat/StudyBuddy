import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/common_widgets/loading_screen.dart';
import 'package:study_buddy/common_widgets/unit_card.dart';
import 'package:study_buddy/services/logging_service.dart';
import '../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/course_model.dart';

class CourseDetailView extends StatefulWidget {
  CourseModel course;
  CourseDetailView(
      {super.key,
      required CourseModel this.course,});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  final _controller = instanceManager.courseController;
  bool editMode = false;
  final courseFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    loadUnits();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: Colors.lightBlue,
            child: Container(
              height: screenHeight * 0.8,
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(30),
              child: editMode == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.name,
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Weight: ${widget.course.weight}'),
                        Text(
                            'Session time: ${widget.course.sessionTime / 3600}'),
                        Text('Exam Date: ${widget.course.examDate}'),
                        Text('Order Matters: ${widget.course.orderMatters}'),
                        Text('Revisions: ${widget.course.revisions}'),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                editMode = true;
                              });
                            },
                            icon: Icon(Icons.edit)),
                        ElevatedButton(
                            onPressed: () async {
                              await widget.course.addUnit();
                              setState(() {});
                            },
                            child: Text(_localizations.addUnit)),
                        widget.course.units == null
                            ? loadingScreen()
                            : getUnitList()
                      ],
                    )
                  : SingleChildScrollView(
                      child: Container(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormBuilder(
                              key: courseFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormBuilderTextField(
                                    name: 'courseName',
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                        labelText: _localizations.unitName),
                                    style: TextStyle(color: Colors.black),
                                    initialValue: widget.course.name,
                                    validator:
                                        FormBuilderValidators.compose([]),
                                  ),
                                  FormBuilderSlider(
                                    name: 'weightSlider',
                                    initialValue: widget.course.weight,
                                    min: 0.0,
                                    max: 2.0,
                                    divisions: 20,
                                    decoration: InputDecoration(
                                        labelText: _localizations.courseWeight),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator:
                                        FormBuilderValidators.compose([]),
                                  ),
                                  FormBuilderTextField(
                                    name: 'sessionTime',
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    initialValue:
                                        '${(widget.course.sessionTime / 3600).toInt()}',
                                    decoration: InputDecoration(
                                        labelText: _localizations.sessionTime,
                                        suffix: Text(_localizations.hours)),
                                    style: TextStyle(color: Colors.white),
                                    validator: FormBuilderValidators.compose(
                                        [FormBuilderValidators.numeric()]),
                                  ),
                                  FormBuilderDateTimePicker(
                                    name: 'examDate',
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    inputType: InputType.date,
                                    enabled: true,
                                    initialDate: widget.course.examDate,
                                    decoration: InputDecoration(
                                        labelText: _localizations.examDate),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal),
                                    validator:
                                        FormBuilderValidators.compose([]),
                                  ),
                                  FormBuilderCheckbox(
                                      name: 'orderMatters',
                                      initialValue: false,
                                      title: Text(_localizations.orderMatters)),
                                  FormBuilderTextField(
                                    name: 'revisions',
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    initialValue:
                                        widget.course.revisions.toString(),
                                    decoration: InputDecoration(
                                      labelText:
                                          _localizations.numberOfRevisions,
                                    ),
                                    style: TextStyle(color: Colors.white),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.numeric()
                                    ]),
                                  ),
                                ],
                              )),
                          IconButton(
                              onPressed: () async {
                                int? res = await _controller.handleEditCourse(
                                    courseFormKey, widget.course);

                                if (res == -1) {
                                  showError(_localizations.errorEditingCourse);
                                }
                                if (res == -2) {
                                  showError(_localizations.wrongDates);
                                } else {
                                  widget.course = await instanceManager
                                      .firebaseCrudService
                                      .getCourse(widget.course.id);
                                  await _controller.getAllCourses();

                                  setState(() {
                                    editMode = false;
                                  });
                                }
                              },
                              icon: Icon(Icons.check)),
                        ],
                      )),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void loadUnits() async {
    await widget.course.getUnits();
    setState(() {});
  }

  /*FutureBuilder<void> loadUnits() {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder(
        future: widget.course.getUnits(),
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
                content: Text(_localizations.errorGettingUnits),
              ),
            );
            return Text('Error: ${snapshot.error}');
          } else {
            if (widget.course.units!.isEmpty || widget.course.units == null) {
              return Center(
                child: Text(_localizations.noUnitsYet),
              );
            }
            return getUnitList();
          }
        });
  }*/

  Expanded getUnitList() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.course.units!.length,
          itemBuilder: (context, index) {
            final unit = widget.course.units![index];
            
              return Dismissible(
                key: Key(unit.id),
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
                  widget.course.units!.removeWhere((element) => element.id == unit.id);
                  await widget.course.deleteUnit(unit: unit);
                  setState(() {});
                },
                child: UnitCard(
                  unit: unit,
                  course: widget.course,
                  notifyParent: refresh,
                  showError: showError,
                ),
              );
            
          },
        ),
      ),
    );
  }

 
  void refresh() {
    setState(() {});
  }

  void showError(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Color.fromARGB(255, 221, 15, 0),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
