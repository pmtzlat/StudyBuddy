import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool sessionsSplittable; // determines if sessions should be splittable between days if a day doesn't have enough time

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
    this.timeStudied = const Duration(seconds: 0),
    this.color = Colors.redAccent,
    this.revisionTime = const Duration(hours: 2), //one hour
    this.id = '0',
    this.units = const <UnitModel>[],
    this.orderMatters = false,
    this.revisions = const [],
    this.sessionsSplittable = true,
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
        revisions = List<UnitModel>.from(other.revisions),
        sessionsSplittable = other.sessionsSplittable;

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
    try {
      units = await firebaseCrud
          .getUnitsForExam(examID: id)
          .timeout(timeoutDuration);
      //printUnits();
    } catch (e) {
      logger.e('Error getting units for exam: $name: $e');
    }
  }

  Future<void> getRevisions() async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    try {
      revisions = await firebaseCrud
          .getRevisionsForExam(examID: id)
          .timeout(timeoutDuration)
          .timeout(timeoutDuration);
      //printRevisions();
    } catch (e) {
      logger.e('Error getting revisions for exam: $name: $e');
    }
  }

  Future<void> addUnit(BuildContext context) async {
    final firebaseCrud = instanceManager.firebaseCrudService;
    final _localizations = AppLocalizations.of(context)!;
    try {
      if (units == null) {
        final newUnit = UnitModel(
            name: ' ${_localizations.unit} 1',
            order: 1,
            sessionTime: revisionTime,
            );
        await firebaseCrud
            .addUnitToExam(newUnit: newUnit, examID: id)
            .timeout(timeoutDuration);
      } else {
        final newUnit = UnitModel(
            name: ' ${_localizations.unit} ${units!.length + 1}',
            order: units!.length + 1,
            sessionTime: revisionTime);
        await firebaseCrud
            .addUnitToExam(newUnit: newUnit, examID: id)
            .timeout(timeoutDuration);
      }
      await getUnits();
    } catch (e) {
      logger.e('Error adding unit: $e');
    }
  }

  Future<void> deleteUnit({required UnitModel unit}) async {
    try {
      final firebaseCrud = instanceManager.firebaseCrudService;
      final unitNum = unit.order;
      await firebaseCrud
          .deleteUnit(unit: unit, examID: id)
          .timeout(timeoutDuration);
      await getUnits();
    } catch (e) {
      logger.e('Error deleting unit $e');
    }
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

  void printMe() {
    String res =
        'Exam $name: \n Date: $examDate:\n Order Matters: $orderMatters\n Units: ';
    for (UnitModel unit in units) {
      res +=
          '\n       ${unit.name}: ${formatDuration(unit.sessionTime)}, completed: ${unit.completed}, order: ${unit.order} - ${unit.id}';
    }
    res +=
        '\n Revision days: ${revisions.length}\n Revision session: $revisionTime';

    logger.i(res);
  }

  void updateUnitOrders(GlobalKey<FormBuilderState>? formKey, BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    String res = 'New unit order: \n';
    for (int i = 0; i < units.length; i++) {
      units[i].order = i + 1;
      //logger.i('$i: Unit ${units[i].order} name: ${units[i].name}');

      if (units[i].name == ' ${_localizations.unit} ${units[i].order + 1}')
        units[i].name = ' ${_localizations.unit} ${units[i].order}';
      res += '${units[i].name}: ${units[i].order}\n';
      
    }
    //logger.i('$res');
  }
}
