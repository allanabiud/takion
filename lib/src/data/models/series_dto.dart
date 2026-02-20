import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:takion/src/domain/entities/series.dart';

part 'series_dto.freezed.dart';
part 'series_dto.g.dart';

@freezed
@HiveType(typeId: 1)
abstract class SeriesDto with _$SeriesDto {
  const factory SeriesDto({
    @HiveField(0) int? id,
    @HiveField(1) String? name,
    @HiveField(2) int? volume,
    @HiveField(3) @JsonKey(name: 'year_began') int? yearBegan,
    @HiveField(4) @JsonKey(name: 'publisher_name') String? publisherName,
    @HiveField(5) @JsonKey(name: 'desc') String? description,
    @HiveField(6) @JsonKey(name: 'year_end') int? yearEnd,
    @HiveField(7) @JsonKey(name: 'issue_count') int? issueCount,
    @HiveField(8) @JsonKey(name: 'series') String? seriesName, // Used by /api/series/
  }) = _SeriesDto;

  factory SeriesDto.fromJson(Map<String, dynamic> json) => _$SeriesDtoFromJson(json);

  const SeriesDto._();

  Series toEntity() {
    return Series(
      id: id ?? 0,
      name: name ?? seriesName ?? 'Unknown Series',
      volume: volume,
      yearBegan: yearBegan,
      yearEnd: yearEnd,
      issueCount: issueCount,
      publisherName: publisherName,
      description: description,
    );
  }
}
