import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/common_widgets/loading_screen.dart';
import 'package:study_buddy/common_widgets/unit_card.dart';
import 'package:study_buddy/services/logging_service.dart';
import '../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/exam_model.dart';

class ExamDetailView extends StatefulWidget {
  ExamModel exam;
  Function refreshParent;
  ExamDetailView(
      {super.key,
      required ExamModel this.exam,
      required this.refreshParent});

  @override
  State<ExamDetailView> createState() => _ExamDetailViewState();
}

class _ExamDetailViewState extends State<ExamDetailView> {
  final _controller = instanceManager.examController;
  bool editMode = false;
  final examFormKey = GlobalKey<FormBuilderState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    loadUnits();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    

    return Center(
        child: SingleChildScrollView(
          child: Card(
            color: Colors.lightBlue,
            child: Container(
              height: screenHeight * 0.8,
              width: screenWidth * 0.95,
              padding: EdgeInsets.all(30),
              child: editMode == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exam.name,
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Weight: ${widget.exam.weight}'),
                        Text(
                            'Session time: ${formatDuration(widget.exam.sessionTime)}'),
                        Text('Exam Date: ${widget.exam.examDate}'),
                        Text('Order Matters: ${widget.exam.orderMatters}'),
                        Text('Revisions: ${widget.exam.revisions.length}'),
                        
                        IconButton(
                            onPressed: () {
                              setState(() {
                                editMode = true;
                              });
                            },
                            icon: Icon(Icons.edit)),
                        Container(
                          height: screenHeight *0.05,
                          padding: EdgeInsets.all(3),
                          child: loading == false ? ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                await widget.exam.addUnit();
                                setState(() {
                                  instanceManager.sessionStorage.needsRecalculation = true;
                                  loading = false;
                                });
                              },
                              child: Text(_localizations.addUnit))
                              : CircularProgressIndicator(),
                        ),
                        widget.exam.units == null
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
                              key: examFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormBuilderTextField(
                                    name: 'examName',
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                        labelText: _localizations.unitName),
                                    style: TextStyle(color: Colors.black),
                                    initialValue: widget.exam.name,
                                    validator:
                                        FormBuilderValidators.compose([]),
                                  ),
                                  FormBuilderSlider(
                                    name: 'weightSlider',
                                    initialValue: widget.exam.weight,
                                    min: 0.0,
                                    max: 2.0,
                                    divisions: 20,
                                    decoration: InputDecoration(
                                        labelText: _localizations.examWeight),
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
                                    initialValue:
                                        '${durationToDouble(widget.exam.sessionTime)}',
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
                                    initialValue: widget.exam.examDate,
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
                                      initialValue: widget.exam.orderMatters,
                                      title: Text(_localizations.orderMatters)),
                                  FormBuilderTextField(
                                    name: 'revisions',
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    initialValue:
                                        widget.exam.revisions.length.toString(),
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
                          loading == false ? IconButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                int? res = await _controller.handleEditExam(
                                    examFormKey, widget.exam);

                                if (res == -1) {
                                  showError(_localizations.errorEditingExam);
                                }
                                if (res == -2) {
                                  showError(_localizations.wrongDates);
                                } else {
                                  
                                  widget.exam = await instanceManager
                                      .firebaseCrudService
                                      .getExam(widget.exam.id);
                                  
                                  await widget.exam.getUnits();
                                  await widget.exam.getRevisions();
                                  widget.refreshParent();

                                  setState(() {
                                    editMode = false;
                                    loading = false;
                                  });
                                }
                              },
                              icon: Icon(Icons.check))
                              : CircularProgressIndicator(),
                        ],
                      )),
                    ),
            ),
          ),
        ),
      
    );
  }

  void loadUnits() async {
    await widget.exam.getUnits();
    await widget.exam.getRevisions();
    setState(() {});
  }


  Expanded getUnitList() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.exam.units!.length,
          itemBuilder: (context, index) {
            final unit = widget.exam.units![index];
            
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
                  widget.exam.units!.removeAt(index);
                  await widget.exam.deleteUnit(unit: unit);
                  setState(() {
                    instanceManager.sessionStorage.needsRecalculation = true;
                  });
                },
                child: UnitCard(
                  unit: unit,
                  exam: widget.exam,
                  notifyParent: loadUnits,
                  showError: showError,
                ),
              );
            
          },
        ),
      ),
    );
  }

 
  

  void showError(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Color.fromARGB(255, 221, 15, 0),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}