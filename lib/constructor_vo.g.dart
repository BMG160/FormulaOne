// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constructor_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConstructorVO _$ConstructorVOFromJson(Map<String, dynamic> json) =>
    ConstructorVO(
      json['constructorRef'] as String,
      json['name'] as String,
      json['nationality'] as String,
      json['url'] as String,
    );

Map<String, dynamic> _$ConstructorVOToJson(ConstructorVO instance) =>
    <String, dynamic>{
      'constructorRef': instance.constructorRef,
      'name': instance.name,
      'nationality': instance.nationality,
      'url': instance.url,
    };
