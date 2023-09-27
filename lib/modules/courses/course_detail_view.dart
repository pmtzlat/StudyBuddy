import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/course_model.dart';

class CourseDetailView extends StatefulWidget {
  final course;
  const CourseDetailView({super.key, required CourseModel this.course});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  final units = [];
  final _controller = instanceManager.courseController;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Card(
          color: Colors.lightBlue,
          child: Container(
            height: screenHeight * 0.7,
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(
                children: [Text(widget.course.name)],
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {}, child: Text(_localizations.addUnit))
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
