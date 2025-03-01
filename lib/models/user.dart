import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserType {
  farmer,
  consumer
}

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final UserType userType;
  final String address;
  final double latitude;
  final double longitude;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
} 