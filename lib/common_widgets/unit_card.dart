import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
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
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/utils/general_utils.dart';

class UnitCard extends StatefulWidget {
  UnitModel unit;
  ExamModel exam;
  Function notifyParent;
  Function showError;
  Color lightShade;
  Color darkShade;
  bool editMode;
  TextEditingController textEditingController;

  UnitCard(
      {required this.unit,
      required this.exam,
      required Function this.notifyParent,
      required Function this.showError,
      required this.lightShade,
      required this.darkShade,
      required this.editMode,
      required this.textEditingController});

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard>
    with SingleTickerProviderStateMixin {
  final _controller = instanceManager.examsController;
  var editMode = false;

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
    widget.textEditingController.selection = TextSelection.collapsed(
        offset: widget.textEditingController.text.length);
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: widget.editMode ? widget.darkShade : widget.lightShade,
      child: AnimatedContainer(
        duration: openUnit,
        height: !open ? screenHeight * 0.08 : screenHeight * 0.15,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.016,
                    horizontal: screenWidth * 0.035),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          //width: screenWidth * 0.55,
                          child: widget.editMode
                              ? Container(
                                  constraints: BoxConstraints(
                                      maxWidth: screenWidth * 0.45,
                                      minWidth: screenWidth * 0.2),
                                  child: IntrinsicWidth(
                                    child: TextField(
                                      //TODO: change to a normal textfield and save like completed
                                      //key: Key(widget.unit.id),

                                      textCapitalization:
                                          TextCapitalization.words,
                                      onChanged: (value) =>
                                          widget.unit.name = value,

                                      controller: widget.textEditingController,
                                      readOnly: !widget.editMode,
                                      decoration: InputDecoration(
                                        border: InputBorder
                                            .none, // Remove the border
                                        isDense: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the border radius
                                        ),
                                        focusedBorder: InputBorder
                                            .none, // Remove the focused border
                                        fillColor:
                                            Colors.white.withOpacity(0.5),
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
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
                                  ),
                                )
                              : Container(
                                  constraints: BoxConstraints(
                                      maxWidth: screenWidth * 0.45),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.5, vertical: 5),
                                  child: Text(widget.unit.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          //fontWeight: open ? FontWeight.w600: FontWeight.normal,
                                          color: widget.editMode
                                              ? expandableEditColor
                                              : expandableColor,
                                          fontSize: screenWidth * 0.05)),
                                ),
                        ),
                        AnimatedSwitcher(
                          duration: openUnit,
                          child: widget.unit.completed && !open
                              ? Container(
                                  key: ValueKey<int>(0),
                                  // margin:
                                  //     EdgeInsets.only(bottom: screenHeight * 0.005),
                                  child: Icon(
                                    Icons.done,
                                    size: screenWidth * 0.07,
                                    color: widget.editMode
                                        ? Colors.white
                                        : Colors.green,
                                  ),
                                )
                              : SizedBox(
                                  key: ValueKey<int>(1),
                                ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      child: RotationTransition(
                          turns: Tween<double>(begin: 0.0, end: 0.5)
                              .animate(_animationController),
                          child: Icon(Icons.expand_more,
                              color: widget.editMode
                                  ? expandableEditColor
                                  : expandableColor)),
                      onTap: () {
                        setState(() {
                          open = !open;
                          if (open) {
                            _animationController.forward();
                          } else {
                            _animationController.reverse();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                      onPressed: () async {
                        if (widget.editMode) {
                          
                          widget.unit.sessionTime = await showTimerPicker(context, widget.unit.sessionTime);
                          if (widget.unit.sessionTime == Duration.zero) {
                            widget.unit.sessionTime =
                                const Duration(minutes: 1);
                             showRedSnackbar(context,_localizations.sessionTimeCantBeZero);
                          }
                        }
                        setState(() {});
                      },
                      icon: Icon(Icons.av_timer,
                          size: screenWidth * 0.06,
                          color: widget.editMode
                              ? expandableEditColor
                              : expandableColor),
                      label: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: widget.editMode
                            ? EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                            : EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the border radius as needed
                        ),
                        child: Text(formatDuration(widget.unit.sessionTime),
                            style: TextStyle(
                                color: widget.editMode
                                    ? expandableEditColor
                                    : expandableColor,
                                fontSize: screenWidth * 0.04)),
                      )),
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
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: widget.editMode
                              ? EdgeInsets.all(1)
                              : EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the border radius as needed
                          ),
                          child: Checkbox(
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4),
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
                                    widget.unit.completed = newValue ?? false;
                                  });
                                }
                              }),
                        )
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
