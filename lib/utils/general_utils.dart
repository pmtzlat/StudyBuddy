import 'package:study_buddy/main.dart';
import 'package:study_buddy/models/exam_model.dart';

List<double> generateDescendingList(int n) {
      List<double> resultList = [];

      for (int i = 0; i < n; i++) {
        double value = 2.0 - (2.0/n)*i;
        resultList.add(double.parse(value.toStringAsFixed(3)));
      }

      return resultList;
    }

String getActiveExamsString(List<ExamModel>? list){
  String res = '';
  if(list == null) list = instanceManager.sessionStorage.activeExams;
  for (ExamModel exam in list!){
    res += '${exam.name} - ${exam.weight}\n';

  }
  return res;
}