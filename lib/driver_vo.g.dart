// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverVO _$DriverVOFromJson(Map<String, dynamic> json) => DriverVO(
  json['code'] as String?,
  json['dob'] as String?,
  json['driverRef'] as String?,
  json['forename'] as String?,
  json['fullName'] as String?,
  json['nationality'] as String?,
  (json['number'] as num?)?.toInt(),
  json['surname'] as String?,
  json['url'] as String?,
);

Map<String, dynamic> _$DriverVOToJson(DriverVO instance) => <String, dynamic>{
  'code': instance.code,
  'dob': instance.dob,
  'driverRef': instance.driverRef,
  'forename': instance.forename,
  'fullName': instance.fullName,
  'nationality': instance.nationality,
  'number': instance.number,
  'surname': instance.surname,
  'url': instance.url,
};
