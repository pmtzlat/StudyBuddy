import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DesyncView extends StatelessWidget {
  const DesyncView({super.key});

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(body: Center(child: Container(width:screenWidth*0.7, child: Text(_localizations.desyncMsg))),);
  }
}