import 'package:flutter/cupertino.dart';

class CalendarController{

  void moveToStageTwo({required PageController controller}){
    controller.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void moveToStageOne({required PageController controller}){
    controller.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

}