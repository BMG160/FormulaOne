import 'package:json_annotation/json_annotation.dart';

part 'constructor_vo.g.dart';

@JsonSerializable()
class ConstructorVO{

  @JsonKey(name: 'constructorRef')
  String constructorRef;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'nationality')
  String nationality;

  @JsonKey(name: 'url')
  String url;

  ConstructorVO(this.constructorRef, this.name, this.nationality, this.url);

  factory ConstructorVO.fromJson(Map<String, dynamic> json) => _$ConstructorVOFromJson(json);

  Map<String, dynamic> toJson() => _$ConstructorVOToJson(this);
}