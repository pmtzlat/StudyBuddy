import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/scheduler_stack_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'dart:math';

class StudyPlanner {
  final firebaseCrud;
  final uid;
  late List<SchedulerStack> generalStacks;
  bool unitsStayInDay;

  StudyPlanner({
    required this.firebaseCrud,
    required this.uid,
    this.unitsStayInDay = false,
  });

  Future<String?> calculateSchedule() async {
    try {
      await firebaseCrud.deleteSchedule();
      List<TimeSlot>? scheduleLimits = await firebaseCrud.getScheduleLimits();
      if (scheduleLimits == null) {
        logger.e('No restraints found');
        return null;
      }

      List<Day>? days = generateDays();
      if (days == null) {
        return 'No courses';
      }

      generalStacks = await generateStacks();
      for (SchedulerStack stack in generalStacks) {
        stack.print();
      }
      await fillRestrictions(days);

      List<Day> result = [];
      while (days.length > 0 && generalStacks.length > 0) {
        Day furthestDay = days.removeAt(0);
        //logger.i('Day in focus: \n ${furthestDay.getString()}');
        fillDayWithSessions(furthestDay, generalStacks);

        result.add(furthestDay);
        logger.i(furthestDay.getString());
      }

      if (days.length == 0 && generalStacks.length != 0) {
        return 'No time';
      }

      //save days to db

      return 'Success';
    } catch (e) {
      logger.e('Error recalculating schedule: $e');
    }
  }

  void fillDayWithSessions(Day day, List<SchedulerStack> stacks) {
    day.getTotalAvailableTime();
    TimeSlot? filler = getAvailableTime(day);

    List<SchedulerStack> filteredStacks = getFilteredStacks(day, stacks);
    if (filteredStacks.length == 0) {
      return;
    }

    while (filler != null && filteredStacks.length != 0) {
      //logger.i('Gap found: ${filler.getInfoString()}');
      //logger.d(day.getString());
      
      if (unitsStayInDay == true) day.getTotalAvailableTime();
      
      day.times.add(getTimeSlotWithUnit(filler, filteredStacks, day));

      filler = getAvailableTime(day);
    }
    //logger.i(day.getString());
  }

  List<SchedulerStack> getFilteredStacks(Day day, List<SchedulerStack> stacks) {
    return stacks
        .where((schedulerStack) =>
            schedulerStack.course.examDate.isAfter(day.date))
        .toList();
  }

  TimeSlot getTimeSlotWithUnit(
      TimeSlot gap, List<SchedulerStack> stacks, Day day) {
    calculateWeights(stacks, day);
    Map<String, dynamic>? selectedUnit =
        getUnitToFillGap(stacks, gap, day.totalAvailableTime);

    if (selectedUnit == null) {
      return gap;
    }
    int startTime = (gap.endTime) - selectedUnit['sessionTime'] + 1 as int;

    final result = TimeSlot(
        weekday: day.weekday,
        startTime: startTime,
        endTime: gap.endTime,
        courseName: selectedUnit['sessionInfo'],
        courseID: selectedUnit['courseID']);

    //logger.i('Selected unit: ${result.courseName}: ${result.startTime} - ${result.endTime}');

    return result;
  }

  void calculateWeights(List<SchedulerStack> stacks, Day day) {
    for (SchedulerStack stack in stacks) {
      final daysToExam = getDaysToExam(day, stack);
      if (daysToExam > 0) {
        stack.weight = (stack.course.weight + (1 / daysToExam)) /
            pow(
                2,
                unitsAlreadyInDay(
                    day,
                    stack.course
                        .id)); // stack.course.name has to be changed to id
        //logger.i('Stack ${stack.course.name} weight: ${stack.weight}');
      } else {
        logger.e('Error: days until exam = 0');
      }
      ;
    }
    stacks.sort((a, b) => b.weight!.compareTo(a.weight!));
  }

  int getDaysToExam(Day day, SchedulerStack stack) {
    Duration difference = stack.course.examDate.difference(day.date);
    int daysDifference = difference.inDays;

    return daysDifference;
  }

  int unitsAlreadyInDay(Day day, String courseID) {
    int count = 0;
    for (TimeSlot slot in day.times) {
      if (slot.courseID == courseID) count++;
    }
    //logger.f('units in Day: $count');
    return count;
  }

