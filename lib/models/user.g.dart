// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => $checkedCreate(
      'User',
      json,
      ($checkedConvert) {
        final val = User(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          userType: $checkedConvert(
              'userType', (v) => $enumDecode(_$UserTypeEnumMap, v)),
          address: $checkedConvert('address', (v) => v as String),
          latitude: $checkedConvert('latitude', (v) => (v as num).toDouble()),
          longitude: $checkedConvert('longitude', (v) => (v as num).toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'userType': _$UserTypeEnumMap[instance.userType]!,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

const _$UserTypeEnumMap = {
  UserType.farmer: 'farmer',
  UserType.consumer: 'consumer',
};
