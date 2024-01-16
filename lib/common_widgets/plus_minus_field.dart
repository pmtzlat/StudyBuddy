import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class plusMinusField extends StatelessWidget {
  plusMinusField(
      {super.key,
      required this.duration,
      required this.toggle,
      required this.addNumberToParent,
      required this.number,
      this.min = 0,
      this.max = 9});

  final Duration duration;
  bool toggle;
  int number;
  final Function addNumberToParent;
  int min;
  int max;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (number > min && toggle) addNumberToParent(-1);
          },
          child: AnimatedSwitcher(
            duration: duration,
            child: Icon(Icons.remove,
                color: toggle ? Colors.white : Colors.transparent),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Text(number.toString(),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: screenWidth * 0.05)),
        SizedBox(width: screenWidth * 0.03),
        GestureDetector(
          onTap: () {
            if (number < max && toggle) addNumberToParent(1);
          },
          child: AnimatedSwitcher(
            duration: duration,
            child: Icon(Icons.add,
                color: toggle ? Colors.white : Colors.transparent),
          ),
        )
      ],
    );
  }
}
