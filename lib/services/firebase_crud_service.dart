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
         
        logger.i('User document with UID $uid does not exist.');
        return null;
      }
    } catch (e) {
      
      logger.i('Error adding course to firebase: $e');
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


  Future<String?> addUnitToCourse({required UnitModel newUnit, required String courseID}) async{

    try{
    final uid = instanceManager.localStorage.getString('uid');
    final firebaseInstance = instanceManager.db; 

    final courseRef = firebaseInstance
        .collection('users')
        .doc(uid)
        .collection('courses')
        .doc(courseID);

     
    final unitData = {
      'name': newUnit.name,
      'weight': newUnit.weight*10,
      'order': newUnit.order,
      'id':''
       
    };

    final unitRef = await courseRef.collection('units').add(unitData);
    await unitRef.update({'id': unitRef.id});

     
    return unitRef.id;

    }catch(e){
      logger.e('Error in Firebase CRUD when adding unit to course $courseID: $e');
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
          id: data['id'] as String,
        );
      }).toList();
      return courses;
    } catch (e) {
      // Handle any errors that occur during the process.
      logger.e('Error getting courses: $e');
      return null;
    }
  }
}
