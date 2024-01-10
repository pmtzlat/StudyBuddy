import 'dart:ui';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/courses/add_course_button.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/utils/validators.dart';

class Page1 extends StatefulWidget {
  Function refresh;
  Function lockClose;
  Function updatePage2;
  Function updatePage3;
  PageController pageController;
  Page1(
      {super.key,
      required this.refresh,
      required this.lockClose,
      required this.updatePage2,
      required this.pageController,
      required this.updatePage3});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final courseCreationFormKey = GlobalKey<FormBuilderState>();
  Duration sessionTime = Duration(hours: 1);
  final _controller = instanceManager.courseController;

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            bottom: screenHeight * 0.1,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            top: screenWidth * 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FormBuilder(
                key: courseCreationFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.00),
                      child: FormBuilderTextField(
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
                        scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.04),
                      child: FormBuilderDateTimePicker(
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
                            futureDateValidator,
                          ]),
                          scrollPadding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom)),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(
                    //       top: screenHeight * 0.05),
                    //   child: FormBuilderSlider(
                    //     name: 'weightSlider',
                    //     initialValue: 1.0,
                    //     min: 0.0,
                    //     max: 2.0,
                    //     divisions: 20,
                    //     valueWidget: (value) {
                    //       return Text('$value',
                    //           style: TextStyle(
                    //               color: Colors.white,
                    //               fontSize: 23));
                    //     },
                    //     inactiveColor:
                    //         const Color.fromARGB(
                    //             255, 52, 52, 52),
                    //     decoration: InputDecoration(
                    //         helperStyle: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: screenHeight *
                    //                 0.03),
                    //         labelText: _localizations
                    //             .courseWeight,
                    //         labelStyle: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: screenHeight *
                    //                 0.03)),
                    //     autovalidateMode:
                    //         AutovalidateMode
                    //             .onUserInteraction,
                    //     validator: FormBuilderValidators
                    //         .compose([
                    //       FormBuilderValidators
                    //           .required(),
                    //     ]),
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.07),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(_localizations.sessionTime,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: screenHeight * 0.02)),
                          TextButton.icon(
                            label: Text(
                              '${formatDuration(sessionTime)}',
                              style: TextStyle(color: Colors.white),
                            ),
                            icon: Icon(Icons.av_timer_rounded,
                                color: Colors.white),
                            onPressed: () async {
                              sessionTime = await showDurationPicker(
                                    context: context,
                                    initialTime: sessionTime,
                                  ) ??
                                  sessionTime;
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),

                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Container(
                    //       width: screenWidth * 0.15,
                    //       child: FormBuilderTextField(
                    //           name: 'sessionHours',
                    //           autovalidateMode:
                    //               AutovalidateMode.onUserInteraction,
                    //           keyboardType: TextInputType.number,
                    //           initialValue: '2',
                    //           decoration: InputDecoration(
                    //             labelText: _localizations.hours,
                    //           ),
                    //           style: TextStyle(color: Colors.white),
                    //           validator: FormBuilderValidators.compose([
                    //             FormBuilderValidators.required(),
                    //             FormBuilderValidators.numeric(),
                    //             integerValidator(context)
                    //           ]),
                    //           scrollPadding: EdgeInsets.only(
                    //               bottom: MediaQuery.of(context)
                    //                   .viewInsets
                    //                   .bottom)),
                    //     ),
                    //     SizedBox(
                    //       width: 10,
                    //     ),
                    //     Container(
                    //       width: screenWidth * 0.15,
                    //       child: FormBuilderTextField(
                    //           name: 'sessionMinutes',
                    //           autovalidateMode:
                    //               AutovalidateMode.onUserInteraction,
                    //           keyboardType: TextInputType.number,
                    //           initialValue: '30',
                    //           decoration: InputDecoration(
                    //             labelText: _localizations.minutes,
                    //           ),
                    //           style: TextStyle(color: Colors.white),
                    //           validator: FormBuilderValidators.compose([
                    //             FormBuilderValidators.required(),
                    //             FormBuilderValidators.numeric(),
                    //             integerValidator(context)
                    //           ]),
                    //           scrollPadding: EdgeInsets.only(
                    //               bottom: MediaQuery.of(context)
                    //                   .viewInsets
                    //                   .bottom)),
                    //     ),
                    //   ],
                    // ),

                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.05),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth * 0.3,
                            child: FormBuilderTextField(
                                name: 'units',
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.number,
                                initialValue: '1',
                                decoration: InputDecoration(
                                    labelText: _localizations.numberOfUnits,
                                    labelStyle: TextStyle(
                                        fontSize: screenWidth * 0.05)),
                                style: TextStyle(color: Colors.white),
                                validator: FormBuilderValidators.compose([
                                  integerValidator(context),
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.numeric()
                                ]),
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom)),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Container(
                            width: screenWidth * 0.45,
                            child: FormBuilderTextField(
                                name: 'revisions',
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.number,
                                initialValue: '2',
                                decoration: InputDecoration(
                                    labelText: _localizations.numberOfRevisions,
                                    labelStyle: TextStyle(
                                        fontSize: screenWidth * 0.05)),
                                style: TextStyle(color: Colors.white),
                                validator: FormBuilderValidators.compose([
                                  integerValidator(context),
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.numeric()
                                ]),
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.05),
                      width: screenWidth * 0.7,
                      child: FormBuilderCheckbox(
                          name: 'orderMatters',
                          initialValue: false,
                          title: Text(
                            _localizations.orderMatters,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.022),
                          )),
                    ),
                    Container(
                      width: screenWidth * 0.7,
                      child: FormBuilderCheckbox(
                          name: 'applySessionTime',
                          initialValue: false,
                          title: Text(
                            _localizations.applySessionTime,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.022),
                          )),
                    ),
                  ],
                )),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                child: AddButton(
                  sessionTime: sessionTime,
                  controller: _controller,
                  formKey: courseCreationFormKey,
                  refresh: widget.refresh,
                  lockClose: widget.lockClose,
                  updatePage2: widget.updatePage2,
                  updatePage3: widget.updatePage3,
                  screen: 0,
                  pageController: widget.pageController,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  final GlobalKey<Page2State> page2Key;
  Function refreshParent;
  Function lockClose;
  Function updatePage3;
  PageController pageController;

  Page2(
      {Key? key,
      required this.refreshParent,
      required this.lockClose,
      required this.pageController,
      required this.updatePage3})
      : page2Key = GlobalKey<Page2State>(),
        super(key: key);

  // Expose a method to trigger a rebuild
  void updateChild() {
    page2Key.currentState?.updateState();
  }

  @override
  Page2State createState() => Page2State();
}

