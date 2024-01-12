import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class SessionStorage {
  List<ExamModel> savedExams =[];
  List<ExamModel> pastExams = [];
  List<ExamModel> activeExams = [];
  

  //NEEDS: a varibale that saves wether the calendar needs recalculating
  // after a new exam is added!!

  List<List<TimeSlot>> weeklyGaps = [];
  List<Day> customDays = [];
  List<Day> activeCustomDays = [];

  int activeOrAllExams = 0;

  Day loadedCalendarDay = Day(
      date: DateTime.now(), weekday: DateTime.now().weekday, id: 'Placeholder');

  DateTime currentDay = stripTime(DateTime.now());
  bool dayLoaded = false;

  var savedWeekday = 0;
  int? schedulePresent;
  List<String> leftoverExams = <String>[];

  ExamModel examToAdd = ExamModel(examDate: DateTime.now(), name: '');
  List<double> examWeightArray = [];

  bool needsRecalculation = false;
  Map<String,List<TimeSlot>> incompletePreviousDays = {};
}
