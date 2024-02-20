import 'package:flutter/material.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/scheduler_stack_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

///Debugging color code:
/// .f - stacks
/// .w - days
/// .i - information
/// .d - selected unit
///

class StudyPlanner {
  final firebaseCrud;
  final uid;
  late List<SchedulerStackModel> generalStacks;

  StudyPlanner({
    required this.firebaseCrud,
    required this.uid,
  });

  Future<int> calculateSchedule() async {
    // 1 = Success
    // 0 = No time
    // -1 = Error

    try {
      if ((instanceManager.sessionStorage.activeExams.isEmpty) ||
          (instanceManager.sessionStorage.weeklyGaps.isEmpty)) {
        logger.i('No exams or no availability. ');
        if (await firebaseCrud
                .deleteNotPastCalendarDays()
                .timeout(timeoutDuration) ==
            -1) {
          return -1;
        }
        instanceManager.sessionStorage.setNeedsRecalc(false);
        return 1;
      }
      
      Map<String, Map<String, int>> unitTotalSessions = {};

      void fillTotalUnitSessions(TimeSlotModel timeSlot) {
        if (unitTotalSessions.containsKey(timeSlot.examID)) {
          if (unitTotalSessions[timeSlot.examID]!
              .containsKey(timeSlot.unitID)) {
            unitTotalSessions[timeSlot.examID]![timeSlot.unitID] =
                (unitTotalSessions[timeSlot.examID]![timeSlot.unitID] ?? 0) + 1;
          } else {
            unitTotalSessions[timeSlot.examID]![timeSlot.unitID] = 1;
          }
        } else {
          unitTotalSessions[timeSlot.examID] = {timeSlot.unitID: 1};
        }
      }

      Future<void> updateAllUnitSessionCompletionInfo() async {
        for (var examID in unitTotalSessions.keys) {
          for (var unitID in unitTotalSessions[examID]!.keys) {
            final totalSessions = unitTotalSessions[examID]![unitID]!;
            await firebaseCrud.updateUnitSessionCompletionInfo(
                examID, unitID, totalSessions);
          }
        }
      }

      generalStacks = await generateStacks();
      logger.f('Stacks generated! \n${getStringFromStackList(generalStacks)}');

      List<DayModel> result = [];

      DateTime? startDate =
          getLastDayOfStudy(instanceManager.sessionStorage.activeExams)!
              .subtract(Duration(days: 1));

      if (startDate == null) {
        logger.i('startDate = null');
        return 1;
      }

      logger.i('Start date: ${startDate}');
      await instanceManager.calendarController.getCustomDays();

      DayModel dayToAdd = await getGeneralOrCustomday(startDate);
      List<SchedulerStackModel> singularDayStacks = <SchedulerStackModel>[];

      while (generalStacks.length != 0 &&
          !((dayToAdd!.date.isBefore(stripTime(DateTime.now()))))) {
        await dayToAdd.getGaps();
        dayToAdd.getTotalAvailableTime();
        final now = DateTime.now();

        if (areDatesEqual(dayToAdd.date, now) && generalStacks.length != 0) {
          final newStart = now.add(Duration(minutes: 15));
          if (!isSecondDayNext(now, newStart)) {
            dayToAdd.headStart(dateTimeToTimeOfDay(newStart));
            dayToAdd.getTotalAvailableTime();
          }
        }
        singularDayStacks = List.from(generalStacks);

        await fillDayWithSessions(dayToAdd, singularDayStacks);
        logger.w('Full day to add: \n\n ${dayToAdd.getString()}');

        result.insert(0, dayToAdd);
        startDate = startDate!.subtract(Duration(days: 1));
        dayToAdd = await getGeneralOrCustomday(startDate);
      }

      if (generalStacks.length != 0) {
        instanceManager.sessionStorage.leftoverExams = <String>[];
        saveLeftoverExams(generalStacks);
        return 0;
      }

      if (await firebaseCrud
              .deleteNotPastCalendarDays()
              .timeout(timeoutDuration) ==
          -1) {
        return -1;
      }

      for (var day in result) {
        var dayID =
            await firebaseCrud.addCalendarDay(day).timeout(timeoutDuration);
        if (dayID == null) {
          return -1;
        }

        var res = 1;
        for (var timeSlot in day.timeSlots) {
          if (timeSlot.examID != 'free') {
            fillTotalUnitSessions(timeSlot);

            timeSlot.date = day.date;
            res = await firebaseCrud
                .addTimeSlotToCalendarDay(dayID, timeSlot)
                .timeout(timeoutDuration);

            if (res == -1) return -1;
          }
        }
      }

      await updateAllUnitSessionCompletionInfo();
      await instanceManager.examsController.getAllExams();

      return 1;
    } catch (e) {
      logger.e('Error recalculating schedule: $e');
      return -1;
    }
  }

