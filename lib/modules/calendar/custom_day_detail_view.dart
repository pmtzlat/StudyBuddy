import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';
import 'package:study_buddy/common_widgets/hour_picker_form.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class CustomDayDetailView extends StatefulWidget {
  final Day customDay;
  const CustomDayDetailView({super.key, required this.customDay});

  @override
  State<CustomDayDetailView> createState() => _CustomDayDetailViewState();
}

class _CustomDayDetailViewState extends State<CustomDayDetailView> {
  final dateFormKey = GlobalKey<FormBuilderState>();
  final _controller = instanceManager.calendarController;
  final restraintFormKey = GlobalKey<FormBuilderState>();

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
                      key: restraintFormKey,
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
                          var res = await _controller.addGap(
                              restraintFormKey,
                              weekday,
                              widget.customDay.times,
                              'edit custom day');

                          if (res == -1) {
                            showRedSnackbar(
                                context, _localizations.errorAddingGap);
                          } else if (res == 0) {
                            showRedSnackbar(
                                context, _localizations.wrongInputGap);
                          }
                          res = await _controller.updateCustomDayTimes(widget.customDay);
                          if (res == -1) {
                            showRedSnackbar(
                                context, _localizations.errorAddingGap);
                          } else if (res == 0) {
                            showRedSnackbar(
                                context, _localizations.wrongInputGap);
                          }
                          _controller.getTimeSlotsForCustomDay(widget.customDay);

                          logger.i(widget.customDay.times);

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
            height: screenHeight * 0.6,
            width: screenWidth * 0.85,
            child: Column(
              children: [
               Text(DateFormat("d MMMM, y").format(widget.customDay.date)),
                Center(
                  child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        
                          showPopUp(widget.customDay.weekday);
                        
                      }),
                ),
                Container(
                  child: Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: widget.customDay.times.length,
                        itemBuilder: (context, index) {
                          final timeSlot = widget.customDay.times[index];

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
                                          widget.customDay.times
                                              .removeAt(index);
                                          final res =
                                              await _controller.updateCustomDayTimes(widget.customDay);
                                          if (res == -1) {
                                            showRedSnackbar(
                                                context,
                                                _localizations
                                                    .errorAddingGap);
                                          } else if (res == 0) {
                                            showRedSnackbar(
                                                context,
                                                _localizations
                                                    .wrongInputGap);
                                          }
                                          _controller.getTimeSlotsForCustomDay(
                                              widget.customDay);

                                          setState(() {});
                                        },
                                        icon: Icon(Icons.delete))
                                  ],
                                )),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
