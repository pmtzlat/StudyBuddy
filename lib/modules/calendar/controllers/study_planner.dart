import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/datatype_utils.dart';
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

  StudyPlanner({
    required this.firebaseCrud,
    required this.uid,
  });

  Future<String?> calculateSchedule() async {
    try {
      //logger.d('calculateSchedule');
      await firebaseCrud.deleteSchedule();

      generalStacks = await generateStacks();
      for (SchedulerStack stack in generalStacks) {
        stack.print();
      }

      List<Day> result = [];

      DateTime loopDate =
          getLastDayOfStudy(instanceManager.sessionStorage.activeCourses)!
              .subtract(Duration(days: 1));

      if (loopDate == null) {
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
        //logger.f(dayToAdd.getString());

        await fillDayWithSessions(dayToAdd, generalStacks);

        logger.e(dayToAdd.getString());

        result.insert(0, dayToAdd);
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

  Future<void> fillDayWithSessions(Day day, List<SchedulerStack> stacks) async {
    try {
      //logger.d('fillDayWithSessions');
      await day.getGaps();
      day.getTotalAvailableTime();
      //logger.w(day.getString());
      //logger.w(day.totalAvailableTime);

      List<SchedulerStack> filteredStacks = getFilteredStacks(day, stacks);
      if (filteredStacks.length == 0) {
        //logger.w('empty filtered stacks');
        return;
      }

      day.times.sort((a, b) {
        final aEndMinutes = a.endTime.hour * 60 + a.endTime.minute;
        final bEndMinutes = b.endTime.hour * 60 + b.endTime.minute;
        return aEndMinutes - bEndMinutes;
      });

      late TimeSlot gap;
      var newTimes = <TimeSlot>[];

      if (filteredStacks.length == 0) {
        return;
      }

      calculateWeights(filteredStacks, day);

      while (day.totalAvailableTime != Duration.zero) {
        gap = day.times.last;
        //logger.t('chosen gap: ${gap.startTime} - ${gap.endTime}');

        newTimes.add(getTimeSlotWithUnit(gap, filteredStacks, day));

        day.getTotalAvailableTime();
        //logger.w(day.totalAvailableTime);

        ;
      }

      day.times = newTimes;
    } catch (e) {
      logger.e('Error filling day with sessions: $e');
    }
  }

  List<SchedulerStack> getFilteredStacks(Day day, List<SchedulerStack> stacks) {
    //logger.d('GetfilteredStacks');
    return stacks
        .where((schedulerStack) =>
            schedulerStack.course.examDate.isAfter(day.date))
        .toList();
  }

  TimeSlot getTimeSlotWithUnit(
      TimeSlot gap, List<SchedulerStack> filteredStacks, Day day) {
    //printFilteredStacks(filteredStacks, day, 'getTimeSlotWithUnit');
    try {
      //logger.d('getTimeSlotWithUnit');
      Map<String, dynamic>? selectedUnit =
          selectCourseAndUnit(filteredStacks, gap, day.totalAvailableTime);

      if (selectedUnit == null) {
        day.times.remove(gap);
        return gap;
      }

      TimeOfDay startTime = subtractDurationFromTimeOfDay(
          gap.endTime, selectedUnit['sessionTime']);

      final result = TimeSlot(
          weekday: day.weekday,
          startTime: startTime,
          endTime: gap.endTime,
          courseName: selectedUnit['sessionInfo'],
          courseID: selectedUnit['courseID']);

      gap.endTime = startTime;
      gap.calculateDuration(gap.startTime, gap.endTime);
      //logger.w('Trigger deletion? ${gap.startTime} =? ${gap.endTime}');
      if (gap.startTime == gap.endTime) {
        //logger.w('Trigger deletion: ${gap.startTime} =? ${gap.endTime}');
        day.times.remove(gap);
        //logger.w(day.times);
      }

      //logger.i('Selected unit: ${result.courseName}: ${result.startTime} - ${result.endTime}');
      //logger.f(
      //   'Result: ${result.courseID} - ${result.courseName}, ${result.startTime} - ${result.endTime}');
      return result;
    } catch (e) {
      logger.e('Error getting time slot with unit: $e');
      day.times.remove(gap);
      return gap;
    }
  }

  void calculateWeights(List<SchedulerStack> stacks, Day day) {
    //logger.d('calculateWeights');
    try {
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
    } catch (e) {
      logger.e('Error calculating weights: $e');
    }
  }

  int getDaysToExam(Day day, SchedulerStack stack) {
    //logger.d('getDaysToExam');
    try {
      Duration difference = stack.course.examDate.difference(day.date);
      int daysDifference = difference.inDays;

      return daysDifference;
    } catch (e) {
      logger.e('Error getting Days to Exam: $e');
      return 0;
    }
  }

  Map<String, dynamic>? selectCourseAndUnit(
      List<SchedulerStack> stacks, TimeSlot gap, Duration availableTime) {
    //logger.d('getUnitToFillGap');
    stacks.sort((a, b) => b.weight!.compareTo(a.weight!));
    late Map<String, dynamic>? selectedUnit;

    for (int i = 0; i < stacks.length; i++) {
      logger.w('Weight of ${stacks[i].course.name}: ${stacks[i].weight}');
      if (i != stacks.length - 1 &&
          (stacks[i].weight == stacks[i + 1].weight &&
          stacks[i].unitsInDay > stacks[i + 1].unitsInDay)) continue;
      selectedUnit = selectUnit(stacks[i], gap, availableTime);

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

  Map<String, dynamic>? selectUnit(
      SchedulerStack stack, TimeSlot gap, Duration availableTime) {
    //logger.d('selectUnitInStack');
    //logger.d(availableTime);
    if (stack.revisions.length == 0) {
      for (int i = stack.units.length - 1; i >= 0; i--) {
        final candidateUnit = stack.units[i];
        //logger.i('Candidate unit: ${candidateUnit.name}: ${candidateUnit.hours/ 3600} hours');
        if (candidateUnit.sessionTime == Duration.zero || candidateUnit.completed == true) {
          continue;
        }
        if (candidateUnit.sessionTime <= availableTime) {
          final result = {
            'unit': candidateUnit,
            'sessionTime': calculateSessionTime(candidateUnit, gap, stack),
            'courseID': stack.course.id,
            'sessionInfo': '${stack.course.name}: ${candidateUnit.name}'
          };
          if (candidateUnit.sessionTime == Duration.zero)
            stack.units.removeAt(i);
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

        if (candidateRevision.sessionTime == Duration.zero) {
          continue;
        }
        if (candidateRevision.sessionTime <= availableTime) {
          final result = {
            'unit': candidateRevision,
            'sessionTime': calculateSessionTime(candidateRevision, gap, stack),
            'courseID': stack.course.id,
            'sessionInfo': '${stack.course.name}: ${candidateRevision.name}'
          };
          if (candidateRevision.sessionTime == Duration.zero)
            stack.revisions.removeAt(i);
          return result;
        } else {
          if (stack.course.orderMatters) {
            return null;
          }
        }
      }
    }
  }

  Duration calculateSessionTime(
      UnitModel unit, TimeSlot gap, SchedulerStack stack) {
    try {
      //logger.d('calculateSessionTime');
      final sessionHours = unit.sessionTime;
      //logger.w('$sessionHours, ${gap.duration}');
      if (sessionHours > (gap.duration)) {
        unit.sessionTime -= gap.duration;
        //logger.w('Sessiontime: ${gap.duration}');

        return gap.duration;
      } else {
        unit.sessionTime = Duration.zero;
        stack.weight = stack.weight! / 2;
        stack.unitsInDay++;
        logger.d(
            'Stack ${stack.course.name} weight divided by 2! - ${stack.weight}');

        //logger.w('Sessiontime: ${sessionHours}');

        return sessionHours;
      }
    } catch (e) {
      logger.e('Error calcualting session time: $e');
      return Duration.zero;
    }
  }

  Future<List<SchedulerStack>> generateStacks() async {
    try {
      //logger.d('generateStacks');
      List<SchedulerStack> result = [];
      for (CourseModel course in instanceManager.sessionStorage.activeCourses) {
        await course.getUnits();
        await course.getRevisions();
        SchedulerStack stack = SchedulerStack(course: course);
        await stack.initializeUnitsAndRevision(course);
        result.add(stack);
      }
      return result;
    } catch (e) {
      logger.e('Error generating stacks: $e');
      return [];
    }
  }

  DateTime? getLastDayOfStudy(dynamic activeCourses) {
    //logger.d('getLastDayOfStudy');
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
