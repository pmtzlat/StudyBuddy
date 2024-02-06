import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';

class ReloadButton extends StatefulWidget {
  Function buttonAction;
  Function updateParent;
  String buttonMessage;
  String bodyMessage;
  ReloadButton({super.key, 
  required this.updateParent,
  required this.buttonMessage,
  required this.bodyMessage,
  required this.buttonAction});

  @override
  State<ReloadButton> createState() => _ReloadButtonState();
}

class _ReloadButtonState extends State<ReloadButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final _localizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          
          widget.bodyMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.black54),
        ),
        Container(
          margin: EdgeInsets.all(screenWidth * 0.1),
          child: ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                loading = true;
              });
              
              await widget.buttonAction();
              
              setState(() {
                loading = false;
              });
              widget.updateParent();
            },
            icon: !loading
                ? Icon(Icons.replay_outlined,
                    color: Colors.black54, size: screenWidth * 0.07)
                : const CircularProgressIndicator(
                    color: Colors.black54,
                  ),
            label: !loading
                ? Text(widget.buttonMessage,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: screenWidth * 0.05,
                    ))
                : SizedBox(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0.0,
              padding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.03, horizontal: screenWidth * 0.08),
            ),
          ),
        )
      ],
    );
  }
}