  Map<String, dynamic>? getUnitToFillGap(
      List<SchedulerStack> stacks, TimeSlot gap, int availableTime) {
    stacks.sort((a, b) => b.weight!.compareTo(a.weight!));
    late Map<String, dynamic>? selectedUnit;

    for (int i = 0; i < stacks.length; i++) {
      selectedUnit = selectUnitInStack(stacks[i], gap, availableTime);

      if (selectedUnit != null) {
        if (stacks[i].units.isEmpty) {
          //logger.i('Removed stack: ${stacks[i].course.name}');
          generalStacks
              .removeWhere((stack) => stack.course.id == stacks[i].course.id);
          stacks.removeAt(i);
        }
        return selectedUnit;
      }
    }
    return null;
  }

  Map<String, dynamic>? selectUnitInStack(
      SchedulerStack stack, TimeSlot gap, int availableTime) {
    //logger.d(availableTime);
    if (stack.revisions.length == 0) {
      for (int i = stack.units.length - 1; i >= 0; i--) {
        final candidateUnit = stack.units[i];
        //logger.i('Candidate unit: ${candidateUnit.name}: ${candidateUnit.hours/ 3600} hours');
        if (candidateUnit.hours == 0) {
          continue;
        }
        if (candidateUnit.hours / 3600 <= availableTime) {
          final result = {
            'unit': candidateUnit,
            'sessionTime': calculateSessionTime(candidateUnit, gap),
            'courseID': stack.course.id,
            'sessionInfo': '${stack.course.name}: ${candidateUnit.name}'
          };
          if (candidateUnit.hours == 0) stack.units.removeAt(i);
          return result;
        } else {
          if (stack.course.orderMatters) {
            return null;
          }
        }
      }
    } else {
      for (int i = stack.revisions.length - 1; i >= 0; i--) {
        final candidateRevision = stack.revisions[i];
        //logger.i('Candidate revision: ${candidateRevision.name}: ${candidateRevision.hours/ 3600} hours');

        if (candidateRevision.hours == 0) {
          continue;
        }
        if (candidateRevision.hours / 3600 <= availableTime) {
          final result = {
            'unit': candidateRevision,
            'sessionTime': calculateSessionTime(candidateRevision, gap),
            'courseID': stack.course.id,
            'sessionInfo': '${stack.course.name}: ${candidateRevision.name}'
          };
          if (candidateRevision.hours == 0) stack.revisions.removeAt(i);
          return result;
        } else {
          if (stack.course.orderMatters) {
            return null;
          }
        }
      }
    }
  }

  int calculateSessionTime(UnitModel unit, TimeSlot gap) {
    final sessionHours = unit.hours / 3600;
    if (sessionHours <= (gap.endTime - gap.startTime + 1)) {
      unit.hours = 0;
      return sessionHours.toInt();
    } else {
      unit.hours -= (gap.endTime - gap.startTime + 1) * 3600;
      return gap.endTime - gap.startTime + 1;
    }
  }

  TimeSlot? getAvailableTime(Day day) {
    return day.findLatestTimegap();
  }

  Future<List<SchedulerStack>> generateStacks() async {
    try {
      List<SchedulerStack> result = [];
      for (CourseModel course in instanceManager.sessionStorage.activeCourses) {
        SchedulerStack stack = SchedulerStack(course: course);
        await stack.initializeUnitsWithRevision(course);
        result.add(stack);
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

  List<Day>? generateDays() {
    try {
      DateTime loopDate =
          getLastDayOfStudy(instanceManager.sessionStorage.activeCourses)!
              .subtract(Duration(days: 1));
      List<Day> result = [];
      while (loopDate.isAfter(DateTime.now()) ||
          loopDate.isAtSameMomentAs(DateTime.now())) {
        result.add(Day(weekday: loopDate.weekday - 1, date: loopDate));

        loopDate = loopDate.subtract(Duration(days: 1));
      }

      return result;
    } catch (e) {
      logger.e('Error generating days:$e');
      return null;
    }
  }

  DateTime? getLastDayOfStudy(dynamic activeCourses) {
    DateTime? currentDate = null;
    for (CourseModel course in activeCourses) {
      if (currentDate != null) {
        if (course.examDate.isAfter(currentDate)) {
          currentDate = course.examDate;
        }
      } else {
        currentDate = course.examDate;
      }
    }
    if (currentDate == null) {
      logger.e('No courses found!');
      return null;
    }
    return currentDate!;
  }

  void printAllTimeSlots(List<TimeSlot> list) {
    //logger.i('Timeslots gotten:');
    for (TimeSlot x in list) {
      x.getInfoString();
    }
  }
}
