import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/exams/exam_detail_view.dart';
import 'package:study_buddy/services/logging_service.dart';

class UnitCard extends StatefulWidget {
  UnitModel unit;
  ExamModel exam;
  Function notifyParent;
  Function showError;
  Color lightShade;
  Color darkShade;
  bool editMode;
  GlobalKey<FormBuilderState> formKey;

  UnitCard(
      {required this.unit,
      required this.exam,
      required Function this.notifyParent,
      required Function this.showError,
      required this.lightShade,
      required this.darkShade,
      required this.editMode,
      required this.formKey});

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard>
    with SingleTickerProviderStateMixin {
  final _controller = instanceManager.examController;
  var editMode = false;
  final unitFormKey = GlobalKey<FormBuilderState>();
  //UnitModel unit = UnitModel(name: 'init', order: 0);
  bool open = false;
  late AnimationController _animationController;
  Duration openUnit = Duration(milliseconds: 200);
  Color expandableColor = Color.fromARGB(255, 61, 61, 61);
  Color expandableEditColor = Colors.black;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //unit = widget.unit;
    _animationController = AnimationController(
      vsync: this,
      duration: openUnit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final _localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: widget.editMode ? widget.darkShade : widget.lightShade,
      child: AnimatedContainer(
        duration: openUnit,
        height: !open ? screenHeight * 0.07 : screenHeight * 0.14,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Theme(
                data: ThemeData().copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor:
                      widget.editMode ? expandableEditColor : expandableColor,
                  collapsedIconColor:
                      widget.editMode ? expandableEditColor : expandableColor,
                  backgroundColor: Colors.transparent,
                  trailing: RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.5)
                          .animate(_animationController),
                      child: Icon(Icons.expand_more,
                          color: widget.editMode
                              ? expandableEditColor
                              : expandableColor)),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      open = expanded;
                      if (open) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  title: Row(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: screenWidth * 0.47,
                        child: widget.editMode
                            ? Container(
                                width: screenWidth * 0.47,
                                child: FormBuilderTextField(
                                  key: Key(widget.unit.name),
                                  textCapitalization: TextCapitalization.words,
                                  name: 'Unit ${widget.unit.order} name',
                                  initialValue: widget.unit.name,
                                  readOnly: !widget.editMode,
                                  decoration: const InputDecoration(
                                    border:
                                        InputBorder.none, // Remove the border
                                    focusedBorder: InputBorder
                                        .none, // Remove the focused border
                                  ),
                                  style: TextStyle(
                                      color: widget.editMode
                                          ? expandableEditColor
                                          : expandableColor,
                                      fontSize: screenWidth * 0.05),
                                  scrollPadding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                ),
                              )
                            : Text(widget.unit.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    //fontWeight: open ? FontWeight.w600: FontWeight.normal,
                                    color: widget.editMode
                                        ? expandableEditColor
                                        : expandableColor,
                                    fontSize: screenWidth * 0.05)),
                      ),
                      SizedBox(
                        width: screenWidth * 0.02,
                      ),
                      AnimatedSwitcher(
                        duration: openUnit,
                        child: widget.unit.completed && !open
                            ? Container(
                                key: ValueKey<int>(0),
                                margin: EdgeInsets.only(
                                    bottom: screenHeight * 0.005),
                                child: Icon(
                                  Icons.done,
                                  size: screenWidth * 0.08,
                                  color: widget.editMode
                                      ? Colors.white
                                      : Colors.green,
                                ),
                              )
                            : SizedBox(
                                key: ValueKey<int>(1),
                              ),
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                      onPressed: () async {
                        if (widget.editMode) {
                          widget.unit.sessionTime = await showDurationPicker(
                                context: context,
                                initialTime: widget.unit.sessionTime,
                              ) ??
                              widget.unit.sessionTime;
                        }
                        setState(() {});
                      },
                      icon: Icon(Icons.av_timer,
                          size: screenWidth * 0.06,
                          color: widget.editMode
                              ? expandableEditColor
                              : expandableColor),
                      label: Text(formatDuration(widget.unit.sessionTime),
                          style: TextStyle(
                              color: widget.editMode
                                  ? expandableEditColor
                                  : expandableColor,
                              fontSize: screenWidth * 0.04))),
                  Container(
                    margin: EdgeInsets.only(right: screenWidth * 0.035),
                    child: Row(
                      children: [
                        Text(_localizations.completed,
                            style: TextStyle(
                                color: widget.editMode
                                    ? expandableEditColor
                                    : expandableColor,
                                fontSize: screenWidth * 0.04)),
                        Checkbox(
                            visualDensity: VisualDensity(
                                horizontal: -4, vertical: -4),
                            activeColor: Colors.black,
                            checkColor: editMode
                                ? widget.darkShade
                                : Colors.white, // Color of the checkmark
                            fillColor:
                                MaterialStateProperty.all(Colors.black),
                            value: widget.unit.completed,
                            onChanged: (bool? newValue) {
                              if (widget.editMode) {
                                setState(() {
                                  widget.unit.completed =
                                      newValue ?? false;
                                });
                              }
                            })
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
