import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/common_widgets/hour_picker_form.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class AddCustomDayView extends StatefulWidget {
  final Function refreshParent;
  const AddCustomDayView({super.key, required Function this.refreshParent});

  @override
  State<AddCustomDayView> createState() => _AddCustomDayViewState();
}

class _AddCustomDayViewState extends State<AddCustomDayView> {
  final dateFormKey = GlobalKey<FormBuilderState>();
  final _controller = instanceManager.calendarController;
  final gapFormKey = GlobalKey<FormBuilderState>();
  List<TimeSlot> customSchedule = [];

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    void showPopUp(int weekday) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.5),

        transitionDuration: Duration(milliseconds: 200),

        // Create the dialog's content
        pageBuilder: (context, animation, secondaryAnimation) {
          return Center(
            child: Card(
              color: Colors.orange,
              child: Container(
                padding: EdgeInsets.all(10),
                height: screenHeight * 0.28,
                width: screenWidth * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    Text(_localizations.addGap),
                    FormBuilder(
                      key: gapFormKey,
                      child: Row(children: [
                        Expanded(
                          child: FormBuilderDateTimePicker(
                            name: 'startTime',
                            inputType: InputType.time,
                            format: DateFormat("HH:mm"),
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                        Text(' - '),
                        Expanded(
                          child: FormBuilderDateTimePicker(
                            name: 'endTime',
                            inputType: InputType.time,
                            format: DateFormat("HH:mm"),
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                      ]),
                    ),
                    IconButton(
                        onPressed: () async {
                          final res = await _controller.addGap(
                              gapFormKey, weekday, customSchedule, 'add custom day');
                          if (res == -1) {
                            showRedSnackbar(
                                context, _localizations.errorAddingGap);
                          } else if (res == 0) {
                            showRedSnackbar(
                                context, _localizations.wrongInputGap);
                          }
                          logger.i(customSchedule);
                          setState(() {});
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.check))
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Center(
      child: Card(
        color: Colors.yellow,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: screenHeight*0.6,
            width: screenWidth * 0.85,
            child: Column(
              children: [
                Text(_localizations.addCustomDay),
                FormBuilder(
                    key: dateFormKey,
                    child: FormBuilderDateTimePicker(
                      name: 'customDate',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputType: InputType.date,
                      enabled: true,
                      decoration:
                          InputDecoration(labelText: _localizations.day),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    )),
                SizedBox(
                  height: screenHeight * 0.025,
                ),
                Center(
                  child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (dateFormKey.currentState!.validate()) {
                          dateFormKey.currentState!.save();
                          showPopUp(dateFormKey.currentState!
                              .fields['customDate']!.value.weekday, 
                              );
                        }
                      }),
                ),
                Container(
                  child: Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: customSchedule.length,
                        itemBuilder: (context, index) {
                          final timeSlot = customSchedule[index];

                          return Card(
                            color: Colors.orange,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${timeSlot.timeOfDayToString(timeSlot.startTime)} - ${timeSlot.timeOfDayToString(timeSlot.endTime)}'),
                                    IconButton(
                                        onPressed: () async {
                                          customSchedule.removeAt(index);

                                          setState(() {});
                                        },
                                        icon: Icon(Icons.delete))
                                  ],
                                )),
                          );
                        }),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: () async{
                      final res = await _controller.addCustomDay(dateFormKey, customSchedule);
                      if (res == -1) {
                            showRedSnackbar(
                                context, _localizations.errorAddingCustomDay);
                          } else if (res == 0) {
                            showRedSnackbar(
                                context, _localizations.wrongInputGap);
                          }
                          else if (res == 2) {
                            showRedSnackbar(
                                context, _localizations.customDayDuplicate);
                          }
                          else if (res == 3) {
                            showRedSnackbar(
                                context, _localizations.customDayEmpty);
                          }
                      Navigator.of(context).pop();
                      widget.refreshParent();


                    }, icon: Icon(Icons.check))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
