import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

class SessionStorage {
  List<ExamModel> savedExams = [];
  List<ExamModel> pastExams = [];
  List<ExamModel> activeExams = [];

  //NEEDS: a varibale that saves wether the calendar needs recalculating
  // after a new exam is added!!

  List<List<TimeSlotModel>> weeklyGaps = [];
  List<DayModel> customDays = [];
  List<DayModel> activeCustomDays = [];

  int activeOrAllExams = 0;

  DayModel loadedCalendarDay = 
    DayModel(weekday: DateTime.now().weekday, date: DateTime.now(), id: 'Placeholder');

  DateTime currentDate = stripTime(DateTime.now());
  //bool dayLoaded = false;

  DateTime? prevDayDate = stripTime(DateTime.now());

  DayModel prevDay = DayModel(weekday: DateTime.now().weekday, date: DateTime.now(), id: 'Placeholder');

  var savedWeekday = 0;
  int? schedulePresent;
  List<String> leftoverExams = <String>[];

  bool initialDayLoad = false;
  bool initialExamsLoad = false;
  bool initialGapsLoad = false;
  bool initialCustomDaysLoad = false;

  ExamModel examToAdd = ExamModel(examDate: DateTime.now(), name: '');
  List<double> examWeightArray = [];

  bool needsRecalculation = false;
  Map<String, List<TimeSlotModel>> incompletePreviousDays = {};
}
