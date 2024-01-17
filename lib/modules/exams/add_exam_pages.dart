import 'dart:ui';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/common_widgets/plus_minus_field.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/exams/add_exam_button.dart';
import 'package:study_buddy/modules/exams/exam_detail_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/utils/general_utils.dart';
import 'package:study_buddy/utils/validators.dart';

class Page1 extends StatefulWidget {
  Function refresh;
  Function lockClose;
  Function updatePage2;
  Function updatePage3;
  PageController pageController;
  Function removePage;
  Page1(
      {super.key,
      required this.refresh,
      required this.lockClose,
      required this.updatePage2,
      required this.pageController,
      required this.updatePage3,
      required this.removePage});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final examCreationFormKey = GlobalKey<FormBuilderState>();
  Duration sessionTime = Duration(hours: 1);
  Duration revisionTime = Duration(hours: 1);
  final _controller = instanceManager.examController;
  Color examColor = Colors.redAccent;
  int revisions = 2;

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    void _openDialog(String title, Widget content) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(18.0),
            title: Text(title, style: TextStyle(color: Colors.white)),
            content: content,
            backgroundColor: Color.fromARGB(255, 16, 16, 16),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(_localizations.cancel,
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(_localizations.select,
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }

    void _openMainColorPicker() async {
      _openDialog(
        _localizations.chooseColor,
        MaterialColorPicker(
          colors: const [
            Colors.amberAccent,
            Colors.blueAccent,
            Colors.cyan,
            Colors.deepOrangeAccent,
            Colors.deepPurpleAccent,
            Colors.indigo,
            Colors.lightGreen,
            Colors.lime,
            Colors.orangeAccent,
            Colors.pinkAccent,
            Colors.purpleAccent,
            Colors.redAccent,
            Colors.teal,
          ],
          selectedColor: examColor,
          allowShades: false,
          onMainColorChange: (color) => setState(() => examColor = color!),
        ),
      );
    }

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
                key: examCreationFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.00),
                      child: FormBuilderTextField(
                        // Name
                        name: 'examName',
                        textCapitalization: TextCapitalization.words,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: _localizations.examName,
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
                          format: DateFormat('EEE, M/d/y') ,
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
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.05),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                          Column(
                            children: [
                              Text(
                                _localizations.numberOfRevisions,
                                style: TextStyle(color: Color.fromRGBO(63, 72, 74, 1.0)),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: screenHeight*0.01),
                                child: plusMinusField(
                                    duration: Duration(seconds: 1),
                                    toggle: true,
                                    addNumberToParent: (int i) {
                                      setState(() {
                                        revisions += i;
                                      });
                                    },
                                    number: revisions),
                              ),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.9,
                      child: Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.07),
                        child: Row(
                          children: [
                            Text(_localizations.color,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: screenWidth * 0.045)),
                            SizedBox(
                              width: screenWidth * 0.06,
                            ),
                            GestureDetector(
                              onTap: () {
                                _openMainColorPicker();
                              },
                              child: Container(
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.1,
                                decoration: BoxDecoration(
                                  color: examColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.0,
                                  ),
                                ),
                                // You can add other child widgets here if needed
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.9,
                      child: Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.07),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_localizations.revisionTime,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: screenHeight * 0.02)),
                            TextButton.icon(
                              label: Text(
                                '${formatDuration(revisionTime)}',
                                style: TextStyle(color: Colors.white),
                              ),
                              icon: Icon(Icons.av_timer_rounded,
                                  color: Colors.white),
                              onPressed: () async {
                                revisionTime = await showDurationPicker(
                                      context: context,
                                      initialTime: revisionTime,
                                    ) ??
                                    revisionTime;
                                setState(() {});
                              },
                            )
                          ],
                        ),
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
                  ],
                )),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                child: AddButton(
                  examColor: examColor,
                  sessionTime: sessionTime,
                  revisionTime: revisionTime,
                  revisions: revisions,
                  controller: _controller,
                  formKey: examCreationFormKey,
                  refresh: widget.refresh,
                  lockClose: widget.lockClose,
                  updatePage2: widget.updatePage2,
                  updatePage3: widget.updatePage3,
                  screen: 0,
                  pageController: widget.pageController,
                  removePage: widget.removePage,
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
  List<UnitModel> unitsToAdd = instanceManager.sessionStorage.examToAdd.units;
  final unitTimesFormKey = GlobalKey<FormBuilderState>();
  final _controller = instanceManager.examController;

  void updateState() {
    setState(() {
      unitsToAdd = instanceManager.sessionStorage.examToAdd.units;
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
                            in instanceManager.sessionStorage.examToAdd.units)
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
                                              // Text('${unit.order}.  ',
                                              //     style: TextStyle(
                                              //         color: Colors.white,
                                              //         fontSize:
                                              //             screenWidth * 0.05)),
                                              Container(
                                                // color: const Color.fromARGB(
                                                //     81, 255, 235, 59),
                                                width: screenWidth * 0.37,
                                                child: FormBuilderTextField(
                                                  textCapitalization:
                                                      TextCapitalization.words,
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
                                                                hours: 1),
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 0, 5, 5).withOpacity(
                                0.0), // Transparent color at the top
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
  List<ExamModel> exams = instanceManager.sessionStorage.activeExams;

  final _controller = instanceManager.examController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void updateState() {
    setState(() {
      exams = instanceManager.sessionStorage.activeExams;
    });

    //logger.d('${getActiveExamsString()}\n$exams');
  }

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
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

    //logger.w('${getActiveExamsString()}\n$exams');

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
                    _localizations.prioritizeExams,
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
                  height: screenHeight * 0.58,
                  child: //Placeholder()
                      ReorderableListView.builder(
                          padding:
                              EdgeInsets.only(bottom: screenHeight * 0.065),
                          proxyDecorator: proxyDecorator,
                          itemBuilder: (context, index) {
                            ExamModel exam = exams[index];
                            final cardColor = exam.color;
                            final lighterColor = lighten(cardColor, .03);
                            final darkerColor = darken(cardColor, .1);
                            return Container(
                                key: Key('$index'),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              end: Alignment.bottomLeft,
                                              begin: Alignment.topRight,
                                              stops: const [
                                                0.2,
                                                0.3,
                                                0.9,
                                              ],
                                              colors: [
                                                lighterColor,
                                                cardColor,
                                                darkerColor
                                              ]),
                                        ),
                                        padding: EdgeInsets.only(
                                            left: screenWidth * 0.05,
                                            top: screenWidth * 0.03,
                                            bottom: screenWidth * 0.03),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(exam.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth * 0.06)),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    '${formatDateTime(exam.examDate)}',
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
                          itemCount: exams.length,
                          onReorder: (int oldIndex, int newIndex) {
                            // logger.i(exams);
                            // logger.t(getActiveExamsString());
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final ExamModel item = exams.removeAt(oldIndex);
                              exams.insert(newIndex, item);
                            });
                            //logger.t(getActiveExamsString());
                          })),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    height: screenHeight * 0.04,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(0, 0, 5, 5),
                            Color.fromARGB(255, 0, 5, 5),
                          ],
                          begin: FractionalOffset(0, 0),
                          end: FractionalOffset(0, 1),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    child: SizedBox()),
              ),
            ]),
            AddButton(
              controller: _controller,
              refresh: widget.refreshParent,
              lockClose: widget.lockClose,
              screen: 2,
            ),
          ],
        ),
      ),
    );
  }
}
