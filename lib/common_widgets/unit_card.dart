import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UnitCard extends StatelessWidget {
  final int index;
  GlobalKey<FormBuilderState> unitCreationFormKey;

  UnitCard({
    required this.index,
    required this.unitCreationFormKey,
  });

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
            Text('${index + 1}.'),
            SizedBox(width: 8.0),
            
          ],
        ),
      ),
    );
  }
}
