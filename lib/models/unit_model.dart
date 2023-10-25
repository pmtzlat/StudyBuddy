class UnitModel {
  final String name;
  Duration sessionTime;
  final String id;
  final int order;
  bool completed;

  UnitModel(
      {required this.name,
      required this.sessionTime,
      this.id = '',
      required this.order,
      this.completed = false});
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
