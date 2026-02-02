import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  // Optional name
  final String? name;

  final String? pinCode;
  final String? phoneNumber;

  const User({this.id, this.name, this.pinCode, this.phoneNumber});

  User copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? pinCode,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    pinCode: pinCode ?? this.pinCode,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    pinCode: json['pinCode'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'pinCode': pinCode,
  };

  @override
  List<Object?> get props => [id, name, phoneNumber, pinCode];

  @override
  String toString() {
    return 'User(id: $id, name: $name, phoneNumber: $phoneNumber, pinCode: $pinCode)';
  }
}
