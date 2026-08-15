import "package:freezed_annotation/freezed_annotation.dart";
import "package:takion/src/domain/entities.dart";

part "issue_list_series_dto.freezed.dart";

@freezed
abstract class IssueListSeriesDto with _$IssueListSeriesDto {
  const factory IssueListSeriesDto({
    required String name,
    required int volume,
    @JsonKey(name: "year_began") required int yearBegan,
    int? id,
  }) = _IssueListSeriesDto;

  factory IssueListSeriesDto.fromJson(Map<String, dynamic> json) {
    return IssueListSeriesDto(
      name: json["name"]?.toString() ?? "",
      volume: (json["volume"] as num?)?.toInt() ?? 1,
      yearBegan: (json["year_began"] as num?)?.toInt() ?? 0,
      id: (json["id"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "volume": volume,
      "year_began": yearBegan,
      "id": id,
    };
  }

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
