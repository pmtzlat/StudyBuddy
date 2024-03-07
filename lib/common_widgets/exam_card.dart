import 'package:flutter/material.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      required this.exam,
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
    String currentLocale = Localizations.localeOf(context).languageCode;

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
                  SizedBox(
                    width: screenWidth * 0.1,
                  ),
                  AnimatedContainer(
                    curve: Curves.decelerate,
                    duration: Duration(milliseconds: 300),
                    width: !widget.prioritizing
                        ? (currentLocale == 'es' ? screenWidth * 0.38 : screenWidth * 0.28)
                        : (currentLocale == 'es' ? screenWidth * 0.5 : screenWidth * 0.4),

                    // color: Colors.yellow,
                    child: SingleChildScrollView(
                      key: Key('1'),
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          Container(
                            width: (currentLocale == 'es' ? screenWidth * 0.36 : screenWidth * 0.26),
                            child: Text(
                                '${formatDateTime(context, widget.exam.examDate)}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.035)),
                          ),
                          SizedBox(width: screenWidth*0.02),
                          ReorderableDragStartListener(
                              // widget 2
                              index: widget.index,
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                child: Icon(Icons.drag_handle_rounded,
                                    color: Colors.black),
                              ))
                        ],
                      ),
                    ),
                  )
                ],
              ))),
    );
  }
}
