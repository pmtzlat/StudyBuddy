import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/hour_picker_form.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/modules/calendar/custom_days_view.dart';

class GeneralAvailabilityView extends StatefulWidget {
  PageController pageController;
  GeneralAvailabilityView({super.key, required this.pageController});

  @override
  State<GeneralAvailabilityView> createState() => _GeneralAvailabilityViewState();
}

class _GeneralAvailabilityViewState extends State<GeneralAvailabilityView> {

 


  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    Widget generalGaps =
    Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(_localizations.chooseFreeSchedule),
                    
                    
                    Container(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.6,
                        child: HourPickerForm()),
                  ],
                ),
              ],
            ),
            TextButton(onPressed: (){
              widget.pageController.nextPage(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.decelerate,
                        );
              
            }, child: Text(_localizations.availabilityForSpecificDays, style: TextStyle(color: Colors.blue)))
            
          ],
        );

    Widget customDays = CustomDaysView(pageController: widget.pageController,);

    List<Widget> pages = [generalGaps, customDays];

    return PageView(
      physics: const  NeverScrollableScrollPhysics(),
      controller: widget.pageController,
      scrollDirection: Axis.vertical,
      children: pages,
    );
  }
}
