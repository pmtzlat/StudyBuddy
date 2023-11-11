import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';
import 'package:ntp/ntp.dart';

class LocalStorageService {
  final SharedPreferences localStorage;
  LocalStorageService({required SharedPreferences this.localStorage});

  Future<int> updateDateHandling() async {
    final now = await NTP.now();
    if (stripTime(now) != stripTime(DateTime.now())) {
      logger.e('Current Date doesn\'t match server!');
      return -1;
    }
    final String oldNewDate = localStorage.getString('newDate') ??
        stripTime(now.subtract(const Duration(days: 1))).toString();

    logger.i('Old newdate: ${oldNewDate}');
    
    localStorage.setString('oldDate', oldNewDate);
    localStorage.setString('newDate', stripTime(now).toString());

    logger.i('Old date: ${localStorage.getString('oldDate')}');
    logger.i('New date: ${localStorage.getString('newDate')}');
    return 1;
  }
}
