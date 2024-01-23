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
import 'package:study_buddy/models/unit_model.dart';
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
  List<UnitModel> prechangeUnits = <UnitModel>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _provisionalListLength = 0;

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

  void addUnit(UnitModel newUnit) {
    final index = widget.exam.units.length;
    widget.exam.units.add(newUnit);
    _listKey.currentState?.insertItem(index);
    _provisionalListLength = widget.exam.units.length;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    final cardColor = examColor;
    final lighterColor = lighten(cardColor, .04);
    final darkerColor = darken(cardColor, .2);
    ExamModel exam = widget.exam;

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

    var examData = Container(
        //color:Colors.yellow.withOpacity(0.3), // delet this

        padding: EdgeInsets.only(
            top: screenWidth * 0.05,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05),
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
                                  initialValue: widget.exam.name,
                                  readOnly: !editMode,
                                  decoration: InputDecoration(),
                                  style: TextStyle(
                                    height: 1,
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.11,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  scrollPadding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  onChanged: (value) {
                                    exam.name = value!;
                                  },
                                ),
                              )
                            : MarqueeWidget(
                                animationDuration: Duration(
                                    seconds:
                                        (widget.exam.name.length / 6).toInt()),
                                backDuration: Duration(
                                    seconds:
                                        (widget.exam.name.length / 9).toInt()),
                                child: Text(
                                  widget.exam.name,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.14,
                                      fontWeight: FontWeight.w300),
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
                    ? Text(
                        DateFormat('EEE, M/d/y').format(widget.exam.examDate),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w300))
                    : FormBuilderDateTimePicker(
                        scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        name: "examDate",
                        inputType: InputType.date,
                        decoration: InputDecoration.collapsed(hintText: ''),
                        initialValue: widget.exam.examDate,
                        format: DateFormat('EEE, M/d/y'),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          futureDateValidator,
                        ]),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
            AnimatedContainer(
              duration: editSwitchTime,
              height: !editMode ? screenHeight * 0.2 : screenHeight * 0.04,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                reverse: true,
                child: Column(
                  children: [
                    Row(
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
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.05))
                      ],
                    ),
                    Container(
                      height: screenHeight * 0.015,
                    ),
                    Row(
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
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.05))
                      ],
                    ),
                    Container(
                      height: screenHeight * 0.015,
                    ),
                    Row(
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
                        Text(formatDuration(widget.exam.timeStudied),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.05))
                      ],
                    ),
                    AnimatedContainer(
                      duration: editSwitchTime,
                      margin:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      color: !editMode ? Colors.white : Colors.transparent,
                      height: 2,
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: screenHeight * 0.005,
            ),
            AnimatedContainer(
              duration: editSwitchTime,
              height: !editMode ? screenHeight * 0.15 : screenHeight * 0.31,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
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
                            initialValue: widget.exam.orderMatters,
                            builder: (FormFieldState<dynamic> field) {
                              return Checkbox(
                                  visualDensity: VisualDensity(
                                      horizontal: -4,
                                      vertical:
                                          -4), // Adjust the values as needed
                                  activeColor: Colors
                                      .white, // Color when checkbox is checked
                                  checkColor:
                                      Colors.black, // Color of the checkmark
                                  fillColor:
                                      MaterialStateProperty.all(Colors.white),
                                  value: !editMode
                                      ? widget.exam.orderMatters
                                      : orderMatters,
                                  onChanged: (bool? newValue) {
                                    if (editMode) {
                                      setState(() {
                                        //logger.i(newValue);
                                        orderMatters = newValue ?? false;
                                        // Additional logic can be added here based on the new value
                                      });
                                      field.didChange(newValue);
                                    }
                                  });
                            })
                      ],
                    ),
                    AnimatedContainer(
                      duration: editSwitchTime,
                      height: !editMode
                          ? screenHeight * 0.015
                          : screenHeight * 0.04,
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
                          width: !editMode
                              ? screenWidth * 0.12
                              : screenWidth * 0.2,
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
                      height: !editMode
                          ? screenHeight * 0.015
                          : screenHeight * 0.04,
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
                              //logger.i(revisionTime);
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
                      height: !editMode
                          ? screenHeight * 0.015
                          : screenHeight * 0.03,
                    ),
                    Container(
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));

    var unitsList = AnimatedList(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      key: _listKey,
      initialItemCount: widget.exam.units.length,
      itemBuilder: (context, index, animation) {
        ////logger.i('$index, ${widget.exam.units.length}');
        try {
          final unit = widget.exam.units[index];

          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: Dismissible(
              key: Key(unit.id),
              onDismissed: (direction) {
                if (editMode) {
                  UnitModel removedItem = widget.exam.units
                      .removeAt(widget.exam.units.indexOf(unit));

                  _listKey.currentState?.removeItem(
                    index,
                    (context, animation) => SizedBox
                        .shrink(), // Use an empty SizedBox to suppress the animation
                    duration: Duration
                        .zero, // Set the duration to zero to eliminate the animation
                  );

                  widget.exam.updateUnitOrders(editExamFormKey);
                  widget.exam.printMe();

                  setState(() {});
                }
              },
              child: UnitCard(
                textEditingController: TextEditingController(text: unit.name),
                unit: unit,
                exam: exam,
                notifyParent: () {},
                showError: () {},
                lightShade: lighten(examColor, 0.5),
                darkShade: examColor,
                editMode: editMode,
              ),
            ),
          );
        } catch (e) {
          logger.e('Error rendering list item. $e');

          return SizedBox();
        }
      },
    );

    return Container(
      height: screenHeight * 0.8,
      width: screenWidth * 0.9,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //clipBehavior: Clip.antiAliasWithSaveLayer,
        child: AnimatedContainer(
          duration: editSwitchTime,
          height: screenHeight * 0.85,
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
                                              //logger.i('Cancel clicked!');

                                              editExamFormKey.currentState!
                                                  .reset();

                                              ////logger.i('A');
                                              ///

                                              try {
                                                if (prechangeUnits.length <
                                                    widget.exam.units.length) {
                                                  for (int i =
                                                          prechangeUnits.length;
                                                      i < _provisionalListLength;
                                                      i++) {
                                                    UnitModel removedItem =
                                                        widget.exam.units
                                                            .removeAt(
                                                                prechangeUnits
                                                                    .length);

                                                    _listKey.currentState!
                                                        .removeItem(
                                                            widget.exam.units
                                                                .length,
                                                            (context,
                                                                    animation) =>
                                                                SizedBox
                                                                    .shrink(), // Use an empty SizedBox to suppress the animation
                                                            duration:
                                                                Duration.zero);
                                                  }
                                                } else if (prechangeUnits
                                                        .length >
                                                    widget.exam.units.length) {
                                                  for (int i = widget
                                                          .exam.units.length;
                                                      i < prechangeUnits.length;
                                                      i++) {
                                                    _listKey.currentState!
                                                        .insertItem(i);
                                                  }
                                                }
                                              } catch (e) {
                                                logger.i(
                                                    'old list is not longer than new one');
                                              }

                                              setState(() {
                                                editMode = false;

                                                orderMatters =
                                                    widget.exam.orderMatters;
                                                revisions = widget
                                                    .exam.revisions.length;
                                                revisionTime =
                                                    widget.exam.revisionTime;
                                                examDate = widget.exam.examDate;
                                                examColor = widget.exam.color;
                                                widget.exam.units =
                                                    prechangeUnits
                                                        .map((unit) =>
                                                            unit.deepCopy())
                                                        .toList();
                                              });
                                              // Map<String, dynamic> formFields =
                                              //     editExamFormKey
                                              //         .currentState!.fields;

                                              // formFields.forEach(
                                              //     (fieldName, fieldState) {
                                              //   logger.d(
                                              //       '$fieldName: ${fieldState.value}');
                                              // });

                                              // for (UnitModel unit
                                              //     in widget.exam.units) {
                                              //   logger.i('Pre: ' +
                                              //       editExamFormKey
                                              //           .currentState!
                                              //           .fields['${unit.id}']!
                                              //           .value);

                                              //   editExamFormKey.currentState!
                                              //       .fields['${unit.id}']!
                                              //       .setValue(unit.name);
                                              //   logger.i('Post: ' +
                                              //       editExamFormKey
                                              //           .currentState!
                                              //           .fields['${unit.id}']!
                                              //           .value);
                                              // }

                                              widget.exam.printMe();

                                              //widget.exam.printMe();
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
                        ? Container(
                            width: screenWidth * 0.36,
                            key: ValueKey<int>(0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                    onPressed: () {
                                      //toggle edit

                                      widget.exam.printMe();

                                      setState(() {
                                        editMode = true;
                                        prechangeUnits = widget.exam.units
                                            .map((unit) => unit.deepCopy())
                                            .toList();
                                      });
                                    },
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    label: Text(_localizations.edit,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.w400))),
                              ],
                            ),
                          )
                        : Container(
                            width: screenWidth * 0.36,
                            key: ValueKey<int>(1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedSwitcher(
                                    duration: editSwitchTime,
                                    child: !loading
                                        ? Container(
                                            width: screenWidth * 0.36,
                                            child: TextButton.icon(
                                                key: ValueKey<int>(0),
                                                onPressed: () async {
                                                  //confirm edit
                                                  //logger.i('Confirm clicked!');

                                                  if (editExamFormKey!
                                                      .currentState!
                                                      .validate()) {
                                                    editExamFormKey!
                                                        .currentState!
                                                        .save();
                                                    setState(() {
                                                      loading = true;
                                                    });

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
                                                      editExamFormKey
                                                          .currentState!
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
                                                      widget.exam = activeExams
                                                          .firstWhere(
                                                              (examToFind) =>
                                                                  examToFind
                                                                      .id ==
                                                                  widget
                                                                      .exam.id);

                                                      orderMatters = widget
                                                          .exam.orderMatters;
                                                      revisions = widget.exam
                                                          .revisions.length;
                                                      revisionTime = widget
                                                          .exam.revisionTime;
                                                      examDate =
                                                          widget.exam.examDate;
                                                      examColor =
                                                          widget.exam.color;
                                                    });
                                                    widget.exam.printMe();
                                                  }
                                                },
                                                label: Text(
                                                    _localizations.confirm,
                                                    style: TextStyle(
                                                        color:
                                                            Colors.greenAccent,
                                                        fontSize: screenWidth *
                                                            0.05)),
                                                icon: Icon(
                                                  Icons.done,
                                                  color: Colors.greenAccent,
                                                  size: screenWidth * 0.08,
                                                )),
                                          )
                                        : Container(
                                            width: screenWidth * 0.36,
                                            child: TextButton.icon(
                                                key: ValueKey<int>(1),
                                                onPressed: () {},
                                                label: Text(
                                                    _localizations.loading,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: screenWidth *
                                                            0.04)),
                                                icon: Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.white,
                                                  size: screenWidth * 0.05,
                                                )),
                                          )),
                              ],
                            ),
                          ),
                  )
                ],
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Container(
                height: screenHeight * 0.73,
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.purple
                      ],
                      stops: [
                        0.0,
                        0.01,
                        0.95,
                        1.0
                      ], // 10% purple, 80% transparent, 10% purple
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: FormBuilder(
                      key: editExamFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          examData,
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          AnimatedSwitcher(
                            duration: editSwitchTime,
                            child: editMode
                                ? Container(
                                    key: Key('0'),
                                    height: screenHeight * 0.03,
                                    child: Text(_localizations.swipeToDelete,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.035)),
                                  )
                                : SizedBox(
                                    key: Key('1'),
                                    height: screenHeight * 0.03,
                                  ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05),
                            child: unitsList,
                          ),
                          AnimatedSwitcher(
                            duration: editSwitchTime,
                            child: editMode
                                ? Container(
                                    key: Key('0'),
                                    height: screenHeight * 0.05,
                                    child: IconButton(
                                        onPressed: () {
                                          // //logger.i(
                                          //     'Pre: ${widget.exam.units.length}');
                                          addUnit(UnitModel(
                                              name:
                                                  'Unit ${widget.exam.units.length + 1}',
                                              order:
                                                  widget.exam.units.length + 1,
                                              id: generateRandomString()));
                                          widget.exam.printMe();
                                          // //logger.i(
                                          //     'Post: ${widget.exam.units.length}');
                                        },
                                        icon: Icon(Icons.add,
                                            color: Colors.white)),
                                  )
                                : SizedBox(
                                    key: Key('1'),
                                    height: screenHeight * 0.05,
                                  ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.05,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
