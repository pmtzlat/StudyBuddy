import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/time_slot_model.dart';
import 'package:study_buddy/models/unit_model.dart';

import '../models/course_model.dart';
import '../models/user_model.dart';
import 'logging_service.dart';

class FirebaseCrudService {
  Future<String?> addCourseToUser(
      {required String uid, required CourseModel newCourse}) async {
    try {
      // Check if the user document exists
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

      // Delete all unit documents in the "units" subcollection
      final unitCollectionRef = courseDocRef.collection('units');
      final unitQuerySnapshot = await unitCollectionRef.get();

      for (final unitDoc in unitQuerySnapshot.docs) {
        await unitDoc.reference.delete();
      }

      // Finally, delete the course document itself
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

  Future<List<CourseModel>?> getAllCourses({required String uid}) async {
    try {
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

  Future<int?> addTimeRestraint({required TimeSlot timeSlot}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid != null) {
        final userDocRef = firebaseInstance.collection('users').doc(uid);

        final timeSlotsCollectionRef = userDocRef.collection('timeRestraints');

        await timeSlotsCollectionRef.add({
          'weekday': timeSlot.weekday,
          'startTime': timeSlot.startTime,
          'endTime': timeSlot.endTime,
          'courseID': timeSlot.courseID,
        });

        return 1;
      } else {
        return -1;
      }
    } catch (e) {
      logger.e('Error adding time restraint: $e');
      return -1;
    }
  }

  Future<int?> deleteRestraints() async {
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
  }

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

  Future<int?> checkRestraints() async {
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
  }

  Future<List<TimeSlot>?> getScheduleLimits() async {
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
  }
}
