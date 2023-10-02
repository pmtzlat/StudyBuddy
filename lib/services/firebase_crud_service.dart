import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/main.dart';
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
          'startStudy': newCourse.startStudy.toString(),
          'id': ''
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
          weight: (unitData['weight'] ?? 1.0).toDouble() / 10,
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
        'weight': newUnit.weight * 10,
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

  Future<bool> addUnit({required UnitModel newUnit, required courseID}) async {
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db;

    try {
      if (uid == null) {
        return false;
      }

      final courseDocRef = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseID);

      final unitData = {
        'name': newUnit.name,
        'weight': newUnit.weight,
        'order': newUnit.order,
      };

      await courseDocRef.collection('units').add(unitData);

      return true;
    } catch (e) {
      logger.e('Error adding new Unit: $e');
      return false;
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
          startStudy: DateTime.parse((data['startStudy'] as String)),
          id: data['id'] as String,
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
        }else{
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
      // Reference to the 'units' subcollection document
      final unitReference = firebaseInstance
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseID)
          .collection('units')
          .doc(unitID);

      // Convert weight to integer by multiplying by 10
      final updatedWeight = (updatedUnit.weight * 10).toInt();

      // Update the unit document with new data
      await unitReference.update({
        'name': updatedUnit.name,
        'weight': updatedWeight,
        // Add other fields you want to update
      });

      return 1; // Success
    } catch (e) {
      logger.e('Error editing unit: $e');
      return -1;
    }
  }
}
