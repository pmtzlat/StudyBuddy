class UserModel {
  final String uid; // Non-null id
  final String? name;
  final int? age;
  bool calendarNeedsRecalc;

  UserModel({
    required this.uid,
    this.name,
    this.age,
    this.calendarNeedsRecalc = false
  });

  factory UserModel.fromJSON(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      age: json['age'],
      calendarNeedsRecalc: json['calendarNeedsRecalc']
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = {
      'uid': uid,
      'name': name,
      'age': age,
      'calendarNeedsRecalc': calendarNeedsRecalc
    };
    return data;
  }
}
