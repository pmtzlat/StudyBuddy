import 'dart:ui';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:study_buddy/common_widgets/loading_screen.dart';
import 'package:study_buddy/instance_manager.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/exams/add_exam_button.dart';
import 'package:study_buddy/modules/exams/add_exam_pages.dart';
import 'package:study_buddy/modules/exams/controllers/exams_controller.dart';
import 'package:study_buddy/modules/exams/exam_detail_view.dart';
import 'package:study_buddy/modules/loader/loader.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/utils/general_utils.dart';
import 'package:study_buddy/utils/validators.dart';
import '../../common_widgets/exam_card.dart';

class ExamsView extends StatefulWidget {
  const ExamsView({super.key});

  @override
  State<ExamsView> createState() => _ExamsViewState();
}

class _ExamsViewState extends State<ExamsView> {
  final _controller = instanceManager.examController;
  bool loading = false;
  bool prioritizing = false;
  List<ExamModel> activeExams = instanceManager.sessionStorage.activeExams;
  List<ExamModel> pastExams = instanceManager.sessionStorage.pastExams;
  List<ExamModel> reorderExams = [];
  Duration prioritizeSwitchTime = Duration(milliseconds: 300);
  ExamModel selectedExam =
      ExamModel(name: 'placeholder', examDate: DateTime.now());
  final PageController examPageController = PageController();

  void updateExamPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Color.fromARGB(255, 158, 158, 158);
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    final PageController timePageController = PageController(
        initialPage: instanceManager.sessionStorage.activeOrAllExams);

