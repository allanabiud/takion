import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:takion/src/domain/entities.dart';

part 'issue_list_series_dto.freezed.dart';
part 'issue_list_series_dto.g.dart';

@freezed
abstract class IssueListSeriesDto with _$IssueListSeriesDto {
  const factory IssueListSeriesDto({
    required String name,
    required int volume,
    @JsonKey(name: 'year_began') required int yearBegan,
    int? id,
  }) = _IssueListSeriesDto;

  factory IssueListSeriesDto.fromJson(Map<String, dynamic> json) =>
      _$IssueListSeriesDtoFromJson(json);

  const IssueListSeriesDto._();

  Series toEntity() {
    return Series(
      id: id ?? 0,
      name: name,
      volume: volume,
      yearBegan: yearBegan,
    );
  }
}
