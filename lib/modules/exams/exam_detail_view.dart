import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

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
  Function updateParent;

  ExamDetailView(
      {super.key,
      required ExamModel this.exam,
      required this.refreshParent,
      required this.pageController,
      required this.updateParent});

  @override
  State<ExamDetailView> createState() => _ExamDetailViewState();
}

class _ExamDetailViewState extends State<ExamDetailView> {
  final _controller = instanceManager.examsController;
  bool editMode = false;
  final editExamFormKey = GlobalKey<FormBuilderState>();

  bool loading = false;
  Duration editSwitchTime = Duration(milliseconds: 300);
  bool orderMatters = false;
  bool sessionsSplittable = false;
  int revisions = 0;
  Duration revisionTime = Duration(seconds: 0);
  DateTime examDate = DateTime.now();
  Color examColor = Colors.white;
  String position = '';
  List<UnitModel> prechangeUnits = <UnitModel>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _provisionalListLength = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    orderMatters = widget.exam.orderMatters;
    sessionsSplittable = widget.exam.sessionsSplittable;
    revisions = widget.exam.revisions.length;
    revisionTime = widget.exam.revisionTime;
    examDate = widget.exam.examDate;
    examColor = widget.exam.color;
    position = getPosition(widget.exam);
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void addUnit(UnitModel newUnit) {
    final index = widget.exam.units.length;
    widget.exam.units.add(newUnit);
    _listKey.currentState?.insertItem(index);
    _provisionalListLength = widget.exam.units.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollDown();
    });
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
                    ? Text(formatDateTime(context, widget.exam.examDate),
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
                        format: DateFormat.yMMMMd(
                            Localizations.localeOf(context).toString()),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
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
              height: !editMode ? screenHeight * 0.2 : screenHeight * 0.36,
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
                            Text(_localizations.keepSessionsInDay,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.043))
                          ],
                        ),
                        FormBuilderField<bool>(
                            name: 'sessionSplittable',
                            enabled: editMode,
                            initialValue: widget.exam.sessionsSplittable,
                            builder: (FormFieldState<dynamic> field) {
                              return Checkbox(
                                  visualDensity: VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                  fillColor:
                                      MaterialStateProperty.all(Colors.white),
                                  value: !editMode
                                      ? widget.exam.sessionsSplittable
                                      : sessionsSplittable,
                                  onChanged: (bool? newValue) {
                                    if (editMode) {
                                      setState(() {
                                        sessionsSplittable = newValue ?? false;
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
                                      horizontal: -4, vertical: -4),
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                  fillColor:
                                      MaterialStateProperty.all(Colors.white),
                                  value: !editMode
                                      ? widget.exam.orderMatters
                                      : orderMatters,
                                  onChanged: (bool? newValue) {
                                    if (editMode) {
                                      setState(() {
                                        orderMatters = newValue ?? false;
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
                              revisionTime = await showTimerPicker(context, revisionTime);
                              if (revisionTime == Duration.zero) {
                                revisionTime = const Duration(minutes: 1);
                                showRedSnackbar(context,
                                    _localizations.sessionTimeCantBeZero);
                              }
                              setState(() {});
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
        try {
          final unit = widget.exam.units[index];

          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: Dismissible(
                key: Key(unit.id),
                onDismissed: (direction) {
                  if (editMode) {
                    widget.exam.units.removeAt(widget.exam.units.indexOf(unit));

                    _listKey.currentState?.removeItem(
                      index,
                      (context, animation) => SizedBox.shrink(),
                      duration: Duration.zero,
                    );

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
        child: AnimatedContainer(
          duration: editSwitchTime,
          height: screenHeight * 0.85,
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenWidth * 0.01),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
                end: Alignment.bottomLeft,
                begin: Alignment.topRight,
                stops: const [0.05, 0.3, 0.9],
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

                                        widget.updateParent();
                                        instanceManager.sessionStorage
                                            .activeOrAllExams = 0;

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
                                              // cancel
                                              closeKeyboard(context);

                                              editExamFormKey.currentState!
                                                  .reset();

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
                                                                    .shrink(),
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
                                              } catch (e) {}

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
                                                  closeKeyboard(context);

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
                                                          'Error editing exam (handleEditExam): $e');
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

                                                    final pastExams =
                                                        instanceManager
                                                            .sessionStorage
                                                            .pastExams;

                                                    try {
                                                      setState(() {
                                                        loading = false;
                                                        editMode = false;
                                                        ExamModel examData =
                                                            instanceManager
                                                                .sessionStorage
                                                                .examToAdd;

                                                        try {
                                                          examData = activeExams
                                                              .firstWhere(
                                                                  (examToFind) =>
                                                                      examToFind
                                                                          .id ==
                                                                      widget
                                                                          .exam
                                                                          .id);
                                                        } catch (e) {
                                                          examData = pastExams
                                                              .firstWhere(
                                                                  (examToFind) =>
                                                                      examToFind
                                                                          .id ==
                                                                      widget
                                                                          .exam
                                                                          .id);
                                                        }

                                                        widget.exam = examData;

                                                        orderMatters = widget
                                                            .exam.orderMatters;
                                                        revisions = widget.exam
                                                            .revisions.length;
                                                        revisionTime = widget
                                                            .exam.revisionTime;
                                                        examDate = widget
                                                            .exam.examDate;
                                                        examColor =
                                                            widget.exam.color;
                                                      });
                                                    } catch (e) {
                                                      logger.e(
                                                          'Error editing exam (buttonClick): $e');
                                                    }
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
                                                icon: Container(
                                                  width: screenWidth * 0.05,
                                                  height: screenWidth * 0.05,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
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
                      stops: [0.0, 0.01, 0.95, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: SingleChildScrollView(
                    controller: _scrollController,
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
                                    height: 1,
                                  ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05),
                            child: unitsList,
                          ),
                          AnimatedContainer(
                            duration: editSwitchTime,
                            height: editMode ? screenHeight * 0.05 : 0,
                            child: SingleChildScrollView(
                              child: Container(
                                key: Key('0'),
                                height: screenHeight * 0.05,
                                child: IconButton(
                                    onPressed: () {
                                      addUnit(UnitModel(
                                          name:
                                              ' ${_localizations.unit} ${widget.exam.units.length + 1}',
                                          order: widget.exam.units.length + 1,
                                          id: generateRandomString()));
                                    },
                                    icon: Icon(Icons.add, color: Colors.white)),
                              ),
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
