import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/modules/calendar/add_custom_day_view.dart';

class CustomDaysView extends StatefulWidget {
  const CustomDaysView({super.key});

  @override
  State<CustomDaysView> createState() => _CustomDaysViewState();
}

class _CustomDaysViewState extends State<CustomDaysView> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 2,
        body: Column(
          children: [
            Title(
              color: Colors.black,
              child: Text(_localizations.customDays),
            ),
            Center(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddCustomDayView(), // Replace NewPage with the page you want to navigate to
                    ),
                  );

              },
            ),
          ),
            Expanded(
                child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: instanceManager.sessionStorage.customDays.length,
              itemBuilder: (context, index) {
                var day = instanceManager.sessionStorage.customDays[index];
                return ListTile(
                    title: Text(DateFormat("d 'of' MMMM, y").format(day.date)));
              },
            ))
          ],
        ));
  }
}
