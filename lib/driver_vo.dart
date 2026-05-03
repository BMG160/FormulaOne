import 'dart:core';

import 'package:json_annotation/json_annotation.dart';

part 'driver_vo.g.dart';

@JsonSerializable()
class DriverVO{

  @JsonKey(name: 'code')
  String? code;

  @JsonKey(name: 'dob')
  String? dob;

  @JsonKey(name: 'driverRef')
  String? driverRef;

  @JsonKey(name: 'forename')
  String? forename;

  @JsonKey(name: 'fullName')
  String? fullName;

  @JsonKey(name: 'nationality')
  String? nationality;

  @JsonKey(name: 'number')
  int? number;

  @JsonKey(name: 'surname')
  String? surname;

  @JsonKey(name: 'url')
  String? url;


  DriverVO(this.code, this.dob, this.driverRef, this.forename, this.fullName,
      this.nationality, this.number, this.surname, this.url);

  factory DriverVO.fromJson(Map<String, dynamic> json) => _$DriverVOFromJson(json);

  Map<String, dynamic> toJson() => _$DriverVOToJson(this);
}