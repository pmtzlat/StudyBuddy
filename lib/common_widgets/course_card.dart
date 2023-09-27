import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/course_model.dart';

class CourseCard extends StatefulWidget {
  final course;
  const CourseCard({super.key, required CourseModel this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Card(
        color: Colors.lightBlue,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text(widget.course.name)],
          ),
        ),
      ),
    );
  }
}
