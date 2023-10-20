import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/modules/courses/course_detail_view.dart';

import '../models/course_model.dart';

class CourseCard extends StatefulWidget {
  final course;
  final Function parentRefresh;
  const CourseCard(
      {super.key,
      required CourseModel this.course,
      required this.parentRefresh});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(SlidePageRoute(
          builder: (context) => CourseDetailView(
            course: widget.course,
          ),
        ));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Card(
          color: Colors.lightBlue,
          child: ListTile(title: Text(widget.course.name)),
        ),
      ),
    );
  }

  
}
