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
import 'package:study_buddy/utils/general_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  //Exam Operations

  Future<String?> addExam({required ExamModel newExam}) async {
    // Check if the user document exists
    
    final uid = instanceManager.localStorage.getString('uid');

    final userDocRef = instanceManager.db.collection('users').doc(uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      final examsCollectionRef = userDocRef.collection('exams');

      final newExamDocRef = await examsCollectionRef.add({
        'name': newExam.name,
        'weight': newExam.weight * 10,
        'examDate': newExam.examDate.toString(),
        'revisionTime': newExam.revisionTime.toString(),
        'unitTime': newExam.unitTime.toString(),
        'color': newExam.color.toHex(),
        'id': '',
        'orderMatters': newExam.orderMatters,
        'revisionInDayBeforeExam': newExam.revisionInDayBeforeExam,
        'sessionSplittable': newExam.sessionsSplittable,
      });

      await newExamDocRef.update({'id': newExamDocRef.id});
      logger.i("Added exam ${newExamDocRef.id as String}");

      return newExamDocRef.id as String;
    } else {
      logger.e('User document with UID $uid does not exist.');
      return null;
    }
  }

  Future<int> deleteExam({required String examId}) async {
    logger.i('Deleting exam $examId ...');
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
      rethrow;
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
            unitTime: parseTime(data['unitTime']),
            color: HexColor.fromHex(data['color']),
            revisionTime: parseTime(data['revisionTime']),
            id: data['id'] as String,
            orderMatters: data['orderMatters'] as bool,
            revisionInDayBeforeExam: data['revisionInDayBeforeExam'] as bool,
            sessionsSplittable: data['sessionSplittable'] as bool);
      }).toList();

      for (ExamModel exam in exams) {
        exam.units = await getUnitsForExam(examID: exam.id) ?? <UnitModel>[];
        exam.revisions =
            await getRevisionsForExam(examID: exam.id) ?? <UnitModel>[];
      }
      return exams;
    } catch (e) {
      logger.e('Error getting exams: $e');
      return null;
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

  Future<int?> editExam(String examID, ExamModel newExam) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    final examReference = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(examID);

    await examReference.update({
      'name': newExam.name,
      'examDate': newExam.examDate.toString(),
      'weight': newExam.weight * 10,
      'revisionTime': newExam.revisionTime.toString(),
      'unitTime': newExam.unitTime.toString(),
      'orderMatters': newExam.orderMatters,
      'revisionInDayBeforeExam': newExam.revisionInDayBeforeExam,
      'color': newExam.color.toHex(),
      'sessionSplittable': newExam.sessionsSplittable,
    });

    logger.i('editExam: updated exam');

    return 1;
  }

  Future<ExamModel?> getExam(String examID) async {
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

      var exam = ExamModel(
          name: data['name'] as String,
          weight: weight,
          examDate: DateTime.parse(data['examDate'] as String),
          unitTime: parseTime(data['unitTime']),
          color: HexColor.fromHex(data['color']),
          revisionTime: parseTime(data['revisionTime']),
          id: data['id'] as String,
          orderMatters: data['orderMatters'] as bool,
          revisionInDayBeforeExam: data['revisionInDayBeforeExam'] as bool,
          sessionsSplittable: data['sessionSplittable'] as bool);

      exam.units = await getUnitsForExam(examID: exam.id) ?? <UnitModel>[];
      exam.revisions =
          await getRevisionsForExam(examID: exam.id) ?? <UnitModel>[];
      return exam;
    } else {
      logger.w('Exam $examID not found!');
      return null;
    }
  }

  Future<dynamic> getExamColor(String examID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final reference = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID);

      // Get the document snapshot
      final DocumentSnapshot snapshot = await reference.get();

      // Check if the document exists
      if (snapshot.exists) {
        // Cast data to Map<String, dynamic> and access the 'color' field
        final color = (snapshot.data() as Map<String, dynamic>)['color'];

        // Return the color
        return color;
      } else {
        // Handle the case when the document does not exist
        logger.w('Document with ID $examID does not exist.');
        return null; // or throw an exception if needed
      }
    } catch (e) {
      logger.e('Error fetching color for exam $examID : $e');
      return null; // or throw an exception if needed
    }
  }

  Future<void> clearUnitsForExam(String examID) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    final dayDocRef = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(examID);

    final unitCollectionRef = dayDocRef.collection('units');
    final unitQuerySnapshot = await unitCollectionRef.get();

    for (final unitDoc in unitQuerySnapshot.docs) {
      await unitDoc.reference.delete();
    }
  }




  //Unit Operations

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
            totalSessions: unitData['totalSessions'] ?? 0,
            completedSessions: unitData['completedSessions'] ?? 0,
            examID: unitData['examID'] ?? '',
            completed: unitData['completed'] ?? false);
        units.add(unit);
      }
      return units;
    } catch (e) {
      logger.e('Error getting units for exam $examID: $e');
      return null;
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
            totalSessions: unitData['totalSessions'] ?? 0,
            completedSessions: unitData['completedSessions'] ?? 0,
            examID: unitData['examID'],
            completed: unitData['completed'] ?? false);
      } else {
        return null;
      }
    } catch (e) {
      logger.e('Error getting specific unit $unitID: $e');
      rethrow;
    }
  }

  Future<String?> addUnitToExam(
      {required UnitModel newUnit, required String examID}) async {
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
      'totalSessions': newUnit.totalSessions,
      'completedSessions': newUnit.completedSessions,
      'examID': examID,
    };

    final unitRef = await examRef.collection('units').add(unitData);
    await unitRef.update({'id': unitRef.id});

    return unitRef.id;
  }

  Future<bool> deleteUnit(
      {required UnitModel unit,
      required examID,
      required BuildContext context}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    final _localizations = AppLocalizations.of(context)!;

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
        if (data['name'] == ' ${_localizations.unit} $currentOrder') {
          newName = ' ${_localizations.unit} ${currentOrder - 1}';
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

  Future<int> changeUnitCompleteness(
      String examID, String unitID, bool value) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      var unitReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('units')
          .doc(unitID);

      final unitSnapshot = await unitReference.get();

      if (!unitSnapshot.exists) {
        unitReference = firebaseInstance
            .collection('users')
            .doc(uid)
            .collection('exams')
            .doc(examID)
            .collection('revisions')
            .doc(unitID);

        final revisionSnapshot = await unitReference.get();

        if (!revisionSnapshot.exists) {
          return -1;
        }
      }
      await unitReference.update({'completed': value});

      return 1;
    } catch (e) {
      logger.e('Error marking Unit as complete: $e');
      return -1;
    }
  }

  Future<int> changeUnitCompletedSessions(
      String examID, String unitID, int value) async {
    try {
     
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      var unitReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('units')
          .doc(unitID);

      final unitSnapshot = await unitReference.get();

      if (!unitSnapshot.exists) {
        unitReference = firebaseInstance
            .collection('users')
            .doc(uid)
            .collection('exams')
            .doc(examID)
            .collection('revisions')
            .doc(unitID);

        final revisionSnapshot = await unitReference.get();

        if (!revisionSnapshot.exists) {
          logger.i('Revision $examID: $unitID not found');
          return -1;
        }
      }
      logger.i('Changing unit completed sessions: $examID: $unitID - $value');

      await unitReference.update({'completedSessions': value});

      return 1;
    } catch (e) {
      logger.e('Error marking Unit as complete: $e');
      rethrow;
    }
  }

  Future<void> updateUnitSessionCompletionInfo(
      String examID, String unitID, int totalSessions) async {
        
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    var unitReference = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(examID)
        .collection('units')
        .doc(unitID);

    final unitSnapshot = await unitReference.get();

    if (unitSnapshot.exists) {
    } else {
      unitReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(examID)
          .collection('revisions')
          .doc(unitID);
    }
    await unitReference.update({'totalSessions': totalSessions});
    await unitReference.update({'completedSessions': 0});
    await unitReference.update({'completed': false});

    logger.i('Exam: $examID, Unit: $unitID - totalSessions: $totalSessions');
  }



  //Revision operations

  Future<List<UnitModel>?> getRevisionsForExam({required String examID}) async {
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
            totalSessions: unitData['totalSessions'] ?? 0,
            completedSessions: unitData['completedSessions'] ?? 0,
            examID: unitData['examID'] ?? '',
            completed: unitData['completed'] ?? false);
        revisions.add(unit);
      }
      return revisions;
    } catch (e) {
      logger.e('Error getting units for exam $examID: $e');
      return null;
    }
  }

  Future<String?> addRevisionToExam(
      {required String examID, required UnitModel newRevision}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    final examRef = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(examID);

    final revisionData = {
      'name': newRevision.name,
      'sessionTime': newRevision.sessionTime.toString(),
      'order': newRevision.order,
      'id': '',
      'completed': newRevision.completed,
      'totalSessions': newRevision.totalSessions,
      'completedSessions': newRevision.completedSessions,
      'examID': examID
    };

    final revisionRef = await examRef.collection('revisions').add(revisionData);
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




  //Calendar Operations

  Future<String?> addCalendarDay(DayModel day) async {
    try {
      
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final userRef = firebaseInstance.collection('users').doc(uid);

      final calendarDaysRef = userRef.collection('calendarDays');

      final newDocumentRef = await calendarDaysRef.add({
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

  Future<DayModel?> getCalendarDayByDate(DateTime date) async {
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
        final matchingDay = DayModel(
            weekday: doc['weekday'],
            id: doc['id'],
            date: DateTime.parse(doc['date'] as String),
            times: <TimeSlotModel>[],
            notifiedIncompleteness: doc['notifiedIncompleteness']);

        if (matchingDay != null) {
          logger.i('Got day for $date');
          return matchingDay;
        }
      }

      return null;
    } catch (e) {
      logger.e('Error getting day $date by ID: $e');
      return DayModel(
          weekday: date.weekday, date: date, id: date.toString(), times: []);
    }
  }

  Future<DayModel?> getCalendarDayByID(String id) async {
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
        return DayModel(
          weekday: doc['weekday'],
          id: doc['id'],
          date: DateTime.parse(doc['date'] as String),
          times: <TimeSlotModel>[],
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

  Future<DayModel> getCalendarDay(DateTime date) async {
    try {
      final DayModel? matchingDay = await getCalendarDayByDate(date);

      if (matchingDay != null) {
        matchingDay.timeSlots =
            await getTimeSlotsForCalendarDay(matchingDay.id);

        return matchingDay;
      }

      return DayModel(
          weekday: date.weekday, date: date, id: date.toString(), times: []);
    } catch (e) {
      logger.e('Error getting current days: $e');
      return DayModel(
          weekday: date.weekday, date: date, id: date.toString(), times: []);
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
      final timeSlotQuerySnapshot = await timeSlotCollectionRef.get().then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });

      return 1;
    } catch (e) {
      logger.e('Error clearing Times for day: $e');
      return -1;
    }
  }

  Future<int?> deleteNotPastCalendarDays() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
     
      if (uid != null) {
        final userDocRef = firebaseInstance.collection('users').doc(uid);

        final timeGapsCollectionRef = userDocRef.collection('calendarDays');

        final selectedDate = stripTime(DateTime.now());

        await timeGapsCollectionRef.get().then((querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            if (doc.data().containsKey('date')) {
              final dateField =
                  DateTime.parse(doc['date'] ?? DateTime.now().toString());
              final date = stripTime(dateField);

              // Compare with the current date and delete the document
              // if the date is equal to or after the current date
              if (date.isAtSameMomentAs(selectedDate) ||
                  date.isAfter(selectedDate)) {
                logger.i('Deleting calendar day : ${date} (with id: ${doc['id']}because it\'s after ${selectedDate}...');
                await clearTimesForCalendarDay(doc['id']);
                await doc.reference.delete();
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

  Future<int> addTimeSlotToCalendarDay(
      String dayID, TimeSlotModel timeSlot) async {
    try {
      
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final color = await getExamColor(timeSlot.examID);

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
        'timeStudied': timeSlot.timeStudied.toString(),
        'examColor': color
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

  Future<List<TimeSlotModel>> getTimeSlotsForCalendarDay(String dayID) async {
    try {
      List<TimeSlotModel> sortTimeSlots(List<TimeSlotModel> timeSlots) {
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

      List<TimeSlotModel> timeSlotsList =
          List<TimeSlotModel>.from(timeSlotsQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // logger.i(data['timeStudied']);
        // logger.i(parseTime(data['timeStudied'] ?? Duration.zero.toString()));
        return TimeSlotModel(
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
            examColor: HexColor.fromHex(data['examColor']),
            timeStudied:
                parseTime(data['timeStudied'] ?? Duration.zero.toString()));
      }));

      timeSlotsList = sortTimeSlots(timeSlotsList);

      return timeSlotsList;
    } catch (e) {
      logger.e('Error gettimg timeSlots for day: $e');
      return <TimeSlotModel>[];
    }
  }

  Future<int> changeTimeSlotCompleteness(
      String dayID, String timeSlotID, bool newValue) async {
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

      await timeSlotReference.update({'completed': newValue});
      return 1;
    } catch (e) {
      logger.e(
          'Error marking calendar timeSlot as complete: $e\n dayID: $dayID, timeSlotID: $timeSlotID');
      rethrow;
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

  Future<TimeSlotModel?> getTimeSlot(String timeSlotID, String dayID) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    final docSnapshot = await firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('calendarDays')
        .doc(dayID)
        .collection('timeSlots')
        .doc(timeSlotID)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;

      return TimeSlotModel(
          id: data['id'],
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
          examColor: HexColor.fromHex(data['examColor']),
          timeStudied:
              parseTime(data['timeStudied'] ?? Duration.zero.toString()));
    } else {
      logger.w('TimeSlot $timeSlotID not found in calendar day $dayID');
      return null;
    }
  }

  Future<Map<DateTime, int>> getAllCalendarDaySessionsNumbers() async {
    Map<DateTime, int> resultMap = {};

    try {
      final uid = instanceManager.localStorage.getString('uid');
      // Reference to the users collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Reference to the user's document
      DocumentReference userDocument = usersCollection.doc(uid);

      // Query calendarDays subcollection
      QuerySnapshot calendarDaysSnapshot =
          await userDocument.collection('calendarDays').get();
      
      logger.w('calendarDaySnapshots = ${calendarDaysSnapshot.size}');

      for (QueryDocumentSnapshot calendarDayDoc in calendarDaysSnapshot.docs) {
        // Extract date from calendarDay document
        String date = calendarDayDoc['date'];

        // Reference to the timeSlots subcollection within the current calendarDay
        CollectionReference timeSlotsCollection =
            calendarDayDoc.reference.collection('timeSlots');

        // Query timeSlots subcollection
        QuerySnapshot timeSlotsSnapshot = await timeSlotsCollection.get();

        // Get the number of timeSlots and add to the resultMap
        int numberOfTimeSlots = timeSlotsSnapshot.size;
        resultMap[DateTime.parse(date)] = numberOfTimeSlots;
      }
    } catch (e) {
      logger.e('Error getting Calendar days sessions: $e');
    }

    return resultMap;
  }



  //General Gaps Operations

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
      rethrow;
    }
  }

  Future<int?> addTimeSlotGap({required TimeSlotModel timeSlot}) async {
    
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
      rethrow;
    }
  }

  Future<List<List<TimeSlotModel>>> getGaps() async {
    List<List<TimeSlotModel>> gaps = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
    ];
    try {
      
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      if ((await checkIfGapsExist(uid)) == false) {
        return gaps;
      }

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
            final timeSlot = TimeSlotModel(
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

      for (List<TimeSlotModel> timeSlots in gaps) {
        timeSlots.sort((a, b) {
          if (a.startTime.hour != b.startTime.hour) {
            return b.startTime.hour - a.startTime.hour;
          } else {
            return b.startTime.minute - a.startTime.minute;
          }
        });
      }

      logger.i('Got Gaps! $gaps');
      return gaps as List<List<TimeSlotModel>>;
    } catch (e) {
      logger.e('Error getting Gaps: $e');
      return gaps;
    }
  }

  Future<int?> deleteGap(TimeSlotModel gap) async {
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

      
    } catch (e) {
      logger.e('Error deleting gap: $e');
      rethrow;
    }
  }

  Future<List<TimeSlotModel>> getGapsForDay(int day) async {
   
    
    List<TimeSlotModel> gaps = [];
    day--;

      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final userDoc = await firebaseInstance.collection('users').doc(uid).get();

      final timeSlotsDocRef =
          userDoc.reference.collection('timeGaps').doc('timeGapsDoc');

      final weekday = weekDays[day];
      final timeGapsCollection = timeSlotsDocRef.collection(weekday);
      final timeGapsQuery = await timeGapsCollection.get();

      for (final doc in timeGapsQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timeSlot = TimeSlotModel(
          id: doc.id,
          weekday: day + 1,
          startTime: stringToTimeOfDay24Hr(data['startTime']),
          endTime: stringToTimeOfDay24Hr(data['endTime']),
          examID: data['examID'] ?? '',
          unitID: data['unitID'] ?? '',
          examName: data['examName'] ?? '',
          unitName: data['unitName'] ?? '',
          completed: data['completed'] ?? false,
        );
        gaps.add(timeSlot);
      }
      
      return gaps;
    
  }



  //Custom Days Operations

  Future<List<DayModel>> getCustomDays() async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final userRef = firebaseInstance.collection('users').doc(uid);
      final QuerySnapshot customDaysQuery =
          await userRef.collection('customDays').get();

      final List<DayModel> customDaysList = customDaysQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DayModel(
          weekday: data['weekday'],
          id: doc.id,
          date: DateTime.parse(data['date'] as String),
          times: <TimeSlotModel>[], // Empty times list
        );
      }).toList();

      return customDaysList;
    } catch (e) {
      logger.e('Error getting custom days: $e');
      return <DayModel>[];
    }
  }

  Future<String?> addCustomDay(DayModel day) async {
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
      rethrow;
    }
  }

  Future<int> addTimeSlotToCustomDay(
      String dayID, TimeSlotModel timeSlot) async {
    try {
      
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      Color color = await getExamColor(timeSlot.examID) ?? Colors.blue;
      logger.i(timeSlot.date);

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
        'examColor': color.toHex()
      };

      final timeSlotRef =
          await dayRef.collection('timeSlots').add(timeSlotData);
      await timeSlotRef.update({'id': timeSlotRef.id});

      return 1;
    } catch (e) {
      logger.e('Error adding Time Slot: $e');
      rethrow;
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
      rethrow;
    }
  }

  Future<int> deleteCustomDay(String dayID) async {
    try {
      
       

      logger.i('deleting...');
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
      rethrow;
    }
  }

  Future<bool> findCustomDayWithDate(String date) async {
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

  Future<List<TimeSlotModel>> getTimeSlotsForCustomDay(String dayID) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    final timeSlotsCollection = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('customDays')
        .doc(dayID)
        .collection('timeSlots');

    final timeSlotsQuery = await timeSlotsCollection.get();

    final List<TimeSlotModel> timeSlotsList =
        List<TimeSlotModel>.from(timeSlotsQuery.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return TimeSlotModel(
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
        examColor: HexColor.fromHex(data['examColor']),
      );
    }));

    return timeSlotsList;
  }

  Future<bool> checkIfCustomDayExists(DateTime date) async {
    

    
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    final userRef = firebaseInstance.collection('users').doc(uid);

    final customDaysRef = userRef.collection('customDays');
    //logger.i(date);

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await customDaysRef.where('date', isEqualTo: date.toString()).get();

    if (snapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //Recalc Operations

  Future<bool> getNeedsRecalc() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    final userDoc = await firebaseInstance.collection('users').doc(uid).get();

    return userDoc['calendarNeedsRecalc'] ?? false;
  }

  Future<void> setNeedsRecalc(bool value) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    final userDoc = firebaseInstance.collection('users').doc(uid);

    await userDoc.update({
      'calendarNeedsRecalc': value,
    });
  }
}
