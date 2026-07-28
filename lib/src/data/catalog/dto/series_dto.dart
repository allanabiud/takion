import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:takion/src/domain/entities.dart';

part 'series_dto.freezed.dart';
part 'series_dto.g.dart';

@freezed
abstract class SeriesDto with _$SeriesDto {
  const factory SeriesDto({
    int? id,
    String? name,
    int? volume,
    @JsonKey(name: 'year_began') int? yearBegan,
    @JsonKey(name: 'publisher_name') String? publisherName,
    @JsonKey(name: 'desc') String? description,
    @JsonKey(name: 'series') String? seriesName, // Used by /api/series/
  }) = _SeriesDto;

  factory SeriesDto.fromJson(Map<String, dynamic> json) =>
      _$SeriesDtoFromJson(json);

  const SeriesDto._();

  Series toEntity() {
    return Series(
      id: id ?? 0,
      name: name ?? seriesName ?? 'Unknown Series',
      volume: volume,
      yearBegan: yearBegan,
      publisherName: publisherName,
      description: description,
    );
  }
}
