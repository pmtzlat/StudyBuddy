import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/hour_picker_form.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/modules/calendar/custom_days_view.dart';

class RestrictionsDetailView extends StatefulWidget {
  const RestrictionsDetailView({super.key});

  @override
  State<RestrictionsDetailView> createState() => _RestrictionsDetailViewState();
}

class _RestrictionsDetailViewState extends State<RestrictionsDetailView> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 2,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(_localizations.chooseFreeSchedule),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CustomDaysView(), // Replace NewPage with the page you want to navigate to
                            ),
                          );
                        },
                        icon: Icon(Icons.calendar_month_outlined),
                        label: Text(_localizations.viewCustomDays)),
                    Container(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.6,
                        child: HourPickerForm()),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
