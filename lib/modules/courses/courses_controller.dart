import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/course_model.dart';

class CoursesController {
  addCourse({
    required name,
    weight = 1.0,
    required examDate,
    units,
    secondsStudied = 0,
    color = '#000000',
    iconCode = 0xe0bf,
    sessionTime = 3600, //one hour
  }) {

    final newCourse = CourseModel(name: name, examDate: examDate);
    final firebaseCrud = instanceManager.firebaseCrudService;
    final uid = instanceManager.localStorage.getString('uid') ?? '';
    return firebaseCrud.addCourseToUser(uid: uid, newCourse: newCourse);

  }
}
