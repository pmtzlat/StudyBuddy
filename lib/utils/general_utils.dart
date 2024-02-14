import 'dart:math';

import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/day_model.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';

const colorOptions = [
  
  Colors.blueAccent,
  Colors.cyan,
  Colors.deepOrangeAccent,
  Colors.purple,
  Colors.indigo,
  Colors.lightGreen,
  Colors.orangeAccent,
  Colors.pinkAccent,
  Colors.purpleAccent,
  Colors.redAccent,
  Colors.teal,
];

Color getRandomColor() {
  final random = Random();
  final index = random.nextInt(colorOptions.length);
  return colorOptions[index];
}

List<double> generateDescendingList(int n) {
  List<double> resultList = [];

  for (int i = 0; i < n; i++) {
    double value = 2.0 - (2.0 / n) * i;
    resultList.add(double.parse(value.toStringAsFixed(3)));
  }

  return resultList;
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
  return difference.inDays.abs() + 1;
}

String generateRandomString({int length = 8}) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return String.fromCharCodes(
    Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );
}

void closeKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus) {
    logger.i('unfocused');

    FocusScope.of(context).requestFocus(new FocusNode());
  }
}

bool containsDayWithID(List<DayModel> days, String targetId) {
  // Using any() method to check if any element satisfies the condition
  return days.any((day) => day.id == targetId);
}

bool containsDayWithDate(List<DayModel> days, DateTime targetDate) {
  // Using any() method to check if any element satisfies the condition
  return days.any((day) => day.date == stripTime(targetDate));
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    double x = size.width;
    double y = size.height;

    double r = x/12; // variable that changes


    double a = x/2 - (r + r/6);
    double b = r/6;
    double c = x/2 - r;


    path.moveTo(0, r);
    path.lineTo(a, r);
    path.quadraticBezierTo( c, r, c, r-b);
    path.quadraticBezierTo( c, 0, x/2, 0);
    path.quadraticBezierTo( x/2 + r, 0, x/2 + r, r-b);
    path.quadraticBezierTo( x/2 + r, r, x/2 + r + b, r);
    path.lineTo(x, r);

    path.lineTo(x, y);
    path.lineTo(0, y);
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ClipShadowPath extends StatelessWidget {
  final Shadow shadow;
  final CustomClipper<Path> clipper;
  final Widget child;

  const ClipShadowPath({
    Key? key,
    required this.shadow,
    required this.clipper,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClipShadowShadowPainter(
        clipper: clipper,
        shadow: shadow,
      ),
      child: ClipPath(child: child, clipper: clipper),
    );
  }
}

class _ClipShadowShadowPainter extends CustomPainter {
  final Shadow shadow;
  final CustomClipper<Path> clipper;

  _ClipShadowShadowPainter({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


