import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';
import 'package:study_buddy/models/unit_model.dart';
import 'package:study_buddy/modules/exams/exam_detail_view.dart';
import 'package:study_buddy/services/logging_service.dart';

class UnitCard extends StatefulWidget {
  UnitModel unit;
  ExamModel exam;
  Function notifyParent;
  Function showError;
  Color lightShade;
  Color darkShade;
  bool darkMode;

  UnitCard(
      {required this.unit,
      required this.exam,
      required Function this.notifyParent,
      required Function this.showError,
      required this.lightShade,
      required this.darkShade,
      required this.darkMode});

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard>
    with SingleTickerProviderStateMixin {
  final _controller = instanceManager.examController;
  var editMode = false;
  final unitFormKey = GlobalKey<FormBuilderState>();
  UnitModel unit = UnitModel(name: 'init', order: 0);
  bool open = false;
  late AnimationController _animationController;
  Duration openUnit = Duration(milliseconds: 200);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    unit = widget.unit;
    _animationController = AnimationController(
      vsync: this,
      duration: openUnit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final _localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: widget.darkMode ? widget.darkShade : widget.lightShade,
      child: AnimatedContainer(
        duration: openUnit,
        height: !open ? screenHeight*0.07 : screenHeight*0.2,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Theme(
                data: ThemeData().copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  trailing: RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.5).animate(_animationController),
                      child: Icon(Icons.expand_more, color: Colors.white)),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      open = expanded;
                      if (open) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  title: Text(unit.name,
                      style: TextStyle(
                          color: widget.darkMode ? Colors.black : Colors.white,
                          fontSize: screenWidth * 0.05)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
