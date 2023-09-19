class UserModel {
  final String uid; // Non-null id
  final String? name;
  final int? age;

  UserModel({
    required this.uid,
    this.name,
    this.age,
  });

  factory UserModel.fromJSON(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = {
      'uid': uid,
      'name': name,
      'age': age,
    };
    return data;
  }
}
