import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/models/unit_model.dart';

class UnitCard extends StatelessWidget {
  final UnitModel unit;

  UnitCard({required this.unit});

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${unit.name}: ${unit.name}'),
                Text('${unit.id}'),
                SizedBox(width: 8.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
