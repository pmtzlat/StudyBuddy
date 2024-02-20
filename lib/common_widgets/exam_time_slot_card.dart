import 'package:flutter/material.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class ExamTimeSlotCard extends StatelessWidget {
  ExamModel exam;
  ExamTimeSlotCard({super.key, required this.exam});
 

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    TextStyle textStyle = TextStyle(
                                color: exam.color, fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold);
    return Card(
        elevation: 0,
        color: lighten(exam.color, 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
            height: screenHeight * 0.095,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Icon(Icons.text_snippet_rounded, color: exam.color, size: screenWidth*0.1,)),
                Text(
                            '${_localizations.exam} - ', 
                            overflow: TextOverflow.ellipsis,
                            style:  textStyle),
                Flexible(
                        child: Text(
                            '${exam.name}', 
                            overflow: TextOverflow.ellipsis,
                            style: textStyle),
                      ),
                
              ],
            ),));
  }
}
