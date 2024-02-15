import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:ntp/ntp.dart';

class LocalStorageService {
  final SharedPreferences localStorage;
  LocalStorageService({required SharedPreferences this.localStorage});

  int updateDateHandling(){
    
    logger.i(
        'Previous Old date: ${localStorage.getString('oldDate') ?? 'Not found'}');
    logger.i(
        'Previous New date: ${localStorage.getString('newDate') ?? 'Not found'}');

    
    final String oldNewDate = localStorage.getString('newDate') ??
        stripTime(now.subtract(const Duration(days: 1))).toString();

    //logger.i('Old newdate: ${oldNewDate}');

    localStorage.setString('oldDate', stripTime(DateTime.now().subtract(Duration(days:1))).toString());  //oldNewDate);
    //localStorage.setString('oldDate', '2023-11-18 00:00:00.000');
    localStorage.setString('newDate', stripTime(now).toString());

    logger.i('Current Old date: ${localStorage.getString('oldDate')}');
    logger.i('Current New date: ${localStorage.getString('newDate')}');
    return 1;
  }

  Future<bool> isCorrectDate() async {
    final timeStamp = await NTP.now();
    logger.i('timeStamp : ${stripTime(timeStamp)} - dateTime.now: ${stripTime(DateTime.now())}');
    if (stripTime(timeStamp) != stripTime(DateTime.now())) {
      logger.e('Current Date doesn\'t match server!');
      return false;
    }
    return true;
  }
}
