class UnitModel {
  final String name;
  Duration sessionTime;
  final String id;
  final int order;
  bool completed;
  Duration completionTime  ;

  UnitModel(
      {required this.name,
      required this.sessionTime,
      this.id = '',
      required this.order,
      this.completed = false,
      this.completionTime = Duration.zero});
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
