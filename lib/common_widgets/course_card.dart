import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/modules/courses/course_detail_view.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/course_model.dart';

class CourseCard extends StatefulWidget {
  final course;
  final Function parentRefresh;
  const CourseCard(
      {super.key,
      required CourseModel this.course,
      required this.parentRefresh});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  double cardRadius = 20.0;
  @override
  Widget build(BuildContext context) {
    final cardColor = stringToColor(widget.course.color);
    final lighterColor = lighten(cardColor, .03);
    final darkerColor = darken(cardColor, .1);

    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.transparent,

          transitionDuration: Duration(milliseconds: 200),

          // Create the dialog's content
          pageBuilder: (context, animation, secondaryAnimation) {
            return CourseDetailView(
                course: widget.course, refreshParent: widget.parentRefresh);
          },
        );
      },
      child: Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    end: Alignment.bottomLeft,
                    begin: Alignment.topRight,
                    stops: [
                      0.2,
                      0.3,
                      0.9,
                    ],
                    colors: [
                      lighterColor,
                      cardColor,
                      darkerColor
                    ]),
              ),
              padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  top: screenWidth * 0.03,
                  bottom: screenWidth * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.course.name,
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.06)),
                ],
              ))),
    );
  }
}
