import 'package:flutter/cupertino.dart';
import 'package:study_buddy/main.dart';

class CalendarController{

  void moveToStageTwo(){
    instanceManager.sessionStorage.calendarBeginPage = 1;
  }

  void moveToStageThree(){
    instanceManager.sessionStorage.calendarBeginPage = 2;
  }

  

}