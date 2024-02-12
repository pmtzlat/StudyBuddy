import 'package:study_buddy/main.dart';
import 'package:study_buddy/services/logging_service.dart';
import 'package:study_buddy/utils/datatype_utils.dart';


class UnitModel {
  String name;
  Duration sessionTime;
  final String id;
  int order;
  int totalSessions;
  int completedSessions;
  bool completed;
  String examID;

  UnitModel({
    required this.name,
    this.sessionTime = const Duration(hours: 2),
    this.id = '',
    this.examID = '',
    required this.order,
    this.totalSessions = 1,
    this.completedSessions = 0,
    this.completed = false,
  }) ;

  // Deserialize from JSON
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      name: json['name'] ?? '',
      sessionTime: Duration(milliseconds: json['sessionTime'] ?? 0),
      id: json['id'] ?? '',
      order: json['order'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      completedSessions: json['completedSessions'] ?? 0,
    )..completed = (json['completedSessions'] == json['totalSessions']);
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sessionTime': sessionTime.inMilliseconds,
      'id': id,
      'order': order,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
    };
  }

  // Deep copy method
  UnitModel deepCopy() {
    return UnitModel.fromJson(this.toJson());
  }

  Future<void> editCompletedSessions(int x) async { //doesn't work properly with revisions, needs debugging
    completedSessions += x;
    
    await instanceManager.firebaseCrudService.changeUnitCompletedSessions(examID, id, completedSessions);
    bool newCompletion = (completedSessions == totalSessions);
    logger.i(getString());
    await instanceManager.firebaseCrudService
        .changeUnitCompleteness(examID, id, newCompletion);
    
  }

  String getString(){
    return '\n\nUnit $name: \nSessions completed: $completedSessions / $totalSessions\nCompleted: $completed\nExam: $examID\n\n';
  }

  UnitModel copyWith({
    String? name,
    Duration? sessionTime,
    String? id,
    int? order,
    int? totalSessions,
    int? completedSessions,
  }) {
    return UnitModel(
      name: name ?? this.name,
      sessionTime: sessionTime ?? this.sessionTime,
      id: id ?? this.id,
      order: order ?? this.order,
      totalSessions: totalSessions ?? this.totalSessions,
      completedSessions: completedSessions ?? this.completedSessions,
    )..completed = (completedSessions == totalSessions);
  }

  
}
