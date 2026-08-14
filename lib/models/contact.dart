import 'package:equatable/equatable.dart';

class Person {
  final String id;
  final String name;
  final String phone;

  Person({required this.id, required this.name, required this.phone});
}

class Contact extends Equatable {
  final int? id;
  final String? name;
  final String? address;
  final String? nrc;
  final String? phone;
  final String? contactType;

  const Contact({
    this.id,
    this.name,
    this.nrc,
    this.address,
    this.phone,
    this.contactType,
  });

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? nrc,
    String? address,
    String? contactType,
  }) => Contact(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    nrc: nrc ?? this.nrc,
    address: address ?? this.address,
    contactType: contactType ?? this.contactType,
  );

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    address: json['address'],
    nrc: json['nrc'],
    contactType: json['contactType'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'nrc': nrc,
    'address': address,
    if (contactType != null) 'contactType': contactType,
  };

  @override
  List<Object?> get props => [id, name, phone, nrc, address, contactType];

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, phone: $phone, nrc: $nrc, address: $address, contactType: $contactType)';
  }
}
