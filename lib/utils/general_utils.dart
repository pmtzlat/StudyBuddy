import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';

List<double> generateDescendingList(int n) {
  List<double> resultList = [];

  for (int i = 0; i < n; i++) {
    double value = 2.0 - (2.0 / n) * i;
    resultList.add(double.parse(value.toStringAsFixed(3)));
  }

  return resultList;
}

String getExamsListString(List<ExamModel>? list) {
  String res = '';
  if (list == null) list = instanceManager.sessionStorage.activeExams;
  for (ExamModel exam in list!) {
    res += '${exam.name} - ${exam.weight}\n';
  }
  return res;
}

String getPosition(ExamModel exam) {
  int position = instanceManager.sessionStorage.activeExams.indexOf(exam) + 1;
  int total = instanceManager.sessionStorage.activeExams.length;
  return '$position of $total';
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

int getDaysUntilExam(DateTime examDate) {
  DateTime currentDate = DateTime.now();
  Duration difference = currentDate.difference(examDate);
  return difference.inDays.abs()+1;
}




