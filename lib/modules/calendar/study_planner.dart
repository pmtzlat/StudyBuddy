import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/scheduler_stack_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class StudyPlanner {
  final _firebaseCrud = instanceManager.firebaseCrudService;
  final uid = instanceManager.localStorage.getString('uid') ?? '';

  Future<int?> calculateSchedule() async {
    try {
      await _firebaseCrud.deleteSchedule();
      List<TimeSlot>? scheduleLimits = await _firebaseCrud.getScheduleLimits();
      if (scheduleLimits == null) {
        logger.e('No restraints found');
        return null;
      }

      List<Day> days = generateDays();

      List<SchedulerStack> stacks = await generateStacks();
      for (SchedulerStack stack in stacks) {
        stack.print();
      }
      await fillRestrictions(days);

      for (Day day in days) {
        day.print();
      }
      List<Day> result = [];
      while (days.length > 0 && stacks.length > 0) {
        Day furthestDay = days.removeAt(0);
        //fillDayWithSessions(furthestDay);

        result.add(furthestDay);
      }

      //save days to db

      return 1;
    } catch (e) {
      logger.e('Error recalculating schedule $e');
      
    }
  }

  /*void fillDayWithSessions(Day day){
    getAvailableTime(day);

  }*/

  Future<List<SchedulerStack>> generateStacks() async {
    try {
      List<SchedulerStack> result = [];
      for (CourseModel course in instanceManager.sessionStorage.activeCourses) {
        SchedulerStack stack = SchedulerStack(course: course);
        await stack.initializeUnitsWithRevision(
            course); // Initialize unitsWithRevision asynchronously
        result.add(stack); // Add the initialized object to the list
      }
      return result;
    } catch (e) {
      logger.e('Error generating stacks: $e');
      return [];
    }
  }

  Future<void> fillRestrictions(List<Day> days) async {
    try {
      final restrictions =
          await instanceManager.firebaseCrudService.getScheduleLimits();
      if (restrictions != null) {
        final weekdayRestrictions = separateTimesForWeekday(restrictions);
        for (Day day in days) {
          day.times = weekdayRestrictions[day.weekday];
        }
      }
    } catch (e) {
      logger.e('Error filling days with restrictions: $e');
    }
  }

  List<List<TimeSlot>> separateTimesForWeekday(List<TimeSlot> restrictions) {
    List<List<TimeSlot>> resultMatrix = [[], [], [], [], [], [], []];
    for (TimeSlot slot in restrictions) {
      resultMatrix[slot.weekday].add(slot);
    }
    return resultMatrix;
  }

  List<Day> generateDays() {
    try {
      DateTime loopDate = getLatestExam().subtract(Duration(days: 1));
      List<Day> result = [];
      while (loopDate.isAfter(DateTime.now()) ||
          loopDate.isAtSameMomentAs(DateTime.now())) {
        result.add(Day(weekday: loopDate.weekday - 1, date: loopDate));

        loopDate = loopDate.subtract(Duration(days: 1));
      }

      return result;
    } catch (e) {
      logger.e('Error generating days:$e');
      return [];
    }
  }

  DateTime getLatestExam() {
    DateTime? currentDate = null;
    for (CourseModel course in instanceManager.sessionStorage.activeCourses) {
      if (currentDate != null) {
        if (course.examDate.isAfter(currentDate)) {
          currentDate = course.examDate;
        }
      } else {
        currentDate = course.examDate;
      }
    }
    return currentDate!.subtract(Duration(days: 1));
  }

  void printAllTimeSlots(List<TimeSlot> list) {
    logger.i('Timeslots gotten:');
    for (TimeSlot x in list) {
      x.print();
    }
  }
}
