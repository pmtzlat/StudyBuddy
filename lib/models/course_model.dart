import 'package:flutter/material.dart';
import 'package:study_buddy/models/unit_model.dart';

class CourseModel {
  final String name;
  final double weight;
  final DateTime examDate;
  final List<UnitModel>? units;
  final int secondsStudied;
  final String color;
  final int iconCode;
  final IconData icon;

  /*
  var iconData = IconData(58717, fontFamily: 'MaterialIcons')

  // Store this in the database
  var icon iconCodePoint = iconData.codePoint;

  // Restore from the database to get icon
  var iconData = IconData(iconCodePointFromDataBase, fontFamily: 'MaterialIcons');
  */ 

  CourseModel(
      {required this.name,
      this.weight = 1.0,
      required this.examDate,
      this.units,
      this.secondsStudied = 0,
      this.color = '#000000',
      this.iconCode = 0xe0bf}) : icon = IconData(iconCode, fontFamily: 'MaterialIcons');



  
}
