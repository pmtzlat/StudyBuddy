import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/main.dart';

import '../models/course_model.dart';
import '../models/user_model.dart';
import 'logging_service.dart';

class FirebaseCrudService {

  Future<int> addCourseToUser({required String uid, required CourseModel newCourse}) async {
    try {
      // Check if the user document exists
      final connectivityResult = await instanceManager.connectivity.checkConnectivity();
      logger.i('connectivityresult: $connectivityResult');
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
          'weight': newCourse.weight,
          'examDate': newCourse.examDate.toString(),
          'sessionTime': newCourse.sessionTime,
          'secondsStudied': newCourse.secondsStudied,
          'color': newCourse.color,
          'iconCode': newCourse.iconCode,
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
  
}
