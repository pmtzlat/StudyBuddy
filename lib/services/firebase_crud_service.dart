import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/common_widgets/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';

import '../models/course_model.dart';
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
  Future<String?> addCourseToUser({required CourseModel newCourse}) async {
    try {
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
        final coursesCollectionRef = userDocRef.collection('courses');

        final newCourseDocRef = await coursesCollectionRef.add({
          'name': newCourse.name,
          'weight': newCourse.weight * 10,
          'examDate': newCourse.examDate.toString(),
          'sessionTime': newCourse.sessionTime,
          'secondsStudied': newCourse.secondsStudied,
          'color': newCourse.color,
          'id': '',
          'orderMatters': newCourse.orderMatters,
          'revisions': newCourse.revisions,
        });

        await newCourseDocRef.update({'id': newCourseDocRef.id});

        return newCourseDocRef.id as String;
      } else {
        logger.e('User document with UID $uid does not exist.');
        return null;
      }
    } catch (e) {
      logger.e('Error adding course to firebase: $e');
      return null;
    }
  }

  Future<List<UnitModel>?> getUnitsForCourse({required String courseID}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    try {
      final courseDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseID);

      final unitCollectionRef = courseDocRef.collection('units');

      final unitQuerySnapshot =
          await unitCollectionRef.orderBy('order', descending: false).get();

      final List<UnitModel> units = [];

      for (final unitDoc in unitQuerySnapshot.docs) {
        final unitData = unitDoc.data() as Map<String, dynamic>;
        final unit = UnitModel(
          name: unitData['name'] ?? '',
          hours: unitData['hours'] ?? 3600,
          id: unitDoc.id,
          order: unitData['order'] ?? 0,
        );
        units.add(unit);
      }
      return units;
    } catch (e) {
      logger.e('Error getting units for course $courseID: $e');
      return null;
    }
  }

  Future<int> deleteCourse({required String courseId}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    try {
      if (uid == null) {
        return -1;
      }

      final userDocRef = firebaseInstance.collection('users').doc(uid);

      final courseDocRef = userDocRef.collection('courses').doc(courseId);
      final courseDoc = await courseDocRef.get();

      if (!courseDoc.exists) {
        return 0;
      }

      final unitCollectionRef = courseDocRef.collection('units');
      final unitQuerySnapshot = await unitCollectionRef.get();

      for (final unitDoc in unitQuerySnapshot.docs) {
        await unitDoc.reference.delete();
      }

      await courseDocRef.delete();

      return 1;
    } catch (e) {
      logger.e('Error deleting course in FirebaseCrud: $e');
      return -1;
    }
  }

  Future<String?> addUnitToCourse(
      {required UnitModel newUnit, required String courseID}) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;

      final courseRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseID);

      final unitData = {
        'name': newUnit.name,
        'hours': newUnit.hours,
        'order': newUnit.order,
        'id': ''
      };

      final unitRef = await courseRef.collection('units').add(unitData);
      await unitRef.update({'id': unitRef.id});

      return unitRef.id;
    } catch (e) {
      logger
          .e('Error in Firebase CRUD when adding unit to course $courseID: $e');
      return null;
    }
  }

  Future<List<CourseModel>?> getAllCourses() async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final QuerySnapshot querySnapshot = await instanceManager.db
          .collection('users')
          .doc(uid)
          .collection('courses')
          .get();

      final List<CourseModel> courses = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        final double weight = ((data['weight'] as double) / 10.0);

        return CourseModel(
          name: data['name'] as String,
          weight: weight,
          examDate: DateTime.parse((data['examDate'] as String)),
          secondsStudied: data['secondsStudied'] as int,
          color: data['color'] as String,
          sessionTime: data['sessionTime'] as int,
          id: data['id'] as String,
          revisions: data['revisions'] as int,
          orderMatters: data['orderMatters'] as bool,
        );
      }).toList();
      return courses;
    } catch (e) {
      logger.e('Error getting courses: $e');
      return null;
    }
  }

  Future<bool> deleteUnit({required UnitModel unit, required courseID}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid == null) {
        return false;
      }

      final unitDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseID)
          .collection('units')
          .doc(unit.id);

      await unitDocRef.delete();

      final querySnapshot = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseID)
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

  Future<int?> editUnit(
      {required CourseModel course,
      required String unitID,
      required UnitModel updatedUnit}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    final courseID = course.id;

    try {
      final unitReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseID)
          .collection('units')
          .doc(unitID);

      await unitReference.update({
        'name': updatedUnit.name,
        'hours': updatedUnit.hours,
      });

      return 1; // Success
    } catch (e) {
      logger.e('Error editing unit: $e');
      return -1;
    }
  }

  Future<int> clearRestrictionsForWeekday(String weekday) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      final dayDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('timeRestraints')
          .doc('timeRestraintsDoc');

      final timeSlotCollectionRef = dayDocRef.collection(weekday);
      final timeSlotQuerySnapshot = await timeSlotCollectionRef.get();

      for (final timeSlotDoc in timeSlotQuerySnapshot.docs) {
        await timeSlotDoc.reference.delete();
      }

      return 1;
    } catch (e) {
      logger.e('Error clearing time restraints for day $weekday: $e');
      return -1;
    }
  }

  Future<int?> addTimeRestraint({required TimeSlot timeSlot}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid != null) {
        if (uid != null) {
          

          final userDocRef = firebaseInstance.collection('users').doc(uid);
          final weekday = weekDays[timeSlot.weekday - 1];
          final timeSlotsCollectionRef = userDocRef
              .collection('timeRestraints')
              .doc('timeRestraintsDoc')
              .collection(weekday);

          final newRestraintRef = await timeSlotsCollectionRef.add({
            'startTime': timeSlot.timeOfDayToString(timeSlot.startTime),
            'endTime': timeSlot.timeOfDayToString(timeSlot.endTime),
            'courseID': timeSlot.courseID,
          });

          await newRestraintRef.update({'id': newRestraintRef.id});

          return 1;
        } else {
          return -1;
        }
      }
      return -1;
    } catch (e) {
      logger.e('Error adding time restraint: $e');
      return -1;
    }
  }

  Future<bool?> checkIfRestraintsExist(String uid) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final userDocRef = firebaseInstance.collection('users').doc(uid);
      final timeSlotsDocRef =
          userDocRef.collection('timeRestraints').doc('timeRestraintsDoc');

      final timeSlotsDocSnapshot = await timeSlotsDocRef.get();

      if (!timeSlotsDocSnapshot.exists) {
        await timeSlotsDocRef.set({'createdAt': DateTime.now().toString()});
        return false;
      }
      return true;
    } catch (e) {
      logger.e('Error checking for Restraints: $e');
      return null;
    }
  }

  /*Future<int?> deleteRestraints() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid != null) {
        final userDocRef = firebaseInstance.collection('users').doc(uid);

        final timeRestrictionsCollectionRef =
            userDocRef.collection('timeRestraints');

        await timeRestrictionsCollectionRef.get().then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });
        logger.i('Wiped time Restraints!');

        return 1;
      } else {
        return -1;
      }
    } catch (e) {
      logger.e('Error deleting restrictions: $e');
      return -1;
    }
  }*/

  Future<int?> deleteSchedule() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid != null) {
        final userDocRef = firebaseInstance.collection('users').doc(uid);

        final timeRestrictionsCollectionRef = userDocRef.collection('schedule');

        await timeRestrictionsCollectionRef.get().then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });
        logger.i('Wiped schedule!');

        return 1;
      } else {
        return -1;
      }
    } catch (e) {
      logger.e('Error deleting schedule: $e');
      return -1;
    }
  }

  /*Future<int?> checkRestraints() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;
    try {
      if (uid != null) {
        final userDocRef = firebaseInstance.collection('users').doc(uid);

        final timeRestraintsCollectionRef =
            userDocRef.collection('timeRestraints');
        final querySnapshot = await timeRestraintsCollectionRef.get();

        if (querySnapshot.docs.isEmpty) {
          return null;
        } else {
          return 1;
        }
      } else {
        return -1;
      }
    } catch (e) {
      logger.e('Error checking restraints: $e');
      return -1;
    }
  }*/

  Future<List<List<TimeSlot>>?> getRestraints() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if ((await checkIfRestraintsExist(uid)) == false) {
        logger.d('returning null...');
        return null;
      }
      ;

      List<List<TimeSlot>> restrictions = [
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
        final timeSlotsDocRef = userDoc.reference
            .collection('timeRestraints')
            .doc('timeRestraintsDoc');

        

        for (var i = 0; i < 7; i++) {
          final weekday = weekDays[i];
          final timeRestraintsCollection = timeSlotsDocRef.collection(weekday);
          final timeRestraintsQuery = await timeRestraintsCollection.get();

          for (final doc in timeRestraintsQuery.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timeSlot = TimeSlot(
              id: doc.id,
              weekday: i + 1,
              startTime: stringToTimeOfDay24Hr(data['startTime']),
              endTime: stringToTimeOfDay24Hr(data['endTime']),
              courseID: data['courseID'],
              unitID: data['unitID'],
              courseName: data['courseName'],
              unitName: data['unitName'],
            );
            restrictions[i].add(timeSlot);
          }
        }
      }

      logger.i('Got restraints! $restrictions');
      return restrictions as List<List<TimeSlot>>?;
    } catch (e) {
      logger.e('Error getting Restrictions: $e');
      return null;
    }
  }

  Future<int?> deleteRestraint(TimeSlot restraint) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final id = restraint.id;

      if (uid == null || uid.isEmpty) {
        return -1;
      }

      logger.i('timeslot to delete: ${restraint.id}, ${restraint.weekday}');

      final userDocRef = firebaseInstance.collection('users').doc(uid);
      final weekday = weekDays[restraint.weekday - 1];
      final timeSlotsCollectionRef = userDocRef
          .collection('timeRestraints')
          .doc('timeRestraintsDoc')
          .collection(weekday);

      await timeSlotsCollectionRef.doc(id).delete();

      return 1;
    } catch (e) {
      logger.e('Error deleting restraint: $e');
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

  /*Future<List<TimeSlot>?> getScheduleLimits() async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid != null) {
        final userDocRef = firebaseInstance.collection('users').doc(uid);
        final timeLimitsCollectionRef = userDocRef.collection('timeRestraints');

        final querySnapshot = await timeLimitsCollectionRef.get();

        List<TimeSlot> timeSlotList = querySnapshot.docs.map<TimeSlot>((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TimeSlot(
            weekday: data['weekday'],
            startTime: data['startTime'],
            endTime: data['endTime'],
            courseID: data['courseID'],
            unitID: data['unitID'],
          );
        }).toList();

        return timeSlotList;
      } else {
        return null;
      }
    } catch (e) {
      logger.e(
          'firebaseCrud.getScheduleLimits: error getting schedule limits: $e');
      return null;
    }
  }*/

  Future<int?> editCourse(CourseModel course) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final courseReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(course.id);

      await courseReference.update({
        'name': course.name,
        'examDate': course.examDate.toString(),
        'weight': course.weight * 10,
        'sessionTime': course.sessionTime,
        'orderMatters': course.orderMatters,
        'revisions': course.revisions
      });

      return 1;
    } catch (e) {
      logger.e('Error updating course: $e');
      return -1;
    }
  }

  Future<CourseModel?> getCourse(String courseID) async {
    try {
      final uid = instanceManager.localStorage.getString('uid');
      final firebaseInstance = instanceManager.db;
      final docSnapshot = await firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseID)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final double weight = ((data['weight'] as double) / 10.0);

        return CourseModel(
          name: data['name'] as String,
          weight: weight,
          examDate: DateTime.parse(data['examDate'] as String),
          secondsStudied: data['secondsStudied'] as int,
          color: data['color'] as String,
          sessionTime: data['sessionTime'] as int,
          id: data['id'] as String,
          revisions: data['revisions'] as int,
          orderMatters: data['orderMatters'] as bool,
        );
      } else {
        return null;
      }
    } catch (e) {
      logger.e('Error getting course: $e');
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
        'courseID': timeSlot.courseID,
        'unitID': timeSlot.unitID,
        'courseName': timeSlot.courseName,
        'unitName': timeSlot.unitName,
        'id': ''
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

  Future<int> clearTimesForDay(String dayID) async {
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

      clearTimesForDay(dayID);

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

  Future<List<TimeSlot>> getTimeSlotsForDay(String dayID) async {
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
          courseID: data['courseID'],
          unitID: data['unitID'],
          courseName: data['courseName'],
          unitName: data['unitName'],
        );
      }));

      return timeSlotsList;
    } catch (e) {
      logger.e('Error gettimg timeSlots for day: $e');
      return <TimeSlot>[];
    }
  }
}
