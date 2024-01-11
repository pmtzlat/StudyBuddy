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
import 'package:study_buddy/modules/loader/loader.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
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
  //List<UnitModel> unitsToAdd = instanceManager.sessionStorage.examToAdd.units;

  void updateExamPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Color.fromARGB(255, 158, 158, 158);
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    final PageController _pageController = PageController(
        initialPage: instanceManager.sessionStorage.activeOrAllExams);

    return instanceManager.scaffold.getScaffold(
        context: context,
        activeIndex: 0,
        body: Column(
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
                TextButton.icon(
                  
                    onPressed: () {
                      showAddExamSheet(context);
                    },
                    label: Text(_localizations.addExam, style: TextStyle(color: buttonColor)),
                    icon: Icon(Icons.add_rounded, color: buttonColor)),
                
                AnimatedOpacity(
                  opacity: instanceManager.sessionStorage.activeOrAllExams == 0 ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: TextButton.icon(
                    
                      onPressed: () {
                       logger.i('Prioritize clicked!');
                       if(instanceManager.sessionStorage.activeOrAllExams == 0){
                        //TODO after gym
                       }
                      },
                      label: Text(_localizations.prioritizeButton, style: TextStyle(color: buttonColor)),
                      icon: Icon(Icons.format_list_numbered, color: buttonColor)),
                ) ,
              ],
            ),
            instanceManager.sessionStorage.activeExams == null
                ? loadingScreen()
                : Flexible(
                    child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        controller: _pageController,
                        children: [
                          getExamList(
                              instanceManager.sessionStorage.activeExams),
                          getExamList(
                              instanceManager.sessionStorage.pastExams)
                        ]),
                  ),
            Center(
              child: Container(
                  margin: EdgeInsets.only(
                      top: screenHeight * 0.02, bottom: screenHeight * 0.03),
                  child: SlidingSwitch(
                    onTap: () {},
                    onDoubleTap: () {},
                    onSwipe: () {},
                    value: false,
                    width: screenWidth * 0.6,
                    height: screenHeight * 0.04,
                    textOff: _localizations.activeExams,
                    textOn: _localizations.allExams,
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
                        instanceManager.sessionStorage.activeOrAllExams = index;
                      });
                      
                      _pageController.animateToPage(index!,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.decelerate);
                    },
                  )),
            ),
          ],
        ));
  }

  void loadExams() async {
    await _controller.getAllExams();
    setState(() {});
  }

  Widget getExamList(List<ExamModel> examList) {
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
                      instanceManager.sessionStorage.activeExams
                          .remove(exam);
                      instanceManager.sessionStorage.savedExams
                          .remove(exam);
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
          instanceManager.sessionStorage.activeExams
              .contains(instanceManager.sessionStorage.examToAdd)) {
        instanceManager.sessionStorage.activeExams
            .remove(instanceManager.sessionStorage.examToAdd);
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

  void refresh() {
    logger.i('updating...');
    setState(() {});
  }

  void setLoading(bool state) {
    logger.i('Changing state of laoding to $state');
    setState(() {
      loading = state;
    });
  }
}
