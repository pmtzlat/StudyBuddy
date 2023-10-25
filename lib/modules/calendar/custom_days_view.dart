import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/common_widgets/error_messages.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/modules/calendar/add_custom_day_view.dart';
import 'package:study_buddy/modules/calendar/custom_day_detail_view.dart';

class CustomDaysView extends StatefulWidget {
  const CustomDaysView({super.key});

  @override
  State<CustomDaysView> createState() => _CustomDaysViewState();
}

class _CustomDaysViewState extends State<CustomDaysView> {
  final _controller = instanceManager.calendarController;
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 2,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Title(
                color: Colors.black,
                child: Text(_localizations.customDays),
              ),
              Center(
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AddCustomDayView(refreshParent: refresh);
                        });
                  },
                ),
              ),
              Expanded(
                  child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: instanceManager.sessionStorage.activeCustomDays.length,
                itemBuilder: (context, index) {
                  var day = instanceManager.sessionStorage.activeCustomDays[index];
                  return GestureDetector(
                    onTap: () async{
                      await _controller.getTimeSlotsForDay(day);


                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return CustomDayDetailView(customDay: day,);
                        });

                    },
                    child: Card(
                      color: Colors.orange,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat("d MMMM, y").format(day.date)),
                              IconButton(
                                  onPressed: () async {
                                    instanceManager.sessionStorage.activeCustomDays
                                        .removeAt(index);
                                    final res = await _controller.deleteCustomDay(day.id);
                                    if (res == -1) {
                                      showRedSnackbar(context,
                                          _localizations.errorDeletingCustomDay);
                                    }
                                    
                  
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.delete))
                            ],
                          )),
                    ),
                  );
                },
              ))
            ],
          ),
        ));
  }

  void refresh() async {
    await _controller.getCustomDays();
    setState(() {});
  }
}
