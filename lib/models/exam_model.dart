import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';

class ExamModel {
  String name;
  double weight;
  DateTime examDate;
  Duration timeStudied;
  Color color;
  Duration revisionTime;
  final String id;
  List<UnitModel> units;
  bool orderMatters;
  List<UnitModel> revisions;


  /*
  var iconData = IconData(58717, fontFamily: 'MaterialIcons')

  // Store this in the database
  var icon iconCodePoint = iconData.codePoint;

  // Restore from the database to get icon
  var iconData = IconData(iconCodePointFromDataBase, fontFamily: 'MaterialIcons');
  */

  ExamModel({
    required this.name,
    this.weight = 2.0,
    required this.examDate,
    this.timeStudied = const Duration(seconds:0),
    this.color = Colors.redAccent,
    this.revisionTime = const Duration(hours: 2), //one hour
    this.id = '0',
    this.units = const <UnitModel>[],
    this.orderMatters = false,
    this.revisions = const [],
  });

   ExamModel.copy(ExamModel other)
      : name = other.name,
        weight = other.weight,
        examDate = other.examDate,
        timeStudied = other.timeStudied,
        color = other.color,
        revisionTime = other.revisionTime,
        id = other.id,
        units = List<UnitModel>.from(other.units),
        orderMatters = other.orderMatters,
        revisions = List<UnitModel>.from(other.revisions);

  bool inFuture(DateTime date) {
    if (examDate.isAfter(date)) {
      return true;
    }
    return false;
  }
  bool inPastOrPresent(DateTime date) {
    if (!examDate.isAfter(date)) {
      return true;
    }
    return false;
  }

  Future<void> getUnits() async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    units = await firebaseCrud.getUnitsForExam(examID: id);
    //printUnits();
  }

  Future<void> getRevisions() async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    revisions = await firebaseCrud.getRevisionsForExam(examID: id);
    //printRevisions();

  }

  Future<void> addUnit() async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    if (units == null) {
      final newUnit = UnitModel(name: 'Unit 1', order: 1, sessionTime: revisionTime, completed: false);
      await firebaseCrud.addUnitToExam(newUnit: newUnit, examID: id);
    } else {
      final newUnit = UnitModel(
          name: 'Unit ${units!.length + 1}', order: units!.length + 1, sessionTime: revisionTime, completed: false);
      await firebaseCrud.addUnitToExam(newUnit: newUnit, examID: id);
    }
    await getUnits();
  }

  Future<void> deleteUnit({required UnitModel unit}) async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    final unitNum = unit.order;
    await firebaseCrud.deleteUnit(unit: unit, examID: id);
    await getUnits();
  }

  void printUnits() {
    if (units != null) {
      for (int i = 0; i < units!.length; i++) {
        logger.i('${units![i].name}, ${units![i].id}');
      }
    }
  }

  void printRevisions() {
    if (revisions != null) {
      for (int i = 0; i < revisions!.length; i++) {
        logger.i('${revisions![i].name}, ${revisions![i].id}');
      }
    }
  }
}