  Future<DayModel> getGeneralOrCustomday(DateTime startDate) async {
    return instanceManager.sessionStorage.customDays.firstWhere(
        (element) => element.date == startDate,
        orElse: () => DayModel(
            id: 'empty',
            weekday: startDate.weekday,
            date: DateTime(startDate.year, startDate.month, startDate.day, 0, 0,
                0, 0, 0)));
  }

  void saveLeftoverExams(List<SchedulerStackModel> stacks) {
    var leftovers = instanceManager.sessionStorage.leftoverExams;
    for (var exam in stacks) {
      String toAdd = '';
      toAdd += '${exam.exam.name}/';
      if (exam.units != null) {
        for (var unit in exam.units!) {
          toAdd += '${unit.name}/';
        }
      }
      if (exam.revisions != null) {
        for (var revision in exam.revisions!) {
          toAdd += '${revision.name}/';
        }
      }
      leftovers.add(toAdd);
    }
  }

  Future<void> fillDayWithSessions(
      DayModel day, List<SchedulerStackModel> stacks) async {
    try {
      if (stacks.length == 0) {
        return;
      }

      day.timeSlots.sort((a, b) {
        final aEndMinutes = a.endTime.hour * 60 + a.endTime.minute;
        final bEndMinutes = b.endTime.hour * 60 + b.endTime.minute;
        return aEndMinutes - bEndMinutes;
      });

      logger.w('Sorted day times: ${day.getString()}');

      late TimeSlotModel gap;
      var newTimes = <TimeSlotModel>[];

      if (stacks.length == 0) {
        return;
      }

      while (day.totalAvailableTime != Duration.zero) {
        calculateWeights(stacks, day);
        gap = day.timeSlots.last;
        logger.t(
            'Gap to fill: ${timeOfDayToStr(gap.startTime)} - ${timeOfDayToStr(gap.endTime)}');

        TimeSlotModel? obtainedSession = getTimeSlotWithUnit(gap, stacks, day);

        if (obtainedSession != null) {
          newTimes.add(obtainedSession);
        } else {
          logger.d('No unit found!');
        }
        //logger.f('New stacks: \n ${getStringFromStackList(stacks)}');

        day.getTotalAvailableTime();
        logger.w(
            'Day: ${day.getString()}\n\nNew total available time: ${day.totalAvailableTime}');
      }

      day.timeSlots = newTimes;
    } catch (e) {
      logger.e('Error filling day with sessions: $e');
    }
  }

  TimeSlotModel? getTimeSlotWithUnit(TimeSlotModel gap,
      List<SchedulerStackModel> filteredStacks, DayModel day) {
    try {
      Map<String, dynamic>? selectedUnit =
          selectExamAndUnit(filteredStacks, gap, day.totalAvailableTime);

      if (selectedUnit == null) {
        day.timeSlots.remove(gap);
        return null;
      }

      TimeOfDay startTime = subtractDurationFromTimeOfDay(
          gap.endTime, selectedUnit['sessionTime']);

      final result = TimeSlotModel(
          weekday: day.weekday,
          startTime: startTime,
          endTime: gap.endTime,
          examName: selectedUnit['sessionInfo'][0],
          examID: selectedUnit['examID'],
          unitName: selectedUnit['sessionInfo'][1],
          unitID: selectedUnit['unitID']);

      gap.endTime = startTime;
      gap.calculateDuration(gap.startTime, gap.endTime);

      if (gap.startTime == gap.endTime) {
        day.timeSlots.remove(gap);
      }

      return result;
    } catch (e) {
      logger.e('Error getting timeslot with unit: $e');
      day.timeSlots.remove(gap);
      return gap;
    }
  }

  void calculateWeights(List<SchedulerStackModel> stacks, DayModel day) {
    try {
      for (int i = stacks.length - 1; i >= 0; i--) {
        SchedulerStackModel stack = stacks[i];
        final daysToExam = _getDaysToExam(day, stack);
        if (daysToExam > 0) {
          stack.weight = (stack.exam.weight + (1 / daysToExam));
        } else {
          stacks.removeAt(i);
          logger.e(
              'Error: days until exam = 0 - day: ${day.date} , stack: ${stack.exam.name}, exam: ${stack.exam.examDate}');
        }
        ;
      }
      stacks.sort((a, b) => b.weight!.compareTo(a.weight!));
      logger
          .f('Stacks sorted by weight: \n\n${getStringFromStackList(stacks)}');
    } catch (e) {
      logger.e('Error calculating weights: $e');
    }
  }

