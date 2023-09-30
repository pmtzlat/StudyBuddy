import 'package:flutter/material.dart';
import 'package:study_buddy/models/unit_model.dart';

class CourseModel {
  final String name;
  final double weight;
  final DateTime examDate;
  final int secondsStudied;
  final String color;
  final int sessionTime; // in seconds
  final DateTime startStudy;
  final String id;
  final List<UnitModel>? units;

  /*
  var iconData = IconData(58717, fontFamily: 'MaterialIcons')

  // Store this in the database
  var icon iconCodePoint = iconData.codePoint;

  // Restore from the database to get icon
  var iconData = IconData(iconCodePointFromDataBase, fontFamily: 'MaterialIcons');
  */

  CourseModel({
    required this.name,
    this.weight = 1.0,
    required this.examDate,
    this.secondsStudied = 0,
    this.color = '#000000',
    this.sessionTime = 3600, //one hour
    required this.startStudy,
    this.id = '',
    this.units = null,
  });

  bool inFuture(DateTime date) {
    if (examDate.isAfter(date)) {
      return true;
    }
    return false;
  }
}