    Widget page1 = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(screenWidth * 0.05),
          child: Text(
            _localizations.examsTitle,
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSwitcher(
              duration: prioritizeSwitchTime,
              child: !prioritizing
                  ? Container(
                      // add course
                      key: ValueKey<int>(0),
                      width: screenWidth * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                              key: ValueKey<int>(0),
                              onPressed: () {
                                showAddExamSheet(context);
                              },
                              label: Text(_localizations.addExam,
                                  style: TextStyle(color: buttonColor)),
                              icon:
                                  Icon(Icons.add_rounded, color: buttonColor)),
                        ],
                      ),
                    )
                  : Container(
                      // cancel prioritize
                      key: ValueKey<int>(1),
                      width: screenWidth * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                              key: ValueKey<int>(1),
                              onPressed: () {
                                logger.i('Cancel clicked!');
                                setState(() {
                                  prioritizing = false;
                                });
                                loadExams();
                              },
                              label: Text(_localizations.cancel,
                                  style: TextStyle(color: Colors.redAccent)),
                              icon: Icon(Icons.close_rounded,
                                  color: Colors.redAccent)),
                        ],
                      ),
                    ),
            ),
            AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: instanceManager.sessionStorage.activeOrAllExams == 0
                    ? AnimatedSwitcher(
                        key: ValueKey<int>(0),
                        duration: prioritizeSwitchTime,
                        child: !prioritizing
                            ? Container(
                                //Prioritize
                                key: ValueKey<int>(0),
                                width: screenWidth * 0.4,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                        key: ValueKey<int>(0),
                                        onPressed: () {
                                          reorderExams = List.from(activeExams);

                                          logger.i('Prioritize clicked!');

                                          setState(() {
                                            prioritizing = true;
                                          });
                                        },
                                        label: Text(
                                            _localizations.prioritizeButton,
                                            style:
                                                TextStyle(color: buttonColor)),
                                        icon: Icon(Icons.format_list_numbered,
                                            color: buttonColor))
                                  ],
                                ),
                              )
                            : Container(
                                //finishPrioritize
                                key: ValueKey<int>(1),
                                width: screenWidth * 0.4,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                        key: ValueKey<int>(1),
                                        onPressed: () async {
                                          logger.i('Confirm clicked!');
                                          _controller
                                              .applyWeights(reorderExams);
                                          reorderExams.sort(
                                              (ExamModel a, ExamModel b) =>
                                                  b.weight.compareTo(a.weight));
                                          logger.i(
                                              'reorderExams after confirm clicked: ${getExamsListString(reorderExams)}');

                                          setState(() {
                                            activeExams = reorderExams;
                                            prioritizing = false;
                                          });
                                          switch (await _controller
                                              .replaceExams(activeExams)) {
                                            case (-1):
                                              var snackbar = SnackBar(
                                                content: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .errorPrioritizing),
                                                backgroundColor:
                                                    Colors.redAccent,
                                              );

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbar);

                                            default:
                                          }

                                          activeExams = instanceManager
                                              .sessionStorage.activeExams;
                                          reorderExams = <ExamModel>[];

                                          loadExams();
                                        },
                                        label: Text(_localizations.confirm,
                                            style: TextStyle(
                                                color: Colors.greenAccent)),
                                        icon: Icon(Icons.done_rounded,
                                            color: Colors.greenAccent)),
                                  ],
                                ),
                              ),
                      )
                    : Text('fasdf',
                        style: TextStyle(color: Colors.transparent))), //hotfix
          ],
        ),
        activeExams == null
            ? loadingScreen()
            : Flexible(
                child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    controller: timePageController,
                    children: [
                      getReorderableActiveExamsList(
                          !prioritizing ? activeExams : reorderExams),
                      getPastExamsList()
                    ]),
              ),
        Center(
          child: Container(
              margin: EdgeInsets.only(
                  top: screenHeight * 0.02, bottom: screenHeight * 0.03),
              child: AnimatedSwitcher(
                duration: prioritizeSwitchTime,
                child: !prioritizing
                    ? SlidingSwitch(
                        onTap: () {},
                        onDoubleTap: () {},
                        onSwipe: () {},
                        value: false,
                        width: screenWidth * 0.6,
                        height: screenHeight * 0.04,
                        textOff: _localizations.futureExams,
                        textOn: _localizations.pastExams,
                        colorOn: Color.fromARGB(255, 59, 59, 59),
                        colorOff: Color.fromARGB(255, 59, 59, 59),
                        contentSize: screenWidth * 0.035,
                        onChanged: (bool value) {
                          int index;
                          if (value == false) {
                            index = 0;
                          } else {
                            index = 1;
                          }
                          print('switched to: $index');
                          setState(() {
                            instanceManager.sessionStorage.activeOrAllExams =
                                index;
                          });

                          timePageController.animateToPage(index!,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.decelerate);
                        },
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            // or Expanded
                            child: Text(
                              _localizations.reorderText,
                              textAlign: TextAlign
                                  .center, // Optional: Center the text within the available space
                            ),
                          ),
                        ],
                      ),
              )),
        ),
      ],
    );

    Widget page2 =
        ExamDetailView(exam: selectedExam, refreshParent: refresh, pageController: examPageController,); //TODO:

    List<Widget> pages = [page1, page2];

    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 0,
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: examPageController,
          children: pages,
        ));
  }

  void giveDetails(ExamModel exam) {
    setState(() {
      selectedExam = exam;
    });
  }

  void loadExams() async {
    await _controller.getAllExams();
    setState(() {
      activeExams = instanceManager.sessionStorage.activeExams;
      pastExams = instanceManager.sessionStorage.pastExams;
    });
    //logger.i('loadExams: ${getActiveExamsString(null)}');
  }

  Widget getReorderableActiveExamsList(List<ExamModel> examsList) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    ReorderableListView reorderableList() {
      Widget proxyDecorator(
          Widget child, int index, Animation<double> animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue =
                Curves.easeInOut.transform(animation.value);
            final double elevation = lerpDouble(0, 6, animValue)!;
            return Material(
              elevation: elevation,
              color: Colors.transparent,
              shadowColor: Colors.black.withOpacity(0.5),
              child: child,
            );
          },
          child: child,
        );
      }

      return ReorderableListView.builder(
          padding: EdgeInsets.only(bottom: screenHeight * 0.065),
          proxyDecorator: proxyDecorator,
          itemBuilder: (context, index) {
            ExamModel exam = examsList[index];
            return Dismissible(
              key: Key(exam.id),
              direction: DismissDirection.endToStart,
              background: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(_localizations.delete,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: screenWidth * 0.04)))
                  ],
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
              ),
              onDismissed: (direction) async {
                if (!prioritizing) {
                  setState(() {
                    activeExams.remove(exam);
                    instanceManager.sessionStorage.savedExams.remove(exam);
                  });

                  await _controller.deleteExam(
                    name: exam.name,
                    id: exam.id,
                    index: index,
                    context: context,
                  );
                  setState(() {});
                } else {
                  setState(() {
                    reorderExams.remove(exam);
                  });
                }
              },
              child: ExamCard(
                exam: examsList![index],
                parentRefresh: loadExams,
                index: index,
                prioritizing: prioritizing,
                pageController: examPageController,
                giveDetails: giveDetails,
              ),
            );

            // Container(
            //     key: Key('$index'),
            //     margin: EdgeInsets.symmetric(vertical: 8),
            //     child: Card(
            //         color: Color.fromARGB(255, 39, 39, 39),
            //         child: Container(
            //             padding: EdgeInsets.only(
            //                 left: screenWidth * 0.05,
            //                 top: screenWidth * 0.03,
            //                 bottom: screenWidth * 0.03),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text(exam.name,
            //                     style: TextStyle(
            //                         color: Colors.white,
            //                         fontSize: screenWidth * 0.06)),
            //                 SingleChildScrollView(
            //                   scrollDirection: Axis.horizontal,
            //                   physics: NeverScrollableScrollPhysics(),
            //                   child: Row(
            //                     children: [
            //                       AnimatedContainer(
            //                         curve: Curves.decelerate,
            //                         duration: prioritizeSwitchTime,
            //                         width:
            //                             prioritizing ? screenWidth * 0.05 : 0,
            //                         child: SizedBox(),
            //                       ),
            //                       Text('${formatDateTime(exam.examDate)}',
            //                           style: TextStyle(
            //                               color: Colors.white,
            //                               fontSize: screenWidth * 0.035)),
            //                       SizedBox(
            //                         width: screenWidth * 0.02,
            //                       ),
            //                       ReorderableDragStartListener(
            //                           child: Padding(
            //                             padding:
            //                                 EdgeInsets.all(screenWidth * 0.02),
            //                             child: Icon(Icons.drag_handle_rounded,
            //                                 color: Colors.black),
            //                           ),
            //                           index: index),
            //                     ],
            //                   ),
            //                 )
            //               ],
            //             ))));
          },
          itemCount: examsList.length,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final ExamModel item = examsList.removeAt(oldIndex);
              examsList.insert(newIndex, item);
            });
          });
    }

    return reorderableList();
  }

  Widget getPastExamsList() {
    List<ExamModel> examList = pastExams;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
              //padding: EdgeInsets.only(bottom: screenHeight * 0.03),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: examList!.length,
              itemBuilder: (context, index) {
                final exam = examList![index];
                return Dismissible(
                  key: Key(exam.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(_localizations.delete,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.04)))
                      ],
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                  ),
                  onDismissed: (direction) async {
                    setState(() {
                      activeExams.remove(exam);
                      instanceManager.sessionStorage.savedExams.remove(exam);
                    });

                    await _controller.deleteExam(
                      name: exam.name,
                      id: exam.id,
                      index: index,
                      context: context,
                    );
                  },
                  child: ExamCard(
                    exam: examList![index],
                    parentRefresh: loadExams,
                    prioritizing: false,
                    index: index,
                    pageController: examPageController,
                    giveDetails: giveDetails,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: screenHeight * 0.01,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.0), Colors.white],
                  begin: FractionalOffset(0, 0),
                  end: FractionalOffset(0, 1),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ),
        ),
      ],
    );
  }

  void showAddExamSheet(BuildContext context) {
    //final examCreationFormKey = GlobalKey<FormBuilderState>();
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    final PageController _pageController = PageController(); // Add a controller
    //Duration sessionTime = Duration(hours:1);

    Page3 page3 = Page3(
      key: GlobalKey<Page3State>(),
      lockClose: setLoading,
      refreshParent: refresh,
    );

    void updatePage3() {
      //calls setstate in page2 to ensure it gets update correctly

      page3.updateChild();
    }

    Page2 page2 = Page2(
      key: GlobalKey<Page2State>(),
      lockClose: setLoading,
      updatePage3: updatePage3,
      pageController: _pageController,
      refreshParent: refresh,
    );

    @override
    void didChangeDependencies() {
      //to update page2 correctly
      super.didChangeDependencies();
      page2 = context.findAncestorWidgetOfExactType<Page2>()!;
      page3 = context.findAncestorWidgetOfExactType<Page3>()!;
    }

    void updatePage2() {
      //calls setstate in page2 to ensure it gets update correctly
      page2.updateChild();
    }

    late List<Widget> pages;

    void removePage(int page) {
      pages.removeAt(page);
    }

    Page1 page1 = Page1(
        refresh: refresh,
        lockClose: setLoading,
        updatePage2: updatePage2,
        updatePage3: updatePage3,
        removePage: removePage,
        pageController: _pageController);

    pages = [page1, page2, page3];

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      builder: (BuildContext context) {
        //logger.i(instanceManager.sessionStorage.examToAdd.units);
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Container(
              height: screenHeight * 0.9,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.01, left: screenWidth * 0.01),
                        child: IconButton(
                            iconSize: screenWidth * 0.1,
                            onPressed: () {
                              closeModal(context);
                            },
                            icon: Icon(Icons.close_rounded)),
                      ),
                    ],
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05,
                          ),
                          child: Text(
                            _localizations.addExam,
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 34.0, // Text size
                            ),
                          ),
                        ),
                        //put the following container inside a pageview as
                        Container(
                          height: screenHeight * 0.82,
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: PageView.builder(
                              controller:
                                  _pageController, // Assign the controller
                              physics:
                                  NeverScrollableScrollPhysics(), // Make it non-scrollable
                              itemCount: pages.length,
                              itemBuilder: (BuildContext context, int index) {
                                return pages[index];
                              }),
                        )
                      ],
                    ),
                  ),
                ]),
              )),
        );
      },
    );
  }

  void closeModal(BuildContext context) {
    logger.i('Closing... - Loading state: $loading');
    if (loading != true) {
      if (instanceManager.sessionStorage.examToAdd != null &&
          activeExams.contains(instanceManager.sessionStorage.examToAdd)) {
        activeExams.remove(instanceManager.sessionStorage.examToAdd);
      }

      instanceManager.sessionStorage.examToAdd.units = <UnitModel>[];
      instanceManager.sessionStorage.examToAdd =
          ExamModel(examDate: DateTime.now(), name: '');
      updateExamPage();
      Navigator.pop(context);
    } else {
      logger.i('Can\'t close while its loading!');
    }
  }

  void refresh() async {
    //logger.i('updating...');
    loadExams();
    setState(() {});
  }

  void setLoading(bool state) {
    //logger.i('Changing state of laoding to $state');
    setState(() {
      loading = state;
    });
  }
}