class Page2State extends State<Page2> {
  List<UnitModel> unitsToAdd = instanceManager.sessionStorage.courseToAdd.units;
  final unitTimesFormKey = GlobalKey<FormBuilderState>();
  final _controller = instanceManager.courseController;

  void updateState() {
    setState(() {
      unitsToAdd = instanceManager.sessionStorage.courseToAdd.units;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      padding:
          EdgeInsets.symmetric(vertical: 10, horizontal: screenWidth * 0.05),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: screenWidth * 0.9,
                  child: Text(
                    _localizations.enterUnitSessionTime,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Stack(children: [
              Container(
                height: screenHeight * 0.65,
                child: FormBuilder(
                  key: unitTimesFormKey,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.1),
                      child: Column(children: [
                        for (UnitModel unit
                            in instanceManager.sessionStorage.courseToAdd.units)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Card(
                              color: Color.fromARGB(255, 39, 39, 39),
                              child: Container(
                                  padding: EdgeInsets.only(
                                      left: screenWidth * 0.05,
                                      top: screenWidth * 0.03,
                                      bottom: screenWidth * 0.03),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text('${unit.order}.  ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth * 0.05)),
                                              Container(
                                                // color: const Color.fromARGB(
                                                //     81, 255, 235, 59),
                                                width: screenWidth * 0.37,
                                                child: FormBuilderTextField(
                                                  name:
                                                      'Unit ${unit.order} name',
                                                  initialValue: '${unit.name}',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                              child: TextButton.icon(
                                            label: Text(
                                              '${formatDuration(unit.sessionTime)}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            icon: Icon(Icons.av_timer_rounded,
                                                color: Colors.white),
                                            onPressed: () async {
                                              unit.sessionTime =
                                                  await showDurationPicker(
                                                        context: context,
                                                        initialTime:
                                                            const Duration(
                                                                minutes: 30),
                                                      ) ??
                                                      unit.sessionTime;
                                              setState(() {});
                                            },
                                          ))
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          )
                      ]),
                    ),
                  ),
                ),
              ),
              Container(
                height: screenHeight * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      //color: Colors.yellow,
                      width: screenHeight * 0.9,
                      height: screenHeight * 0.1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent, // Transparent color at the top
                            Color.fromARGB(255, 0, 5, 5),
                            Color.fromARGB(255, 0, 5, 5),
                          ],
                        ),
                      ),
                      child: Center(
                        child: //Placeholder()
                            AddButton(
                                controller: _controller,
                                formKey: unitTimesFormKey,
                                refresh: widget.refreshParent ?? () {},
                                lockClose: widget.lockClose ?? (bool value) {},
                                updatePage3: widget.updatePage3,
                                screen: 1,
                                pageController: widget.pageController),
                      ),
                    )
                  ],
                ),
              )
            ]),
          ],
        ),
      ),
    );
  }

  void update() {
    setState(() {});
  }
}

