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

    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_localizations.chooseFreeSchedule),
            
            // ElevatedButton.icon(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) =>
            //               CustomDaysView(), // Replace NewPage with the page you want to navigate to
            //         ),
            //       );
            //     },
            //     icon: Icon(Icons.calendar_month_outlined),
            //     label: Text(_localizations.viewCustomDays)),
            Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.65,
                child: HourPickerForm()),
            
          ],
        );
  }
}
