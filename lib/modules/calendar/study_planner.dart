import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/scheduler_stack_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'dart:math';

/*class StudyPlanner {

  final firebaseCrud;
  final uid;
  late List<SchedulerStack> generalStacks;

  StudyPlanner({
    required this.firebaseCrud,
    required this.uid,
  });

  Future<String?> calculateSchedule() async {
    try {
      await firebaseCrud.deleteSchedule();
      List<TimeSlot>? scheduleLimits = await firebaseCrud.getScheduleLimits();

      generalStacks = await generateStacks();
      for (SchedulerStack stack in generalStacks) {
        stack.print();
      }

      List<Day> result = [];
      List<List<TimeSlot>>? weekdayRestrictions = null;

      if (scheduleLimits != null) {
        weekdayRestrictions = separateTimesForWeekday(scheduleLimits);
      }

      DateTime loopDate =
          getLastDayOfStudy(instanceManager.sessionStorage.activeCourses)!
              .subtract(Duration(days: 1));
      
      if(loopDate == null){
        return 'No courses';
      }

      Day dayToAdd = Day(
          id: DateTime(
                  loopDate.year, loopDate.month, loopDate.day, 0, 0, 0, 0, 0)
              .toString(),
          weekday: loopDate.weekday,
          date: DateTime(
              loopDate.year, loopDate.month, loopDate.day, 0, 0, 0, 0, 0));

      while (
          generalStacks.length != 0 && dayToAdd!.date.isAfter(DateTime.now())) {
        if (weekdayRestrictions != null)
          dayToAdd.times =
              List<TimeSlot>.from(weekdayRestrictions[dayToAdd.weekday - 1]);
        fillDayWithSessions(dayToAdd, generalStacks);

        result.insert(0, dayToAdd);
        logger.i(dayToAdd.getString());
        loopDate = loopDate.subtract(Duration(days: 1));
        dayToAdd = Day(
            id: DateTime(
                    loopDate.year, loopDate.month, loopDate.day, 0, 0, 0, 0, 0)
                .toString(),
            weekday: loopDate.weekday,
            date: DateTime(
                loopDate.year, loopDate.month, loopDate.day, 0, 0, 0, 0, 0));
      }

      

      if (!dayToAdd.date.isAfter(DateTime.now()) && generalStacks.length != 0) {
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
      

      day.getTotalAvailableTime();
      calculateWeights(filteredStacks, day);

      day.times.add(getTimeSlotWithUnit(filler, filteredStacks, day));

      filler = getAvailableTime(day);
    }

  }

 
  
  List<SchedulerStack> getFilteredStacks(Day day, List<SchedulerStack> stacks) {
    return stacks
        .where((schedulerStack) =>
            schedulerStack.course.examDate.isAfter(day.date))
        .toList();
  }

  TimeSlot getTimeSlotWithUnit(
      TimeSlot gap, List<SchedulerStack> filteredStacks, Day day) {
    
    //printFilteredStacks(filteredStacks, day, 'getTimeSlotWithUnit');
    Map<String, dynamic>? selectedUnit =
        getUnitToFillGap(filteredStacks, gap, day.totalAvailableTime);

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
        stack.weight = (stack.course.weight + (1 / daysToExam));
      } else {
        logger.e(
            'Error: days until exam = 0 - day: ${day.date} , stack: ${stack.course.name}, exam: ${stack.course.examDate}');
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
            'sessionTime': calculateSessionTime(candidateUnit, gap, stack),
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
            'sessionTime': calculateSessionTime(candidateRevision, gap, stack),
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

  int calculateSessionTime(UnitModel unit, TimeSlot gap, SchedulerStack stack) {
    final sessionHours = unit.hours / 3600;
    if (sessionHours > (gap.endTime - gap.startTime + 1)) {
      unit.hours -= (gap.endTime - gap.startTime + 1) * 3600;
      return gap.endTime - gap.startTime + 1;
    } else {
      unit.hours = 0;
      stack.weight = stack.weight!/2;
      return sessionHours.toInt();
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

  List<List<TimeSlot>> separateTimesForWeekday(List<TimeSlot> restrictions) {
    List<List<TimeSlot>> resultMatrix = [[], [], [], [], [], [], []];
    for (TimeSlot slot in restrictions) {
      resultMatrix[slot.weekday - 1].add(slot);
    }
    return resultMatrix;
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

  }
  */