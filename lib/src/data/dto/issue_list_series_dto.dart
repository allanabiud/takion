import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:takion/src/domain/entities/series.dart';

part 'issue_list_series_dto.freezed.dart';
part 'issue_list_series_dto.g.dart';

@freezed
@HiveType(typeId: 3) // Assign a new HiveType ID
abstract class IssueListSeriesDto with _$IssueListSeriesDto {
  const factory IssueListSeriesDto({
    @HiveField(0) required String name,
    @HiveField(1) required int volume,
    @HiveField(2) @JsonKey(name: 'year_began') required int yearBegan,
  }) = _IssueListSeriesDto;

  factory IssueListSeriesDto.fromJson(Map<String, dynamic> json) => _$IssueListSeriesDtoFromJson(json);

  const IssueListSeriesDto._();

  Series toEntity() {
    return Series(
      id: 0,
      name: name,
      volume: volume,
      yearBegan: yearBegan,
    );
  }
}
