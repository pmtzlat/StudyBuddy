import 'package:flutter/material.dart';
import 'package:study_buddy/common_widgets/leftover_card.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';

void showRedSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message, style: TextStyle(color: Colors.white)),
    backgroundColor: Colors.red,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showGreenSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message, style: const TextStyle(color: Colors.white)),
    backgroundColor: Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> showErrorDialogForRecalc(
    BuildContext context, String title, String body, bool showLeftovers) async {
  var screenHeight = MediaQuery.of(context).size.height;
  var screenWidth = MediaQuery.of(context).size.width;
  await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Color.fromARGB(155, 0, 0, 0),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Card(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.65, // Set your maximum height
              ),
              width: screenWidth * 0.9,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1, vertical: screenWidth * 0.07),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: screenWidth * 0.2,
                      color: Colors.amber,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 30),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(body),
                    SizedBox(height: screenHeight * 0.03),
                    if (showLeftovers)
                      Column(children: <Widget>[
                        for (String item
                            in instanceManager.sessionStorage.leftoverExams)
                          LeftOverCard(text: item)
                      ]

                          //  itemCount: instanceManager
                          //      .sessionStorage.leftoverExams.length,
                          //  itemBuilder: (context, index) {
                          //    final currentItem = instanceManager
                          //        .sessionStorage
                          //        .leftoverExams[index];

                          //    return LeftOverCard(text: currentItem);
                          //  }
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
}
