import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_buddy/common_widgets/reload_button.dart';
import 'package:study_buddy/common_widgets/scaffold.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/modules/calendar/calendar_view.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/error_&_success_messages.dart';

class StartErrorPage extends StatefulWidget {
  String errorMsg;
  StartErrorPage({super.key, required this.errorMsg});

  @override
  State<StartErrorPage> createState() => _StartErrorPageState();
}

class _StartErrorPageState extends State<StartErrorPage> {

  
  
  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    var screenWidth = MediaQuery.of(context).size.width;
    String displayedMessage = '';
    
    switch(widget.errorMsg){
      case('Sync Error'): displayedMessage = _localizations.desyncMsg;
      case('Connection Error'): displayedMessage = _localizations.noConnectionMsg;
      case('Start Error'): displayedMessage = _localizations.errorLoading;

    }
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 50,
              color: Colors.amber,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: ReloadButton(
              buttonMessage: _localizations.reload,
              updateParent: ()async{

            }, 
            buttonAction: ()async{
              try{
                await Future.delayed(const Duration(seconds: 3));
                if(await handleAppStart()){
                  logger.i('Successful start!');
                  Navigator.of(context)
                    .pushReplacement(fadePageRouteBuilder(CalendarView()));
                }else{
                  throw Exception;
                }

              }catch(e){
                logger.e('Error handling app start: $e');
                  showRedSnackbar(context, _localizations.errorLoading);
              }

            },
            
            bodyMessage: displayedMessage)
          )
        ],
      )),
    );
  }
}