  int _getDaysToExam(DayModel day, SchedulerStackModel stack) {
    try {
      Duration difference = stack.exam.examDate.difference(day.date);
      int daysDifference = difference.inDays;

      return daysDifference;
    } catch (e) {
      logger.e('Error getting Days to Exam: $e');
      return 0;
    }
  }

  Map<String, dynamic>? selectExamAndUnit(List<SchedulerStackModel> stacks,
      TimeSlotModel gap, Duration availableTime) {
    stacks.sort((a, b) => b.weight!.compareTo(a.weight!));
    late Map<String, dynamic>? selectedUnit;

    for (int i = 0; i < stacks.length; i++) {
      if (i != stacks.length - 1 &&
          (stacks[i].weight == stacks[i + 1].weight &&
              stacks[i].unitsInDay > stacks[i + 1].unitsInDay)) continue;
      selectedUnit = selectUnit(stacks[i], gap, availableTime);

      if (selectedUnit != null) {
        if (stacks[i].units.isEmpty && stacks[i].revisions.isEmpty) {
          generalStacks
              .removeWhere((stack) => stack.exam.id == stacks[i].exam.id);

          stacks.removeAt(
              i); //THIS LINE GIVES PROBLEMS WHEN UNITS ARE SELECTED - stacks and generalstacks are the same
        }
        return selectedUnit;
      }
    }
    return null;
  }

  Map<String, dynamic>? selectUnit(
      SchedulerStackModel stack, TimeSlotModel gap, Duration availableTime) {
    if (stack.revisions.length == 0) {
      for (int i = stack.units.length - 1; i >= 0; i--) {
        final candidateUnit = stack.units[i];
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
            'unitID': candidateUnit.id,
          };

          logResult(result);
          if (candidateUnit.sessionTime == Duration.zero)
            stack.units.removeAt(i);

          return result;
        } else {
          if (!stack.exam.sessionsSplittable) {
            if (stack.exam.orderMatters) {
              return null;
            } else {
              continue;
            }
          } else {
            if (stack.exam.orderMatters) {
              return null;
            } else {
              final result = {
                'unit': candidateUnit,
                'sessionTime': calculateSessionTime(candidateUnit, gap, stack),
                'examID': stack.exam.id,
                'sessionInfo': [stack.exam.name, candidateUnit.name],
                'unitID': candidateUnit.id,
              };

              logResult(result);
              if (candidateUnit.sessionTime == Duration.zero)
                stack.units.removeAt(i);

              return result;
            }
          }
        }
      }
    } else {
      for (int i = stack.revisions.length - 1; i >= 0; i--) {
        final candidateRevision = stack.revisions[i];

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
          logResult(result);
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
          logResult(result);
          if (candidateRevision.sessionTime == Duration.zero)
            stack.revisions.removeAt(i);
          return result;
        }
      }
    }
  }

  Duration calculateSessionTime(
      UnitModel unit, TimeSlotModel gap, SchedulerStackModel stack) {
    try {
      final sessionHours = unit.sessionTime;
      if (sessionHours > (gap.duration)) {
        unit.sessionTime -= gap.duration;

        return gap.duration;
      } else {
        unit.sessionTime = Duration.zero;
        stack.weight = stack.weight! / 2;
        stack.unitsInDay++;

        return sessionHours;
      }
    } catch (e) {
      logger.e('Error calcualting session time: $e');
      return Duration.zero;
    }
  }

  Future<List<SchedulerStackModel>> generateStacks() async {
    try {
      List<SchedulerStackModel> result = [];
      for (ExamModel exam in instanceManager.sessionStorage.activeExams) {
        await exam.getUnits();
        await exam.getRevisions();
        SchedulerStackModel stack = SchedulerStackModel(exam: exam);
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
    DateTime? selectedDate = null;
    for (ExamModel exam in activeExams) {
      if (selectedDate != null) {
        if (exam.examDate.isAfter(selectedDate)) {
          selectedDate = exam.examDate;
        }
      } else {
        selectedDate = exam.examDate;
      }
    }
    if (selectedDate == null) {
      logger.e('No exams found!');
      return null;
    }
    return selectedDate!;
  }

  void logResult(Map<String, dynamic> result) {
    String output =
        'Selected unit: \n ${result['sessionInfo'][0]}: ${result['sessionInfo'][1]}\nDuration: ${formatDuration(result['sessionTime'])}';
    logger.d(output);
  }
}
