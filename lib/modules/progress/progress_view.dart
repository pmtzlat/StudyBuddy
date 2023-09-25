import 'package:flutter/material.dart';
import 'package:study_buddy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GraphsView extends StatefulWidget {
  const GraphsView({super.key});

  @override
  State<GraphsView> createState() => _GraphsViewState();
}

class _GraphsViewState extends State<GraphsView> {
  @override
  Widget build(BuildContext context) {
    return instanceManager.scaffold.getScaffold(context: context, activeIndex: 3, 
    body:
    Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(AppLocalizations.of(context)!.progressTitle)],
            )
          ],
        )
    );;
  }
}