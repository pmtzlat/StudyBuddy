class UnitModel{

  final String name;
  int hours;
  final String id;
  final int order;
  bool completed;

  UnitModel({required this.name, required this.hours, this.id = '', required this.order, this.completed = false});
}