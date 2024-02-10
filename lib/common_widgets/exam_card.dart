import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/modules/exams/exam_detail_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/utils/general_utils.dart';
import '../models/exam_model.dart';

class ExamCard extends StatefulWidget {
  ExamModel exam;
  final Function parentRefresh;
  int index;
  bool prioritizing;
  PageController pageController;
  Function giveDetails;
  ExamCard(
      {super.key,
      required ExamModel this.exam,
      required this.parentRefresh,
      required this.index,
      required this.prioritizing,
      required this.pageController,
      required this.giveDetails});

  @override
  State<ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  double cardRadius = 20.0;
  @override
  Widget build(BuildContext context) {
    final cardColor = widget.exam.color;
    final lighterColor = lighten(cardColor, .05);
    final darkerColor = darken(cardColor, .15);

    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        logger.i(widget.prioritizing);
        if (!widget.prioritizing) {
          widget.giveDetails(widget.exam);
          widget.pageController.animateToPage(1,
              duration: Duration(milliseconds: 300), curve: Curves.decelerate);
        }
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
                    //stops: [ 0.1, 0.9],
                    colors: [cardColor, darkerColor]),
              ),
              padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  top: screenWidth * 0.03,
                  bottom: screenWidth * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                        '${widget.exam.name}', // - ${widget.exam.weight}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white, fontSize: screenWidth * 0.06)),
                  ),
                  SizedBox(width: screenWidth*0.1,),
                  AnimatedContainer(
                    curve: Curves.decelerate,
                    duration: Duration(milliseconds: 300),
                    width: !widget.prioritizing
                        ? screenWidth * 0.35
                        : screenWidth * 0.45,

                    // color: Colors.yellow,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.313,
                            child: Row(
                              // widget 1
                              children: [
                                Text('${formatDateTime(context, widget.exam.examDate)}',
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
                            width: screenWidth * 0.12,
                            child: ReorderableDragStartListener(
                                // widget 2
                                index: widget.index,
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Icon(Icons.drag_handle_rounded,
                                      color: Colors.black),
                                )),
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
