import 'package:flutter/material.dart';
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
    content: Text(message, style: TextStyle(color: Colors.white)),
    backgroundColor: Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showErrorDialogForRecalc(
    BuildContext context, String title, String body, bool showLeftovers) {
  var screenHeight = MediaQuery.of(context).size.height;
  var screenWidth = MediaQuery.of(context).size.width;
  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Color.fromARGB(48, 0, 0, 0),
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Card(
            child:  Container(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.7, // Set your maximum height
                ),
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenWidth * 0.05),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: screenWidth * 0.2,
                      color: Colors.amber,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(body),
                    SizedBox(height: screenHeight * 0.03),
                    if (showLeftovers)
                       Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  screenHeight * 0.18, // Set your maximum height
                            ),
                            child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              removeBottom: true,
                              child:  Scrollbar(
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                      itemCount: instanceManager
                                          .sessionStorage.leftoverCourses.length,
                                      itemBuilder: (context, index) {
                                        final currentItem = instanceManager
                                            .sessionStorage
                                            .leftoverCourses[index];
                              
                                        return Text('$currentItem \n');
                                      }),
                                ),
                            )),
                      
                  ],
                ),
              ),
          ),
        );
      });
}
