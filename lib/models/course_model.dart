import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class CourseModel {
  final String name;
  final double weight;
  final DateTime examDate;
  final int secondsStudied;
  final String color;
  final int sessionTime; // in seconds
  final String id;
  List<UnitModel>? units;
  bool orderMatters;
  int revisions;

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
    this.id = '',
    this.units = null,
    this.orderMatters = false,
    this.revisions = 2,
  });

  bool inFuture(DateTime date) {
    if (examDate.isAfter(date)) {
      return true;
    }
    return false;
  }

  Future<void> getUnits() async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    units = await firebaseCrud.getUnitsForCourse(courseID: id);
  }

  Future<void> addUnit() async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    if (units == null) {
      final newUnit = UnitModel(name: 'Unit 1', order: 1, hours: sessionTime, completed: false);
      await firebaseCrud.addUnitToCourse(newUnit: newUnit, courseID: id);
    } else {
      final newUnit = UnitModel(
          name: 'Unit ${units!.length + 1}', order: units!.length + 1, hours: sessionTime, completed: false);
      await firebaseCrud.addUnitToCourse(newUnit: newUnit, courseID: id);
    }
    await getUnits();
  }

  Future<void> deleteUnit({required UnitModel unit}) async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    final unitNum = unit.order;
    await firebaseCrud.deleteUnit(unit: unit, courseID: id);
    await getUnits();
  }

  void printUnits() {
    if (units != null) {
      for (int i = 0; i < units!.length; i++) {
        logger.i('${units![i].name}, ${units![i].id}');
      }
    }
  }
}
