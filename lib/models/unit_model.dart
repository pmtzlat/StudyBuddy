class UnitModel {
  String name;
  Duration sessionTime;
  final String id;
  final int order;
  bool completed;
  Duration completionTime;
  Duration realStudyTime;

  UnitModel(
      {required this.name,
      this.sessionTime = const Duration(hours:2),
      this.id = '',
      required this.order,
      this.completed = false,
      this.completionTime = Duration.zero,
      this.realStudyTime = Duration.zero});
  UnitModel copyWith({
    String? name,
    Duration? sessionTime,
    String? id,
    int? order,
    bool? completed,
    
  }) {
    return UnitModel(
      name: name ?? this.name,
      sessionTime: sessionTime ?? this.sessionTime,
      id: id ?? this.id,
      order: order ?? this.order,
      completed: completed ?? this.completed,
    );
  }
}
