import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';

import '../models/exam_model.dart';
import '../models/user_model.dart';
import 'logging_service.dart';

class FirebaseCrudService {
  final weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  Future<String?> addExamToUser({required ExamModel newExam}) async {
    // Check if the user document exists
    final uid = instanceManager.localStorage.getString('uid');
    final connectivityResult =
        await instanceManager.connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return null;
    }

    final userDocRef = instanceManager.db.collection('users').doc(uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      final examsCollectionRef = userDocRef.collection('exams');

      final newExamDocRef = await examsCollectionRef.add({
        'name': newExam.name,
        'weight': newExam.weight * 10,
        'examDate': newExam.examDate.toString(),
        'sessionTime': newExam.sessionTime.toString(),
        'timeStudied': newExam.timeStudied.toString(),
        'color': newExam.color,
        'id': '',
        'orderMatters': newExam.orderMatters,
      });

      await newExamDocRef.update({'id': newExamDocRef.id});

      return newExamDocRef.id as String;
    } else {
      logger.e('User document with UID $uid does not exist.');
      return null;
    }
  }

  Future<List<UnitModel>?> getUnitsForExam({required String examID}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    try {
      final examDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID);

      final unitCollectionRef = examDocRef.collection('units');

      final unitQuerySnapshot =
          await unitCollectionRef.orderBy('order', descending: false).get();

      final List<UnitModel> units = [];

      for (final unitDoc in unitQuerySnapshot.docs) {
        final unitData = unitDoc.data() as Map<String, dynamic>;
        final unit = UnitModel(
            name: unitData['name'] ?? '',
            sessionTime: parseTime(unitData['sessionTime']),
            id: unitDoc.id,
            order: unitData['order'] ?? 0,
            completed: unitData['completed'] ?? false,
            completionTime: parseTime(
                unitData['completionTime'] ?? Duration.zero.toString()),
            realStudyTime: parseTime(
                unitData['realStudyTime'] ?? Duration.zero.toString()));
        units.add(unit);
      }
      return units;
    } catch (e) {
      logger.e('Error getting units for exam $examID: $e');
      return null;
    }
  }

  Future<int> updateUnitCompletionTime(String examID, String unitID,
      String revisionOrUnit, Duration newCompletionTime) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    try {
      final unitRef = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection(revisionOrUnit)
          .doc(unitID);

      await unitRef.update({'completionTime': newCompletionTime.toString()});

      return 1;
    } catch (e) {
      logger.e('Error updating unit completion time for unit $unitID: $e');
      return -1;
    }
  }

  Future<UnitModel?> getSpecificUnit(
      String examID, String unitID, String revisionOrUnit) async {
    logger.i(
        'Getting specific unit: examID: $examID, unitID: $unitID, $revisionOrUnit');
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    try {
      final unitDoc = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection(revisionOrUnit)
          .doc(unitID)
          .get();

      if (unitDoc.exists) {
        //logger.i('Exists');
        final unitData = unitDoc.data() as Map<String, dynamic>;

        return UnitModel(
            name: unitData['name'] ?? '',
            sessionTime: parseTime(unitData['sessionTime']),
            id: unitDoc.id,
            order: unitData['order'] ?? 0,
            completed: unitData['completed'] ?? false,
            completionTime: parseTime(
                unitData['completionTime'] ?? Duration.zero.toString()),
            realStudyTime: parseTime(
                unitData['realStudyTime'] ?? Duration.zero.toString()));
      } else {
        return null;
      }
    } catch (e) {
      logger.e('Error getting specific unit $unitID: $e');
      return null;
    }
  }

  Future<List<UnitModel>?> getRevisionsForExam(
      {required String examID}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    try {
      final examDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID);

      final revisionCollectionRef = examDocRef.collection('revisions');

      final revisionQuerySnapshot =
          await revisionCollectionRef.orderBy('order', descending: false).get();

      final List<UnitModel> revisions = [];

      for (final revisionDoc in revisionQuerySnapshot.docs) {
        final unitData = revisionDoc.data() as Map<String, dynamic>;
        final unit = UnitModel(
            name: unitData['name'] ?? '',
            sessionTime: parseTime(unitData['sessionTime']),
            id: revisionDoc.id,
            order: unitData['order'] ?? 0,
            completed: unitData['completed'] ?? false,
            completionTime: parseTime(
                unitData['completionTime'] ?? Duration.zero.toString()),
            realStudyTime: parseTime(
                unitData['realStudyTime'] ?? Duration.zero.toString()));
        revisions.add(unit);
      }
      return revisions;
    } catch (e) {
      logger.e('Error getting units for exam $examID: $e');
      return null;
    }
  }

  Future<String?> addCalendarDay(Day day) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final userRef = firebaseInstance.collection('users').doc(uid);

      final customDaysRef = userRef.collection('calendarDays');

      final newDocumentRef = await customDaysRef.add({
        'weekday': day.weekday,
        'date': day.date.toString(),
        'notifiedIncompleteness': day.notifiedIncompleteness,
      });

      await newDocumentRef.update({'id': newDocumentRef.id});

      logger.i('Added calendar day: ${day.date}');

      return newDocumentRef.id;
    } catch (e) {
      logger.e('Error adding calendar day: $e');
      return '';
    }
  }

  Future<Day?> getCalendarDayByDate(DateTime date) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final userCalendarDaysCollection = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays');
      final querySnapshot = await userCalendarDaysCollection
          .where('date', isEqualTo: date.toString())
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final matchingDay = Day(
            weekday: doc['weekday'],
            id: doc['id'],
            date: DateTime.parse(doc['date'] as String),
            times: <TimeSlot>[],
            notifiedIncompleteness: doc['notifiedIncompleteness']);

        if (matchingDay != null) {
          logger.i('Got day for $date');
          return matchingDay;
        }
      }

      return null;
    } catch (e) {
      logger.e('Error getting day $date by ID: $e');
      return Day(
          weekday: date.weekday, date: date, id: date.toString(), times: []);
    }
  }

  Future<Day?> getCalendarDayByID(String id) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final day = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays')
          .doc(id)
          .get();

      if (day.exists) {
        final doc = day.data() as Map<String, dynamic>;
        return Day(
          weekday: doc['weekday'],
          id: doc['id'],
          date: DateTime.parse(doc['date'] as String),
          times: <TimeSlot>[],
          notifiedIncompleteness: doc['notifiedIncompleteness'],
        );
      } else {
        // Document does not exist
        return null;
      }
    } catch (e) {
      logger.e('Error getting calendar day by id: $e');
      return null;
    }
  }

  Future<Day> getCalendarDay(DateTime date) async {
    try {
      final Day? matchingDay = await getCalendarDayByDate(date);

      if (matchingDay != null) {
        matchingDay.times = await getTimeSlotsForCalendarDay(matchingDay.id);

        return matchingDay;
      }

      return Day(
          weekday: date.weekday, date: date, id: date.toString(), times: []);
    } catch (e) {
      logger.e('Error getting current days: $e');
      return Day(
          weekday: date.weekday, date: date, id: date.toString(), times: []);
    }
  }

  Future<DateTime?> getCalendarDayDateByDayID(String dayID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final userCalendarDaysCollection = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays');
      final querySnapshot =
          await userCalendarDaysCollection.where('id', isEqualTo: dayID).get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return DateTime.parse(doc['date']);
      }
      return null;
    } catch (e) {
      logger.e('Error getting date for day by id: $e');
      return null;
    }
  }

  Future<int> clearTimesForCalendarDay(String dayID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final dayDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays')
          .doc(dayID);

      final timeSlotCollectionRef = dayDocRef.collection('timeSlots');
      final timeSlotQuerySnapshot = await timeSlotCollectionRef.get();

      for (final timeSlotDoc in timeSlotQuerySnapshot.docs) {
        await timeSlotDoc.reference.delete();
      }

      return 1;
    } catch (e) {
      logger.e('Error clearing Times for day: $e');
      return -1;
    }
  }

  Future<int> deleteAllCalendarDays() async {
    try {
      final firebaseInstance = instanceManager.db;
      final uid = instanceManager.localStorage.getString('uid');

      final userCalendarDaysCollection = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays');

      final querySnapshot = await userCalendarDaysCollection.get();

      for (final doc in querySnapshot.docs) {
        await clearTimesForCalendarDay(doc['id']);
        await doc.reference.delete();
      }
      return 1;
    } catch (e) {
      logger.e('Error deleting calendar days: $e');
      return -1;
    }
  }

  Future<int> deleteExam({required String examId}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    try {
      if (uid == null) {
        return -1;
      }

      final userDocRef = firebaseInstance.collection('users').doc(uid);

      final examDocRef = userDocRef.collection('exams').doc(examId);
      final examDoc = await examDocRef.get();

      if (!examDoc.exists) {
        return 0;
      }

      final unitCollectionRef = examDocRef.collection('units');
      final unitQuerySnapshot = await unitCollectionRef.get();

      for (final unitDoc in unitQuerySnapshot.docs) {
        await unitDoc.reference.delete();
      }

      final revisionCollectionRef = examDocRef.collection('revisions');
      final revisionQuerySnapshot = await revisionCollectionRef.get();

      for (final revisionDoc in revisionQuerySnapshot.docs) {
        await revisionDoc.reference.delete();
      }

      await examDocRef.delete();

      return 1;
    } catch (e) {
      logger.e('Error deleting exam in FirebaseCrud: $e');
      return -1;
    }
  }

  Future<String?> addUnitToExam(
      {required UnitModel newUnit, required String examID}) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final examRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID);

      final unitData = {
        'name': newUnit.name,
        'sessionTime': newUnit.sessionTime.toString(),
        'order': newUnit.order,
        'id': '',
        'completed': newUnit.completed,
        'completionTime': newUnit.completionTime.toString(),
        'realStudyTime': newUnit.realStudyTime.toString()
      };

      final unitRef = await examRef.collection('units').add(unitData);
      await unitRef.update({'id': unitRef.id});

      return unitRef.id;
    } catch (e) {
      logger
          .e('Error in Firebase CRUD when adding unit to exam $examID: $e');
      return null;
    }
  }

  Future<String?> addRevisionToExam(
      {required UnitModel newUnit, required String examID}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    final examRef = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(examID);

    final revisionData = {
      'name': newUnit.name,
      'sessionTime': newUnit.sessionTime.toString(),
      'order': newUnit.order,
      'id': '',
      'completed': newUnit.completed,
      'completionTime': newUnit.completionTime.toString(),
      'realStudyTime': newUnit.realStudyTime.toString()
    };

    final revisionRef =
        await examRef.collection('revisions').add(revisionData);
    await revisionRef.update({'id': revisionRef.id});

    return revisionRef.id;
  }

  Future<int> clearRevisionsForExam(String examID) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid != null) {
        final examDocRef = firebaseInstance
            .collection('users')
            .doc(uid)
            .collection('exams')
            .doc(examID);

        final revisionsCollectionRef = examDocRef.collection('revisions');

        await revisionsCollectionRef.get().then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });
        logger.i('Wiped revisions!');

        return 1;
      } else {
        return -1;
      }
    } catch (e) {
      logger.e('Error deleting schedule: $e');
      return -1;
    }
  }

  Future<int> removeRevisionFromExam(int order, String examID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final revisionsCollection = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('revisions');
      final querySnapshot =
          await revisionsCollection.where('order', isEqualTo: order).get();

      await querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
      return 1;
    } catch (e) {
      logger.e('Error deleting revision $order from exam $examID: $e');
      return -1;
    }
  }

  Future<List<ExamModel>?> getAllExams() async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final QuerySnapshot querySnapshot = await instanceManager.db
          .collection('users')
          .doc(uid)
          .collection('exams')
          .get();

      final List<ExamModel> exams = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        final double weight = ((data['weight'] as double) / 10.0);

        return ExamModel(
          name: data['name'] as String,
          weight: weight,
          examDate: DateTime.parse((data['examDate'] as String)),
          timeStudied: parseTime(data['timeStudied']),
          color: data['color'] as String,
          sessionTime: parseTime(data['sessionTime']),
          id: data['id'] as String,
          orderMatters: data['orderMatters'] as bool,
        );
      }).toList();
      return exams;
    } catch (e) {
      logger.e('Error getting exams: $e');
      return null;
    }
  }

  Future<bool> deleteUnit({required UnitModel unit, required examID}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid == null) {
        return false;
      }

      final unitDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('units')
          .doc(unit.id);

      await unitDocRef.delete();

      final querySnapshot = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('units')
          .where('order', isGreaterThan: unit.order)
          .get();

      final batch = firebaseInstance.batch();
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final currentOrder = data['order'] as int;
        String newName = '';
        if (data['name'] == 'Unit $currentOrder') {
          newName = 'Unit ${currentOrder - 1}';
        } else {
          newName = data['name'];
        }

        batch.update(doc.reference, {
          'order': currentOrder - 1,
          'name': newName,
        });
      }

      await batch.commit();

      return true;
    } catch (e) {
      logger.e('Error deleting Unit: $e');
      return false;
    }
  }

  Future<int> editUnit(
      {required ExamModel exam,
      required String unitID,
      required UnitModel updatedUnit}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    final examID = exam.id;

    try {
      final unitReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('units')
          .doc(unitID);

      await unitReference.update({
        'name': updatedUnit.name,
        'sessionTime': updatedUnit.sessionTime.toString(),
        'completed': updatedUnit.completed,
        'completionTime': updatedUnit.completionTime.toString(),
        'realStudyTime': updatedUnit.realStudyTime.toString()
      });
      return 1;
    } catch (e) {
      logger.e('Error editing unit: $e');
      return -1;
    }
  }

  Future<int> clearGapsForWeekday(String weekday) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      final dayDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('timeGaps')
          .doc('timeGapsDoc');

      final timeSlotCollectionRef = dayDocRef.collection(weekday);
      final timeSlotQuerySnapshot = await timeSlotCollectionRef.get();

      for (final timeSlotDoc in timeSlotQuerySnapshot.docs) {
        await timeSlotDoc.reference.delete();
      }

      return 1;
    } catch (e) {
      logger.e('Error clearing time gaps for day $weekday: $e');
      return -1;
    }
  }

  Future<int?> addGeneralTimeSlot({required TimeSlot timeSlot}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid != null) {
        if (uid != null) {
          final userDocRef = firebaseInstance.collection('users').doc(uid);
          final weekday = weekDays[timeSlot.weekday - 1];
          final timeSlotsCollectionRef = userDocRef
              .collection('timeGaps')
              .doc('timeGapsDoc')
              .collection(weekday);

          final newGapRef = await timeSlotsCollectionRef.add({
            'startTime': timeSlot.timeOfDayToString(timeSlot.startTime),
            'endTime': timeSlot.timeOfDayToString(timeSlot.endTime),
            'examID': timeSlot.examID,
            'duration': timeSlot.duration.toString(),
          });

          await newGapRef.update({'id': newGapRef.id});

          return 1;
        } else {
          return -1;
        }
      }
      return -1;
    } catch (e) {
      logger.e('Error adding time gap: $e');
      return -1;
    }
  }

  Future<bool?> checkIfGapsExist(String uid) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final userDocRef = firebaseInstance.collection('users').doc(uid);
      final timeSlotsDocRef =
          userDocRef.collection('timeGaps').doc('timeGapsDoc');

      final timeSlotsDocSnapshot = await timeSlotsDocRef.get();

      if (!timeSlotsDocSnapshot.exists) {
        await timeSlotsDocRef.set({'createdAt': DateTime.now().toString()});
        return false;
      }
      return true;
    } catch (e) {
      logger.e('Error checking for Gaps: $e');
      return null;
    }
  }

  Future<int?> deleteNotPastCalendarDays() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid != null) {
        final userDocRef = firebaseInstance.collection('users').doc(uid);

        final timeGapsCollectionRef = userDocRef.collection('calendarDays');

        final currentDate = stripTime(DateTime.now());

        await timeGapsCollectionRef.get().then((querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            if (doc.data().containsKey('date')) {
              final dateField =
                  DateTime.parse(doc['date'] ?? DateTime.now().toString());
              final date = stripTime(dateField);

              // Compare with the current date and delete the document
              // if the date is equal to or after the current date
              if (date.isAtSameMomentAs(currentDate) ||
                  date.isAfter(currentDate)) {
                await clearTimesForCalendarDay(doc['id']);
                doc.reference.delete();
              }
            }
          });
        });

        logger.i('Deleted present and future schedule entries!');
        return 1;
      } else {
        return -1;
      }
    } catch (e) {
      logger.e('Error deleting schedule: $e');
      return -1;
    }
  }

  Future<List<List<TimeSlot>>> getGaps() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if ((await checkIfGapsExist(uid)) == false) {
        return [
          [],
          [],
          [],
          [],
          [],
          [],
          [],
        ];
      }
      ;

      List<List<TimeSlot>> gaps = [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
      ];

      final userDoc = await firebaseInstance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final timeSlotsDocRef =
            userDoc.reference.collection('timeGaps').doc('timeGapsDoc');

        for (var i = 0; i < 7; i++) {
          final weekday = weekDays[i];
          final timeGapsCollection = timeSlotsDocRef.collection(weekday);
          final timeGapsQuery = await timeGapsCollection.get();

          for (final doc in timeGapsQuery.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timeSlot = TimeSlot(
              id: doc.id,
              weekday: i + 1,
              startTime: stringToTimeOfDay24Hr(data['startTime']),
              endTime: stringToTimeOfDay24Hr(data['endTime']),
              examID: data['examID'] ?? '',
              unitID: data['unitID'] ?? '',
              examName: data['examName'] ?? '',
              unitName: data['unitName'] ?? '',
              completed: data['completed'] ?? false,
            );
            gaps[i].add(timeSlot);
          }
        }
      }

      logger.i('Got Gaps! $gaps');
      return gaps as List<List<TimeSlot>>;
    } catch (e) {
      logger.e('Error getting Gaps: $e');
      return [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
      ];
    }
  }

  Future<int?> deleteGap(TimeSlot gap) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final id = gap.id;

      if (uid == null || uid.isEmpty) {
        return -1;
      }

      logger.i('timeslot to delete: ${gap.id}, ${gap.weekday}');

      final userDocRef = firebaseInstance.collection('users').doc(uid);
      final weekday = weekDays[gap.weekday - 1];
      final timeSlotsCollectionRef = userDocRef
          .collection('timeGaps')
          .doc('timeGapsDoc')
          .collection(weekday);

      await timeSlotsCollectionRef.doc(id).delete();

      return 1;
    } catch (e) {
      logger.e('Error deleting gap: $e');
      return -1;
    }
  }

  Future<List<Day>> getCustomDays() async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final userRef = firebaseInstance.collection('users').doc(uid);
      final QuerySnapshot customDaysQuery =
          await userRef.collection('customDays').get();

      final List<Day> customDaysList = customDaysQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Day(
          weekday: data['weekday'],
          id: doc.id,
          date: DateTime.parse(data['date'] as String),
          times: <TimeSlot>[], // Empty times list
        );
      }).toList();

      return customDaysList;
    } catch (e) {
      logger.e('Error getting custom days: $e');
      return <Day>[];
    }
  }

  Future<void> editExamWeight(ExamModel exam) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    final examReference = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(exam.id);

    await examReference.update({
      'weight': exam.weight * 10,
    });
    return;
  }

  Future<int?> editExam(ExamModel exam) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    final examReference = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(exam.id);

    await examReference.update({
      'name': exam.name,
      'examDate': exam.examDate.toString(),
      'weight': exam.weight * 10,
      'sessionTime': exam.sessionTime.toString(),
      'orderMatters': exam.orderMatters,
      'revisions': exam.revisions
    });

    logger.i('editExam: updated exam');

    final examUnits = await getUnitsForExam(examID: exam.id);

    if (examUnits != null) {
      for (var unit in examUnits!) {
        final res = await editUnit(
            exam: exam,
            unitID: unit.id,
            updatedUnit: unit.copyWith(sessionTime: exam.sessionTime));

        if (res != 1) {
          return -1;
        }
      }
    }

    return 1;
  }

  Future<ExamModel?> getExam(String examID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final docSnapshot = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final double weight = ((data['weight'] as double) / 10.0);

        return ExamModel(
          name: data['name'] as String,
          weight: weight,
          examDate: DateTime.parse(data['examDate'] as String),
          timeStudied: parseTime(data['timeStudied']),
          color: data['color'] as String,
          sessionTime: parseTime(data['sessionTime']),
          id: data['id'] as String,
          orderMatters: data['orderMatters'] as bool,
        );
      } else {
        return null;
      }
    } catch (e) {
      logger.e('Error getting exam: $e');
      return null;
    }
  }

  Future<String?> addCustomDay(Day day) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final userRef = firebaseInstance.collection('users').doc(uid);

      final customDaysRef = userRef.collection('customDays');

      final newDocumentRef = await customDaysRef.add({
        'weekday': day.weekday,
        'date': day.date.toString(),
      });

      await newDocumentRef.update({'id': newDocumentRef.id});

      return newDocumentRef.id;
    } catch (e) {
      logger.e('Error adding custom day: $e');
      return null;
    }
  }

  Future<int> addTimeSlotToCustomDay(String dayID, TimeSlot timeSlot) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final dayRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('customDays')
          .doc(dayID);

      final Map<String, dynamic> timeSlotData = {
        'weekday': timeSlot.weekday,
        'startTime': timeSlot.timeOfDayToString(timeSlot.startTime),
        'endTime': timeSlot.timeOfDayToString(timeSlot.endTime),
        'duration': timeSlot.duration.toString(),
        'examID': timeSlot.examID,
        'unitID': timeSlot.unitID,
        'examName': timeSlot.examName,
        'unitName': timeSlot.unitName,
        'completed': timeSlot.completed,
        'id': '',
        'dayID': dayID,
        'date': timeSlot.date.toString(),
      };

      final timeSlotRef =
          await dayRef.collection('timeSlots').add(timeSlotData);
      await timeSlotRef.update({'id': timeSlotRef.id});

      return 1;
    } catch (e) {
      logger.e('Error adding Time Slot: $e');
      return -1;
    }
  }

  Future<int> addTimeSlotToCalendarDay(String dayID, TimeSlot timeSlot) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final dayRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays')
          .doc(dayID);

      final Map<String, dynamic> timeSlotData = {
        'weekday': timeSlot.weekday,
        'startTime': timeSlot.timeOfDayToString(timeSlot.startTime),
        'endTime': timeSlot.timeOfDayToString(timeSlot.endTime),
        'duration': timeSlot.duration.toString(),
        'examID': timeSlot.examID,
        'unitID': timeSlot.unitID,
        'examName': timeSlot.examName,
        'unitName': timeSlot.unitName,
        'completed': timeSlot.completed,
        'id': '',
        'dayID': dayID,
        'date': timeSlot.date.toString(),
        'timeStudied': timeSlot.timeStudied.toString()
      };

      final timeSlotRef =
          await dayRef.collection('timeSlots').add(timeSlotData);
      await timeSlotRef.update({'id': timeSlotRef.id});

      return 1;
    } catch (e) {
      logger.e('Error adding Time Slot: $e');
      return -1;
    }
  }

  Future<int> clearTimesForCustomDay(String dayID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final dayDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('customDays')
          .doc(dayID);

      final timeSlotCollectionRef = dayDocRef.collection('timeSlots');
      final timeSlotQuerySnapshot = await timeSlotCollectionRef.get();

      for (final timeSlotDoc in timeSlotQuerySnapshot.docs) {
        await timeSlotDoc.reference.delete();
      }

      return 1;
    } catch (e) {
      logger.e('Error clearing Times for day: $e');
      return -1;
    }
  }

  Future<int> deleteCustomDay(String dayID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      await clearTimesForCustomDay(dayID);

      final dayDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('customDays')
          .doc(dayID);

      await dayDocRef.delete();

      return 1;
    } catch (e) {
      logger.e('Error deleting Custom Day: $e');
      return -1;
    }
  }

  Future<bool> findDate(String date) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final dayQuery = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('customDays')
          .where('date', isEqualTo: date)
          .get();

      return dayQuery.docs.isNotEmpty;
    } catch (e) {
      logger.e('Error finding custom day: $e');
      return false;
    }
  }

  Future<List<TimeSlot>> getTimeSlotsForCustomDay(String dayID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final timeSlotsCollection = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('customDays')
          .doc(dayID)
          .collection('timeSlots');

      final timeSlotsQuery = await timeSlotsCollection.get();

      final List<TimeSlot> timeSlotsList =
          List<TimeSlot>.from(timeSlotsQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TimeSlot(
          id: doc.id,
          weekday: data['weekday'],
          startTime: stringToTimeOfDay24Hr(data['startTime']),
          endTime: stringToTimeOfDay24Hr(data['endTime']),
          examID: data['examID'],
          unitID: data['unitID'],
          examName: data['examName'],
          unitName: data['unitName'],
          completed: data['completed'] ?? false,
          dayID: data['dayID'] ?? '',
          date: DateTime.parse(data['date']),
        );
      }));

      return timeSlotsList;
    } catch (e) {
      logger.e('Error gettimg timeSlots for day: $e');
      return <TimeSlot>[];
    }
  }

  Future<List<TimeSlot>> getTimeSlotsForCalendarDay(String dayID) async {
    try {
      List<TimeSlot> sortTimeSlots(List<TimeSlot> timeSlots) {
        timeSlots.sort((a, b) {
          final aStartHour = a.startTime.hour;
          final aStartMinute = a.startTime.minute;
          final bStartHour = b.startTime.hour;
          final bStartMinute = b.startTime.minute;

          if (aStartHour < bStartHour) {
            return -1;
          } else if (aStartHour > bStartHour) {
            return 1;
          } else {
            if (aStartMinute < bStartMinute) {
              return -1;
            } else if (aStartMinute > bStartMinute) {
              return 1;
            } else {
              final aEndHour = a.endTime.hour;
              final aEndMinute = a.endTime.minute;
              final bEndHour = b.endTime.hour;
              final bEndMinute = b.endTime.minute;

              if (aEndHour < bEndHour) {
                return -1;
              } else if (aEndHour > bEndHour) {
                return 1;
              } else {
                if (aEndMinute < bEndMinute) {
                  return -1;
                } else if (aEndMinute > bEndMinute) {
                  return 1;
                } else {
                  return 0;
                }
              }
            }
          }
        });

        return timeSlots;
      }

      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final timeSlotsCollection = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays')
          .doc(dayID)
          .collection('timeSlots');

      final timeSlotsQuery = await timeSlotsCollection.get();

      List<TimeSlot> timeSlotsList =
          List<TimeSlot>.from(timeSlotsQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // logger.i(data['timeStudied']);
        // logger.i(parseTime(data['timeStudied'] ?? Duration.zero.toString()));
        return TimeSlot(
            id: doc.id,
            weekday: data['weekday'],
            startTime: stringToTimeOfDay24Hr(data['startTime']),
            endTime: stringToTimeOfDay24Hr(data['endTime']),
            examID: data['examID'],
            unitID: data['unitID'],
            examName: data['examName'],
            unitName: data['unitName'],
            completed: data['completed'] ?? false,
            dayID: data['dayID'] ?? '',
            date: DateTime.parse(data['date']),
            timeStudied:
                parseTime(data['timeStudied'] ?? Duration.zero.toString()));
      }));

      timeSlotsList = sortTimeSlots(timeSlotsList);

      return timeSlotsList;
    } catch (e) {
      logger.e('Error gettimg timeSlots for day: $e');
      return <TimeSlot>[];
    }
  }

  Future<int> markUnitAsComplete(String examID, String unitID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final unitReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('units')
          .doc(unitID);

      final unitSnapshot = await unitReference.get();

      if (unitSnapshot.exists) {
        await unitReference.update({'completed': true});
      } else {
        final revisionReference = firebaseInstance
            .collection('users')
            .doc(uid)
            .collection('exams')
            .doc(examID)
            .collection('revisions')
            .doc(unitID);

        final revisionSnapshot = await revisionReference.get();

        if (revisionSnapshot.exists) {
          await revisionReference.update({'completed': true});
        } else {
          return -1;
        }
      }

      return 1;
    } catch (e) {
      logger.e('Error marking Unit as complete: $e');
      return -1;
    }
  }

  Future<int> markCalendarTimeSlotAsComplete(
      String dayID, String timeSlotID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final timeSlotReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays')
          .doc(dayID)
          .collection('timeSlots')
          .doc(timeSlotID);

      await timeSlotReference.update({'completed': true});
      return 1;
    } catch (e) {
      logger.e(
          'Error marking calendar timeSlot as complete: $e\n dayID: $dayID, timeSlotID: $timeSlotID');
      return -1;
    }
  }

  Future<int> markUnitAsIncomplete(String examID, String unitID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final unitReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('units')
          .doc(unitID);

      final unitSnapshot = await unitReference.get();

      if (unitSnapshot.exists) {
        await unitReference.update({'completed': false});
      } else {
        final revisionReference = firebaseInstance
            .collection('users')
            .doc(uid)
            .collection('exams')
            .doc(examID)
            .collection('revisions')
            .doc(unitID);

        final revisionSnapshot = await revisionReference.get();

        if (revisionSnapshot.exists) {
          await revisionReference.update({'completed': false});
        } else {
          return -1;
        }
      }
      logger.i('Changed unit to incomplete!');
      return 1;
    } catch (e) {
      logger.e('Error marking Unit as completed: $e');
      return -1;
    }
  }

  Future<int> markCalendarTimeSlotAsIncomplete(
      String dayID, String timeSlotID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final timeSlotReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays')
          .doc(dayID)
          .collection('timeSlots')
          .doc(timeSlotID);

      await timeSlotReference.update({'completed': false});
      return 1;
    } catch (e) {
      logger.e('Error marking timeSlot as complete: $e');
      return -1;
    }
  }

  Future<void> markCalendarDayAsNotified(String dayID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final dayRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays')
          .doc(dayID);

      await dayRef.update({'notifiedIncompleteness': true});
    } catch (e) {
      logger.e('FirebaseCrud Error in marking day as notified: $e');
    }
  }

  Future<void> updateTimeStudiedForTimeSlot(
      String slotID, String dayID, Duration timeStudied) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final timeSlotRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('calendarDays')
          .doc(dayID)
          .collection('timeSlots')
          .doc(slotID);

      await timeSlotRef.update({'timeStudied': timeStudied.toString()});
    } catch (e) {
      logger.e('Error in Firebase CRUD - saveTimeStudiedForTimeSlot: $e');
    }
  }
}
