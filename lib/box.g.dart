// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Box _$BoxFromJson(Map<String, dynamic> json) {
  return Box(
      movieId: json['movieId'] as int,
      movieName: json['movieName'] as String,
      releaseInfo: json['releaseInfo'] as String,
      boxInfo: double.parse(json['boxInfo'] as String),
      sumBoxInfo: json['sumBoxInfo'] as String);
}

Map<String, dynamic> _$BoxToJson(Box instance) => <String, dynamic>{
      'movieId': instance.movieId,
      'movieName': instance.movieName,
      'releaseInfo': instance.releaseInfo,
      'boxInfo': instance.boxInfo,
      'sumBoxInfo': instance.sumBoxInfo,
    };
