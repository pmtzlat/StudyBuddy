import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/common_widgets/marquee.dart';
import 'package:study_buddy/common_widgets/plus_minus_field.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/common_widgets/loading_screen.dart';
import 'package:study_buddy/common_widgets/unit_card.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/utils/general_utils.dart';
import 'package:study_buddy/utils/validators.dart';
import '../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/exam_model.dart';

class ExamDetailView extends StatefulWidget {
  ExamModel exam;
  Function refreshParent;
  PageController pageController;
  ExamDetailView(
      {super.key,
      required ExamModel this.exam,
      required this.refreshParent,
      required this.pageController});

  @override
  State<ExamDetailView> createState() => _ExamDetailViewState();
}

class _ExamDetailViewState extends State<ExamDetailView> {
  final _controller = instanceManager.examController;
  bool editMode = false;
  final editExamFormKey = GlobalKey<FormBuilderState>();
  bool loading = false;
  Duration editSwitchTime = Duration(milliseconds: 300);
  bool orderMatters = false;
  int revisions = 0;
  Duration revisionTime = Duration(seconds: 0);
  DateTime examDate = DateTime.now();
  Color examColor = Colors.white;
  String position = '';

  @override
  void initState() {
    super.initState();
    orderMatters = widget.exam.orderMatters;
    revisions = widget.exam.revisions.length;
    revisionTime = widget.exam.revisionTime;
    examDate = widget.exam.examDate;
    examColor = widget.exam.color;
    position = getPosition(widget.exam);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    final cardColor = examColor;
    final lighterColor = lighten(cardColor, .05);
    final darkerColor = darken(cardColor, .2);
    ExamModel exam = widget.exam;

    final shakeKey1 = GlobalKey<ShakeWidgetState>();
    final shakeKey2 = GlobalKey<ShakeWidgetState>();
    final shakeKey3 = GlobalKey<ShakeWidgetState>();

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

    var examData = Expanded(
      child: Container(
          //color:Colors.yellow.withOpacity(0.3), // delet this

          padding: EdgeInsets.all(screenWidth * 0.05),
          child: FormBuilder(
            key: editExamFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.1),
                    Flexible(
                        child: AnimatedSwitcher(
                            duration: editSwitchTime,
                            child: editMode
                                ? Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: FormBuilderTextField(
                                      name: "name",
                                      initialValue: exam.name,
                                      readOnly: !editMode,
                                      decoration: InputDecoration.collapsed(
                                          hintText: exam.name),
                                      style: TextStyle(
                                        height: 1,
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.11,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  )
                                : MarqueeWidget(
                                    animationDuration: Duration(
                                        seconds:
                                            (exam.name.length / 2).toInt()),
                                    backDuration: Duration(
                                        seconds:
                                            (exam.name.length / 6).toInt()),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Text(
                                        exam.name,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            height: 1,
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.11,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ))))
                  ],
                ),
                AnimatedContainer(
                  duration: editSwitchTime,
                  height: !editMode ? 0 : screenHeight * 0.04,
                ),
                AnimatedSwitcher(
                    duration: editSwitchTime,
                    child: !editMode
                        ? Text(DateFormat('EEE, M/d/y').format(exam.examDate),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.w300))
                        : FormBuilderDateTimePicker(
                            name: "examDate",
                            inputType: InputType.date,
                            decoration: InputDecoration.collapsed(hintText: ''),
                            initialValue: exam.examDate,
                            format: DateFormat('EEE, M/d/y'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              futureDateValidator,
                            ]),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (DateTime? value) {
                              if (!value!.isBefore(stripTime(DateTime.now())
                                  .add(Duration(days: 1)))) {
                                setState(() {
                                  examDate = value!;
                                });
                              }
                            },
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.w300),
                          )),
                AnimatedContainer(
                  duration: editSwitchTime,
                  height: !editMode ? screenHeight * 0.08 : screenHeight * 0.03,
                ),
                GestureDetector(
                  onTap: () {
                    if (editMode) {
                      shakeKey1.currentState?.shake();
                    }
                  },
                  child: ShakeMe(
                    key: shakeKey1,
                    shakeCount: 3,
                    shakeOffset: 10,
                    shakeDuration: Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.pin_rounded,
                              color: Colors.white,
                              size: screenWidth * 0.08,
                            ),
                            SizedBox(width: 10),
                            Text(_localizations.priority,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.05))
                          ],
                        ),
                        Text(position,
                            style: TextStyle(
                                color: !editMode
                                    ? Colors.white
                                    : const Color.fromARGB(255, 93, 93, 93),
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.05))
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: editSwitchTime,
                  height: screenHeight * 0.015,
                ),
                GestureDetector(
                    onTap: () {
                      if (editMode) {
                        shakeKey2.currentState?.shake();
                      }
                    },
                    child: ShakeMe(
                      key: shakeKey2,
                      shakeCount: 3,
                      shakeOffset: 10,
                      shakeDuration: Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.white,
                                size: screenWidth * 0.08,
                              ),
                              SizedBox(width: 10),
                              Text(_localizations.daysUntilExam,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.05))
                            ],
                          ),
                          Text('${getDaysUntilExam(examDate)}',
                              style: TextStyle(
                                  color: !editMode
                                      ? Colors.white
                                      : const Color.fromARGB(255, 93, 93, 93),
                                  fontWeight: FontWeight.w400,
                                  fontSize: screenWidth * 0.05))
                        ],
                      ),
                    )),
                AnimatedContainer(
                  duration: editSwitchTime,
                  height: screenHeight * 0.015,
                ),
                GestureDetector(
                    onTap: () {
                      if (editMode) {
                        shakeKey3.currentState?.shake();
                      }
                    },
                    child: ShakeMe(
                      key: shakeKey3,
                      shakeCount: 3,
                      shakeOffset: 10,
                      shakeDuration: Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: screenWidth * 0.08,
                              ),
                              SizedBox(width: 10),
                              Text(_localizations.timeStudied,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.05))
                            ],
                          ),
                          Text(formatDuration(exam.timeStudied),
                              style: TextStyle(
                                  color: !editMode
                                      ? Colors.white
                                      : const Color.fromARGB(255, 93, 93, 93),
                                  fontWeight: FontWeight.w400,
                                  fontSize: screenWidth * 0.05))
                        ],
                      ),
                    )),
                AnimatedContainer(
                  duration: editSwitchTime,
                  height:
                      !editMode ? screenHeight * 0.015 : screenHeight * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.my_library_books_rounded,
                          color: Colors.white,
                          size: screenWidth * 0.08,
                        ),
                        SizedBox(width: 10),
                        Text(_localizations.orderMatter,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.05))
                      ],
                    ),
                    FormBuilderField<bool>(
                        name: 'orderMatters',
                        enabled: editMode,
                        initialValue: exam.orderMatters,
                        builder: (FormFieldState<dynamic> field) {
                          return Checkbox(
                              visualDensity: VisualDensity(
                                  horizontal: -4,
                                  vertical: -4), // Adjust the values as needed
                              activeColor: Colors
                                  .white, // Color when checkbox is checked
                              checkColor:
                                  Colors.black, // Color of the checkmark
                              fillColor:
                                  MaterialStateProperty.all(Colors.white),
                              value:
                                  !editMode ? exam.orderMatters : orderMatters,
                              onChanged: (bool? newValue) {
                                if (editMode) {
                                  setState(() {
                                    logger.i(newValue);
                                    orderMatters = newValue ?? false;
                                    // Additional logic can be added here based on the new value
                                  });
                                  field.didChange(newValue);
                                }
                              });
                        })

                    // Container(
                    //   width: screenWidth * 0.1,
                    //   child: FormBuilderCheckbox(
                    //     name: 'orderMatters',
                    //     enabled: editMode,
                    //   initialValue: exam.orderMatters,
                    //   title: SizedBox(),
                    //   ),
                    // )
                  ],
                ),
                AnimatedContainer(
                  duration: editSwitchTime,
                  height:
                      !editMode ? screenHeight * 0.015 : screenHeight * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.restore_page_outlined,
                          color: Colors.white,
                          size: screenWidth * 0.08,
                        ),
                        SizedBox(width: 10),
                        Text(
                          _localizations.revisionDays,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.05),
                        )
                      ],
                    ),
                    AnimatedContainer(
                      duration: editSwitchTime,
                      width: !editMode ? screenWidth * 0.12 : screenWidth * 0.2,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: plusMinusField(
                          duration: editSwitchTime,
                          toggle: editMode,
                          number: revisions,
                          addNumberToParent: (int value) {
                            setState(() {
                              revisions += value;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
                AnimatedContainer(
                  duration: editSwitchTime,
                  height:
                      !editMode ? screenHeight * 0.015 : screenHeight * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.av_timer,
                          color: Colors.white,
                          size: screenWidth * 0.08,
                        ),
                        SizedBox(width: 10),
                        Text(_localizations.revisionTime,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04))
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (editMode) {
                          revisionTime = await showDurationPicker(
                                context: context,
                                initialTime: revisionTime,
                              ) ??
                              revisionTime;
                          setState(() {
                            revisionTime = revisionTime;
                          });
                          logger.i(revisionTime);
                        }
                      },
                      child: Text(formatDuration(revisionTime),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: screenWidth * 0.05)),
                    )
                  ],
                ),
                AnimatedContainer(
                  duration: editSwitchTime,
                  height:
                      !editMode ? screenHeight * 0.015 : screenHeight * 0.03,
                ),
                AnimatedSwitcher(
                    duration: editSwitchTime,
                    child: editMode
                        ? Container(
                            width: screenWidth * 0.9,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.brush,
                                  color: Colors.white,
                                  size: screenWidth * 0.08,
                                ),
                                SizedBox(width: 10),
                                Text(_localizations.color,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.05)),
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
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox()),
              ],
            ),
          )),
    );

    return Container(
      height: screenHeight * 0.8,
      width: screenWidth * 0.9,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SingleChildScrollView(
          physics: !editMode
              ? AlwaysScrollableScrollPhysics()
              : NeverScrollableScrollPhysics(),
          child: AnimatedContainer(
            duration: editSwitchTime,
            height: screenHeight * 0.82,
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenWidth * 0.01),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  end: Alignment.bottomLeft,
                  begin: Alignment.topRight,
                  stops: [0.05, 0.3, 0.9],
                  colors: !editMode
                      ? [lighterColor, cardColor, darkerColor]
                      : [Colors.black, darken(darkerColor, .5), darkerColor]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedSwitcher(
                      duration: editSwitchTime,
                      child: !editMode
                          ? Container(
                              key: ValueKey<int>(0),
                              width: screenWidth * 0.4,
                              height: screenHeight * 0.06,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 3),
                                    padding: EdgeInsets.all(2),
                                    child: IconButton(
                                        iconSize: screenWidth * 0.1,
                                        onPressed: () {
                                          //return
                                          widget.pageController.animateToPage(0,
                                              duration:
                                                  Duration(milliseconds: 300),
                                              curve: Curves.decelerate);
                                        },
                                        icon: Icon(Icons.close_rounded,
                                            color: Colors.white,
                                            size: screenWidth * 0.08)),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              // cancel edit
                              key: ValueKey<int>(1),
                              height: screenHeight * 0.06,
                              width: screenWidth * 0.4,
                              padding: EdgeInsets.all(2),
                              child: AnimatedSwitcher(
                                duration: editSwitchTime,
                                child: !loading
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextButton.icon(
                                              key: ValueKey<int>(1),
                                              onPressed: () {
                                                logger.i('Cancel clicked!');
                                                editExamFormKey.currentState!
                                                    .reset();
                                                setState(() {
                                                  editMode = false;

                                                  orderMatters =
                                                      exam.orderMatters;
                                                  revisions =
                                                      exam.revisions.length;
                                                  revisionTime =
                                                      exam.revisionTime;
                                                  examDate = exam.examDate;
                                                  examColor = exam.color;
                                                });
                                              },
                                              label: Text(_localizations.cancel,
                                                  style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize:
                                                          screenWidth * 0.05)),
                                              icon: Icon(
                                                Icons.close_rounded,
                                                color: Colors.redAccent,
                                                size: screenWidth * 0.08,
                                              ))
                                        ],
                                      )
                                    : SizedBox(),
                              ),
                            ),
                    ),
                    AnimatedSwitcher(
                      duration: editSwitchTime,
                      child: !editMode
                          ? TextButton.icon(
                              onPressed: () {
                                //toggle edit
                                setState(() {
                                  editMode = true;
                                });
                              },
                              icon: Icon(Icons.edit, color: Colors.white),
                              label: Text(_localizations.edit,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w400)))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                AnimatedSwitcher(
                                    duration: editSwitchTime,
                                    child: !loading
                                        ? TextButton.icon(
                                            key: ValueKey<int>(0),
                                            onPressed: () async {
                                              //confirm edit
                                              logger.i('Confirm clicked!');
                                              setState(() {
                                                loading = true;
                                              });

                                              if (editExamFormKey!.currentState!
                                                  .validate()) {
                                                editExamFormKey!.currentState!
                                                    .save();
                                                try {
                                                  await _controller
                                                      .handleEditExam(
                                                          editExamFormKey,
                                                          widget.exam,
                                                          revisions,
                                                          revisionTime,
                                                          examColor);
                                                } catch (e) {
                                                  logger.e(
                                                      'Error editing exam: $e');
                                                  editExamFormKey.currentState!
                                                      .reset();
                                                  showRedSnackbar(
                                                      context,
                                                      _localizations
                                                          .errorEditingExam);
                                                }

                                                final activeExams =
                                                    instanceManager
                                                        .sessionStorage
                                                        .activeExams;

                                                setState(() {
                                                  loading = false;
                                                  editMode = false;
                                                  widget.exam =
                                                      activeExams.firstWhere(
                                                          (examToFind) =>
                                                              examToFind.id ==
                                                              exam.id);
                                                  exam = widget.exam;
                                                  orderMatters =
                                                      exam.orderMatters;
                                                  revisions =
                                                      exam.revisions.length;
                                                  revisionTime =
                                                      exam.revisionTime;
                                                  examDate = exam.examDate;
                                                  examColor = exam.color;
                                                });
                                              }
                                            },
                                            label: Text(_localizations.confirm,
                                                style: TextStyle(
                                                    color: Colors.greenAccent,
                                                    fontSize:
                                                        screenWidth * 0.05)),
                                            icon: Icon(
                                              Icons.done,
                                              color: Colors.greenAccent,
                                              size: screenWidth * 0.08,
                                            ))
                                        : TextButton.icon(
                                            key: ValueKey<int>(1),
                                            onPressed: () {},
                                            label: Text(_localizations.loading,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenWidth * 0.05)),
                                            icon: Icon(
                                              Icons.edit_outlined,
                                              color: Colors.white,
                                              size: screenWidth * 0.08,
                                            ))),
                              ],
                            ),
                    )
                  ],
                ),
                examData
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void loadUnits() async {
  //   await widget.exam.getUnits();
  //   await widget.exam.getRevisions();
  //   setState(() {});
  // }

  // Expanded getUnitList() {
  //   return Expanded(
  //     child: Container(
  //       child: ListView.builder(
  //         scrollDirection: Axis.vertical,
  //         shrinkWrap: true,
  //         itemCount: widget.exam.units!.length,
  //         itemBuilder: (context, index) {
  //           final unit = widget.exam.units![index];

  //           return Dismissible(
  //             key: Key(unit.id),
  //             background: Container(
  //               color: const Color.fromARGB(255, 255, 77, 65),
  //               child: Icon(
  //                 Icons.delete,
  //                 color: Colors.white,
  //               ),
  //               alignment: Alignment.centerRight,
  //               padding: EdgeInsets.only(right: 20.0),
  //             ),
  //             onDismissed: (direction) async {
  //               widget.exam.units!.removeAt(index);
  //               await widget.exam.deleteUnit(unit: unit);
  //               setState(() {
  //                 instanceManager.sessionStorage.needsRecalculation = true;
  //               });
  //             },
  //             child: UnitCard(
  //               unit: unit,
  //               exam: widget.exam,
  //               notifyParent: loadUnits,
  //               showError: showError,
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  // void showError(String message) {
  //   SnackBar snackBar = SnackBar(
  //     content: Text(message),
  //     backgroundColor: Color.fromARGB(255, 221, 15, 0),
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }
}



