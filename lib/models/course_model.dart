import 'package:study_buddy/models/unit_model.dart';

class Course {
  final String name;
  final double weight;
  final DateTime examDate;
  final List<Unit>? units;
  final int secondsStudied;

  Course(
      {required this.name,
      this.weight = 1.0,
      required this.examDate,
      this.units,
      this.secondsStudied = 0});
}
