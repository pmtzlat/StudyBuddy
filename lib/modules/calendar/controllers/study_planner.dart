import 'package:flutter/material.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
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

  Future<int> calculateSchedule() async {
    // 1 = Success
    // 0 = No time
    // -1 = Error
    try {
      //logger.d('calculateSchedule');
      //await firebaseCrud.deleteSchedule();

      generalStacks = await generateStacks();
      for (SchedulerStack stack in generalStacks) {
        stack.print();
      }

      List<Day> result = [];

      DateTime loopDate =
          getLastDayOfStudy(instanceManager.sessionStorage.activeExams)!
              .subtract(Duration(days: 1));

      if (loopDate == null) {
        return 1;
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
        await dayToAdd.getGaps();
        dayToAdd.getTotalAvailableTime();

        await fillDayWithSessions(dayToAdd, generalStacks);

        logger.w(dayToAdd.getString());

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

      final now = DateTime.now();

      if (areDatesEqual(dayToAdd.date, now) && generalStacks.length != 0) {
        final newStart = now.add(Duration(hours: 1));
        if (!isSecondDayNext(now, newStart)) {
          await dayToAdd.getGaps();
          dayToAdd.headStart(dateTimeToTimeOfDay(newStart));
          dayToAdd.getTotalAvailableTime();

          //logger.d(dayToAdd.getString());
          await fillDayWithSessions(dayToAdd, generalStacks);
          logger.w(dayToAdd.getString());
          result.insert(0, dayToAdd);
        }
      }

      if (generalStacks.length != 0) {
        instanceManager.sessionStorage.leftoverExams = <String>[];
        saveLeftoverExams(generalStacks);
        return 0;
      }

      if (await firebaseCrud.deleteNotPastCalendarDays() == -1) {
        return -1;
      }
      //logger.i('Success deleting calendar Days!');

      for (var day in result) {
        var dayID = await firebaseCrud.addCalendarDay(day);
        if (dayID == null) {
          return -1;
        }

        var res = 1;
        for (var timeSlot in day.times) {
          if (timeSlot.examID != 'free') {
            
            timeSlot.date = day.date;
            res = await firebaseCrud.addTimeSlotToCalendarDay(dayID, timeSlot);

            if (res == -1) return -1;
          }
        }
      }

      return 1;
    } catch (e) {
      logger.e('Error recalculating schedule: $e');
      return -1;
    }
  }

  void saveLeftoverExams(List<SchedulerStack> stacks) {
    var leftovers = instanceManager.sessionStorage.leftoverExams;
    for (var exam in stacks) {
      String toAdd = '';
      toAdd += ' ${exam.exam.name}: \n';
      if (exam.units != null) {
        for (var unit in exam.units!) {
          toAdd += '${unit.name}, ';
        }
      }
      if (exam.revisions != null) {
        for (var revision in exam.revisions!) {
          toAdd += '${revision.name}, ';
        }
      }
      //logger.d(toAdd);
      leftovers.add(toAdd);
    }

  }

  Future<void> fillDayWithSessions(Day day, List<SchedulerStack> stacks) async {
    try {
      //logger.d('fillDayWithSessions');

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
            schedulerStack.exam.examDate.isAfter(day.date))
        .toList();
  }

  TimeSlot getTimeSlotWithUnit(
      TimeSlot gap, List<SchedulerStack> filteredStacks, Day day) {
    //printFilteredStacks(filteredStacks, day, 'getTimeSlotWithUnit');
    try {
      //logger.d('getTimeSlotWithUnit');
      Map<String, dynamic>? selectedUnit =
          selectExamAndUnit(filteredStacks, gap, day.totalAvailableTime);

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
          examName: selectedUnit['sessionInfo'][0],
          examID: selectedUnit['examID'],
          unitName: selectedUnit['sessionInfo'][1],
          unitID: selectedUnit['unitID']);

      gap.endTime = startTime;
      gap.calculateDuration(gap.startTime, gap.endTime);
      //logger.w('Trigger deletion? ${gap.startTime} =? ${gap.endTime}');
      if (gap.startTime == gap.endTime) {
        //logger.w('Trigger deletion: ${gap.startTime} =? ${gap.endTime}');
        day.times.remove(gap);
        //logger.w(day.times);
      }

      //logger.i('Selected unit: ${result.examName}: ${result.startTime} - ${result.endTime}');
      //logger.f(
      //   'Result: ${result.examID} - ${result.examName}, ${result.startTime} - ${result.endTime}');
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
        final daysToExam = _getDaysToExam(day, stack);
        if (daysToExam > 0) {
          stack.weight = (stack.exam.weight + (1 / daysToExam));
        } else {
          logger.e(
              'Error: days until exam = 0 - day: ${day.date} , stack: ${stack.exam.name}, exam: ${stack.exam.examDate}');
        }
        ;
      }
      stacks.sort((a, b) => b.weight!.compareTo(a.weight!));
    } catch (e) {
      logger.e('Error calculating weights: $e');
    }
  }

  int _getDaysToExam(Day day, SchedulerStack stack) {
    //logger.d('getDaysToExam');
    try {
      Duration difference = stack.exam.examDate.difference(day.date);
      int daysDifference = difference.inDays;

      return daysDifference;
    } catch (e) {
      logger.e('Error getting Days to Exam: $e');
      return 0;
    }
  }

  Map<String, dynamic>? selectExamAndUnit(
      List<SchedulerStack> stacks, TimeSlot gap, Duration availableTime) {
    //logger.d('getUnitToFillGap');
    stacks.sort((a, b) => b.weight!.compareTo(a.weight!));
    late Map<String, dynamic>? selectedUnit;

    for (int i = 0; i < stacks.length; i++) {
      //logger.w('Weight of ${stacks[i].exam.name}: ${stacks[i].weight}');
      if (i != stacks.length - 1 &&
          (stacks[i].weight == stacks[i + 1].weight &&
              stacks[i].unitsInDay > stacks[i + 1].unitsInDay)) continue;
      selectedUnit = selectUnit(stacks[i], gap, availableTime);

      if (selectedUnit != null) {
        if (stacks[i].units.isEmpty && stacks[i].revisions.isEmpty) {
          //logger.i('Removed stack: ${stacks[i].exam.name}');
          generalStacks
              .removeWhere((stack) => stack.exam.id == stacks[i].exam.id);
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
        if (candidateUnit.sessionTime == Duration.zero ||
            candidateUnit.completed == true) {
          continue;
        }
        if (candidateUnit.sessionTime <= availableTime) {
          final result = {
            'unit': candidateUnit,
            'sessionTime': calculateSessionTime(candidateUnit, gap, stack),
            'examID': stack.exam.id,
            'sessionInfo': [stack.exam.name, candidateUnit.name],
            'unitID': candidateUnit.id
          };
          if (candidateUnit.sessionTime == Duration.zero)
            stack.units.removeAt(i);
          return result;
        } else {
          if (stack.exam.orderMatters) {
            return null;
          }
        }
      }
    } else {
      //logger.i(stack.revisions);
      for (int i = stack.revisions.length - 1; i >= 0; i--) {
        final candidateRevision = stack.revisions[i];
        //logger.i('Candidate revision: ${candidateRevision.name}');

        if (candidateRevision.sessionTime == Duration.zero) {
          continue;
        }
        if (candidateRevision.sessionTime <= availableTime) {
          final result = {
            'unit': candidateRevision,
            'sessionTime': calculateSessionTime(candidateRevision, gap, stack),
            'examID': stack.exam.id,
            'sessionInfo': [stack.exam.name, candidateRevision.name],
            'unitID': candidateRevision.id
          };
          if (candidateRevision.sessionTime == Duration.zero)
            stack.revisions.removeAt(i);
          return result;
        } else {
          final result = {
            'unit': candidateRevision,
            'sessionTime': calculateSessionTime(candidateRevision, gap, stack),
            'examID': stack.exam.id,
            'sessionInfo': [stack.exam.name, candidateRevision.name],
            'unitID': candidateRevision.id
          };
          if (candidateRevision.sessionTime == Duration.zero)
            stack.revisions.removeAt(i);
          return result;
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
        //logger.d(
        //  'Stack ${stack.exam.name} weight divided by 2! - ${stack.weight}');

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
      for (ExamModel exam in instanceManager.sessionStorage.activeExams) {
        await exam.getUnits();
        await exam.getRevisions();
        SchedulerStack stack = SchedulerStack(exam: exam);
        await stack.initializeUnitsAndRevision(exam);
        result.add(stack);
      }
      return result;
    } catch (e) {
      logger.e('Error generating stacks: $e');
      return [];
    }
  }

  DateTime? getLastDayOfStudy(dynamic activeExams) {
    //logger.d('getLastDayOfStudy');
    DateTime? currentDate = null;
    for (ExamModel exam in activeExams) {
      if (currentDate != null) {
        if (exam.examDate.isAfter(currentDate)) {
          currentDate = exam.examDate;
        }
      } else {
        currentDate = exam.examDate;
      }
    }
    if (currentDate == null) {
      logger.e('No exams found!');
      return null;
    }
    return currentDate!;
  }
}