// Container(
//   padding: EdgeInsets.all(30),
//   child: editMode == false
//       ? Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.exam.name,
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Text('Weight: ${widget.exam.weight}'),
//             Text(
//                 'Session time: ${formatDuration(widget.exam.sessionTime)}'),
//             Text('Exam Date: ${widget.exam.examDate}'),
//             Text('Order Matters: ${widget.exam.orderMatters}'),
//             Text('Revisions: ${widget.exam.revisions.length}'),
//             IconButton(
//                 onPressed: () {
//                   setState(() {
//                     editMode = true;
//                   });
//                 },
//                 icon: Icon(Icons.edit)),
//             Container(
//               height: screenHeight * 0.05,
//               padding: EdgeInsets.all(3),
//               child: loading == false
//                   ? ElevatedButton(
//                       onPressed: () async {
//                         setState(() {
//                           loading = true;
//                         });
//                         await widget.exam.addUnit();
//                         setState(() {
//                           instanceManager.sessionStorage
//                               .needsRecalculation = true;
//                           loading = false;
//                         });
//                       },
//                       child: Text(_localizations.addUnit))
//                   : CircularProgressIndicator(),
//             ),
//             widget.exam.units == null
//                 ? loadingScreen()
//                 : getUnitList()
//           ],
//         )
//       : SingleChildScrollView(
//           child: Container(
//               child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               FormBuilder(
//                   key: examFormKey,
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       FormBuilderTextField(
//                         name: 'examName',
//                         autovalidateMode:
//                             AutovalidateMode.onUserInteraction,
//                         decoration: InputDecoration(
//                             labelText: _localizations.unitName),
//                         style: TextStyle(color: Colors.black),
//                         initialValue: widget.exam.name,
//                         validator:
//                             FormBuilderValidators.compose([]),
//                       ),
//                       FormBuilderSlider(
//                         name: 'weightSlider',
//                         initialValue: widget.exam.weight,
//                         min: 0.0,
//                         max: 2.0,
//                         divisions: 20,
//                         decoration: InputDecoration(
//                             labelText:
//                                 _localizations.examWeight),
//                         autovalidateMode:
//                             AutovalidateMode.onUserInteraction,
//                         validator:
//                             FormBuilderValidators.compose([]),
//                       ),
//                       FormBuilderTextField(
//                         name: 'sessionTime',
//                         autovalidateMode:
//                             AutovalidateMode.onUserInteraction,
//                         keyboardType: TextInputType.number,
//                         initialValue:
//                             '${durationToDouble(widget.exam.sessionTime)}',
//                         decoration: InputDecoration(
//                             labelText:
//                                 _localizations.sessionTime,
//                             suffix: Text(_localizations.hours)),
//                         style: TextStyle(color: Colors.white),
//                         validator:
//                             FormBuilderValidators.compose([
//                           FormBuilderValidators.numeric()
//                         ]),
//                       ),
//                       FormBuilderDateTimePicker(
//                         name: 'examDate',
//                         autovalidateMode:
//                             AutovalidateMode.onUserInteraction,
//                         inputType: InputType.date,
//                         enabled: true,
//                         initialValue: widget.exam.examDate,
//                         decoration: InputDecoration(
//                             labelText: _localizations.examDate),
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16.0,
//                             fontWeight: FontWeight.normal),
//                         validator:
//                             FormBuilderValidators.compose([]),
//                       ),
//                       FormBuilderCheckbox(
//                           name: 'orderMatters',
//                           initialValue:
//                               widget.exam.orderMatters,
//                           title: Text(
//                               _localizations.orderMatters)),
//                       FormBuilderTextField(
//                         name: 'revisions',
//                         autovalidateMode:
//                             AutovalidateMode.onUserInteraction,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         initialValue: widget
//                             .exam.revisions.length
//                             .toString(),
//                         decoration: InputDecoration(
//                           labelText:
//                               _localizations.numberOfRevisions,
//                         ),
//                         style: TextStyle(color: Colors.white),
//                         validator:
//                             FormBuilderValidators.compose([
//                           FormBuilderValidators.required(),
//                           FormBuilderValidators.numeric()
//                         ]),
//                       ),
//                     ],
//                   )),
//               loading == false
//                   ? IconButton(
//                       onPressed: () async {
//                         setState(() {
//                           loading = true;
//                         });
//                         int? res =
//                             await _controller.handleEditExam(
//                                 examFormKey, widget.exam);

//                         if (res == -1) {
//                           showError(
//                               _localizations.errorEditingExam);
//                         }
//                         if (res == -2) {
//                           showError(_localizations.wrongDates);
//                         } else {
//                           widget.exam = await instanceManager
//                               .firebaseCrudService
//                               .getExam(widget.exam.id);

//                           await widget.exam.getUnits();
//                           await widget.exam.getRevisions();
//                           widget.refreshParent();

//                           setState(() {
//                             editMode = false;
//                             loading = false;
//                           });
//                         }
//                       },
//                       icon: Icon(Icons.check))
//                   : CircularProgressIndicator(),
//             ],
//           )),
//         ),
// ),
