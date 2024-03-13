import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LeftOverCard extends StatelessWidget {
  final String text;
  LeftOverCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final List<String> separatedData = text.split('/').toList();
    String title = separatedData[0];
    String units = separatedData.sublist(1,separatedData.length-1).join(', ');
    units += separatedData[separatedData.length-1];
    final examList = instanceManager.sessionStorage.activeExams;
    ExamModel? matchingExam;
    try {
      matchingExam = examList.firstWhere((exam) => exam.name == title);
    } catch (e) {
      logger.w('Exam $title not found!');
      matchingExam = null;
    }

    final Color cardColor = matchingExam?.color ?? Colors.blue;

    final lighterColor = lighten(cardColor, .05);
    final darkerColor = darken(cardColor, .15);

    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
            width: screenWidth * 0.7,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  end: Alignment.bottomLeft,
                  begin: Alignment.topRight,
                  //stops: [ 0.1, 0.9],
                  colors: [increaseColorSaturation(cardColor, .2), darken(cardColor, 0.15)]),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth*0.05),
                ),
                SizedBox(height: 20,),
                Text(
                  units,
                  style:  TextStyle(color: Colors.white, fontSize: screenWidth*0.04),
                ),
              ],
            )));
  }
}
