enum UserType {
  farmer,
  consumer
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String address;
  final double latitude;
  final double longitude;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == map['user_type'],
        orElse: () => UserType.consumer,
      ),
      address: map['address'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType.toString().split('.').last,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Add copy with method for updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserType? userType,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Add equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.userType == userType &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        userType.hashCode ^
        address.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, userType: $userType, address: $address, latitude: $latitude, longitude: $longitude)';
  }
} 