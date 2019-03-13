import 'package:json_annotation/json_annotation.dart';

part 'box.g.dart';

@JsonSerializable()
class Box {
  // 影片 ID
  final int movieId;
  // 影片名称
  final String movieName;
  // 放映信息
  final String releaseInfo;
  // 票房
  final double boxInfo;
  // 总票房
  final String sumBoxInfo;

  Box({
    this.movieId,
    this.movieName,
    this.releaseInfo,
    this.boxInfo,
    this.sumBoxInfo,
  });

  factory Box.fromJson(Map<String, dynamic> json) => _$BoxFromJson(json);

  Map<String, dynamic> toJson() => _$BoxToJson(this);
}
