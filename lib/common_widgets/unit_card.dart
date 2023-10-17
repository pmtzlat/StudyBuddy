import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/courses/course_detail_view.dart';

class UnitCard extends StatefulWidget {
  final UnitModel unit;
  final CourseModel course;
  final Function notifyParent;

  UnitCard(
      {required this.unit,
      required this.course,
      required Function this.notifyParent});

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard> {
  final _controller = instanceManager.courseController;
  var editMode = false;
  final unitFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: editMode == false
                  ? [
                      Text('Unit ${widget.unit.order}: ${widget.unit.name}'),
                      Text('${widget.unit.id}'),
                      Text('${widget.unit.hours / 3600}'),
                      SizedBox(width: 8.0),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              editMode = true;
                            });
                          },
                          icon: Icon(Icons.edit))
                    ]
                  : [
                      FormBuilder(
                          key: unitFormKey,
                          child: Container(
                            width: screenWidth * 0.6,
                            child: Column(
                              children: [
                                FormBuilderTextField(
                                  name: 'unitName',
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                      labelText: _localizations.unitName),
                                  style: TextStyle(color: Colors.black),
                                  initialValue: widget.unit.name,
                                  validator: FormBuilderValidators.compose([]),
                                ),
                                FormBuilderTextField(
                                  name: 'hours',
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  initialValue: (widget.unit.hours / 3600).toInt().toString(),
                                  decoration: InputDecoration(
                                    labelText: _localizations.unitHours,
                                  ),
                                  style: TextStyle(color: Colors.black),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.numeric()
                                  ]),
                                ),
                              ],
                            ),
                          )),
                      IconButton(
                          onPressed: () async {
                            await _controller.handleEditUnit(
                                unitFormKey, widget.course, widget.unit);
                            await widget.course.getUnits();
                            widget.notifyParent();

                            setState(() {
                              editMode = false;
                            });
                          },
                          icon: Icon(Icons.check))
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