class Page3 extends StatefulWidget {
  final GlobalKey<Page3State> page3Key;
  Function refreshParent;
  Function lockClose;

  Page3({Key? key, required this.refreshParent, required this.lockClose})
      : page3Key = GlobalKey<Page3State>(),
        super(key: key);

  void updateChild() {
    page3Key.currentState?.updateState();
  }

  @override
  State<Page3> createState() => Page3State();
}

class Page3State extends State<Page3> {
  List<CourseModel> courses = instanceManager.sessionStorage.activeCourses;

  final _controller = instanceManager.courseController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void updateState() {
    setState(() {});
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.5),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      padding:
          EdgeInsets.symmetric(vertical: 10, horizontal: screenWidth * 0.05),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: screenWidth * 0.9,
                  child: Text(
                    _localizations.prioritizeCourses,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Stack(children: [
              Container(
                  height: screenHeight * 0.57,
                  child: //Placeholder()
                      ReorderableListView.builder(
                          padding:
                              EdgeInsets.only(bottom: screenHeight * 0.065),
                          proxyDecorator: proxyDecorator,
                          itemBuilder: (context, index) {
                            CourseModel course = courses[index];
                            return Container(
                                key: Key('$index'),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Card(
                                    color: Color.fromARGB(255, 39, 39, 39),
                                    child: Container(
                                        padding: EdgeInsets.only(
                                            left: screenWidth * 0.05,
                                            top: screenWidth * 0.03,
                                            bottom: screenWidth * 0.03),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(course.name,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenWidth * 0.06)),
                                            Row(
                                              children: [
                                                Text(
                                                    '${formatDateTime(course.examDate)}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: screenWidth *
                                                            0.035)),
                                                SizedBox(
                                                  width: screenWidth * 0.02,
                                                ),
                                                ReorderableDragStartListener(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                          screenWidth * 0.02),
                                                      child: Icon(
                                                          Icons
                                                              .drag_handle_rounded,
                                                          color: Colors.black),
                                                    ),
                                                    index: index),
                                              ],
                                            )
                                          ],
                                        ))));
                          },
                          itemCount: courses.length,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final CourseModel item =
                                  courses.removeAt(oldIndex);
                              courses.insert(newIndex, item);
                            });
                          })),
              Container(
                height: screenHeight * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        //color: Colors.yellow,

                        width: screenHeight * 0.9,
                        height: screenHeight * 0.08,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            //stops: [0.1, 0.8], 
                            colors: [
                              Colors
                                  .transparent, // Transparent color at the top
                              
                              Color.fromARGB(255, 0, 5, 5),
                            ],
                          ),
                        ),
                        child: SizedBox()),
                    AddButton(
                      controller: _controller,
                      refresh: widget.refreshParent ?? () {},
                      lockClose: widget.lockClose ?? (bool value) {},
                      screen: 2,
                    ),
                  ],
                ),
              )
            ]),
          ],
        ),
      ),
    );
  }
}
