import 'package:study_buddy/utils/datatype_utils.dart';

class UnitModel {
  String name;
  Duration sessionTime;
  final String id;
  int order;
  bool completed;
  Duration completionTime;
  Duration realStudyTime;

  UnitModel({
    required this.name,
    this.sessionTime = const Duration(hours: 2),
    this.id = '',
    required this.order,
    this.completed = false,
    this.completionTime = Duration.zero,
    this.realStudyTime = Duration.zero,
  });

  // Deserialize from JSON
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      name: json['name'] ?? '',
      sessionTime: Duration(milliseconds: json['sessionTime'] ?? 0),
      id: json['id'] ?? '',
      order: json['order'] ?? 0,
      completed: json['completed'] ?? false,
      completionTime: Duration(milliseconds: json['completionTime'] ?? 0),
      realStudyTime: Duration(milliseconds: json['realStudyTime'] ?? 0),
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sessionTime': sessionTime.inMilliseconds,
      'id': id,
      'order': order,
      'completed': completed,
      'completionTime': completionTime.inMilliseconds,
      'realStudyTime': realStudyTime.inMilliseconds,
    };
  }

  // Deep copy method
  UnitModel deepCopy() {
    return UnitModel.fromJson(this.toJson());
  }

  UnitModel copyWith({
    String? name,
    Duration? sessionTime,
    String? id,
    int? order,
    bool? completed,
    Duration? completionTime,
    Duration? realStudyTime,
  }) {
    return UnitModel(
      name: name ?? this.name,
      sessionTime: sessionTime ?? this.sessionTime,
      id: id ?? this.id,
      order: order ?? this.order,
      completed: completed ?? this.completed,
      completionTime: completionTime ?? this.completionTime,
      realStudyTime: realStudyTime ?? this.realStudyTime,
    );
  }

  String getString() {
    return 'Unit $order: $name \n\n${formatDuration(sessionTime)} - $completed';
  }

  

}
