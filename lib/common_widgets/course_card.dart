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
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black.withOpacity(0.5),

          transitionDuration: Duration(milliseconds: 200),

          // Create the dialog's content
          pageBuilder: (context, animation, secondaryAnimation) {
            return CourseDetailView(
                course: widget.course, refreshParent: widget.parentRefresh);
          },
        );
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
