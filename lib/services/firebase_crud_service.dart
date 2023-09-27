import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/main.dart';

import '../models/course_model.dart';
import '../models/user_model.dart';
import 'logging_service.dart';

class FirebaseCrudService {
  Future<int> addCourseToUser(
      {required String uid, required CourseModel newCourse}) async {
    try {
      // Check if the user document exists
      final connectivityResult =
          await instanceManager.connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return -1; // No internet connectivity
      }

      final userDocRef = instanceManager.db.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // User document exists, add the new course to the courses subcollection
        final coursesCollectionRef = userDocRef.collection('courses');
        await coursesCollectionRef.add({
          'name': newCourse.name,
          'weight': newCourse.weight *
              10, //weight stored as integers, so x10 when writing and /10 when reading
          'examDate': newCourse.examDate.toString(),
          'sessionTime': newCourse.sessionTime,
          'secondsStudied': newCourse.secondsStudied,
          'color': newCourse.color,
          'startStudy': newCourse.startStudy.toString()
        });
        return 1;
      } else {
        // Handle the case where the user document doesn't exist
        logger.i('User document with UID $uid does not exist.');
        return 0;
      }
    } catch (e) {
      // Handle any errors here
      logger.i('Error adding course to firebase: $e');
      return -1;
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
        

        // Convert the 'weight' from Firestore (integer) to a double by dividing by 10
        final double weight = ((data['weight'] as double) / 10.0);

        return CourseModel(
          name: data['name'] as String,
          weight: weight,
          examDate: DateTime.parse((data['examDate'] as String)),
          secondsStudied: data['secondsStudied'] as int,
          color: data['color'] as String,
          sessionTime: data['sessionTime'] as int,
          startStudy: DateTime.parse((data['startStudy'] as String)),
        );
      }).toList();
      logger.i('Success getting courses!');
      return courses;
    } catch (e) {
      // Handle any errors that occur during the process.
      logger.e('Error getting courses: $e');
      return null;
    }
  }
}
