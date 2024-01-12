import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/modules/exams/exam_detail_view.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/exam_model.dart';

class ExamCard extends StatefulWidget {
  final exam;
  final Function parentRefresh;
  int index;
  bool prioritizing;
  ExamCard(
      {super.key,
      required ExamModel this.exam,
      required this.parentRefresh,
      required this.index,
      required this.prioritizing});

  @override
  State<ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  double cardRadius = 20.0;
  @override
  Widget build(BuildContext context) {
    final cardColor = stringToColor(widget.exam.color);
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
            return ExamDetailView(
                exam: widget.exam, refreshParent: widget.parentRefresh);
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
                  Text('${widget.exam.name} - ${widget.exam.weight}',
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.06)),
                 
                  AnimatedContainer(
                    curve: Curves.decelerate,
                    duration: Duration(milliseconds: 300),
                    width: !widget.prioritizing
                        ? screenWidth * 0.23
                        : screenWidth * 0.35,

                   // color: Colors.yellow,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth*0.23,
                            child: Row(
                              // widget 1
                              children: [
                                Text('${formatDateTime(widget.exam.examDate)}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.035)),
                                SizedBox(
                                  width: screenWidth * 0.02,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: screenWidth*0.12,
                            child: ReorderableDragStartListener(
                                // widget 2
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Icon(Icons.drag_handle_rounded,
                                      color: Colors.black),
                                ),
                                index: widget.index),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ))),
    );
  }
}