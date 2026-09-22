import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String identifier; // Email or Mobile Number
  final String name;

  const UserModel({
    required this.id,
    required this.identifier,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifier': identifier,
      'name': name,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      identifier: json['identifier'] as String,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, identifier, name];
}
