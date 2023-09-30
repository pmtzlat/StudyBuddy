import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/common_widgets/unit_card.dart';
import 'package:study_buddy/services/logging_service.dart';
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
                      onPressed: () async {
                        await widget.course.addUnit();
                        setState(() {});
                      },
                      child: Text(_localizations.addUnit))
                ],
              ),
              widget.course.units == null ? loadUnits() : getUnitList()
            ]),
          ),
        ),
      ),
    );
  }

  void addUnit() async {}

  FutureBuilder<void> loadUnits() {
    final _localizations = AppLocalizations.of(context)!;
    var screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder(
        future: widget.course.getUnits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while the Future is running
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // Display the error message and show the snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(_localizations.errorGettingUnits),
              ),
            );
            return Text('Error: ${snapshot.error}');
          } else {
            if (widget.course.units.length == 0) {
              return Center(
                child: Text(_localizations.noUnitsYet),
              );
            }
            return getUnitList();
          }
        });
  }

  Expanded getUnitList() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.course.units!.length,
          itemBuilder: (context, index) {
            final unit = widget.course.units![index];
            return Dismissible(
              key: Key(unit.id),
              background: Container(
                color: const Color.fromARGB(255, 255, 77, 65),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
              ),
              onDismissed: (direction) async {
                await widget.course.deleteUnit(unit: unit);
                setState(() {});
              },
              child: UnitCard(unit: unit),
            );
          },
        ),
      ),
    );
  }
}
