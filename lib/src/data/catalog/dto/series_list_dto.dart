import "package:takion/src/domain/entities.dart";

class SeriesListDto {
  const SeriesListDto({
    required this.id,
    required this.series,
    this.yearBegan,
    this.yearEnd,
    this.volume,
    this.issueCount,
    this.modified,
  });

  final int id;
  final String series;
  final int? yearBegan;
  final int? yearEnd;
  final int? volume;
  final int? issueCount;
  final String? modified;

  factory SeriesListDto.fromJson(Map<String, dynamic> json) {
    return SeriesListDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      series: (json["series"] as String?)?.trim().isNotEmpty == true
          ? (json["series"] as String)
          : "Unknown Series",
      yearBegan: (json["year_began"] as num?)?.toInt(),
      yearEnd: (json["year_end"] as num?)?.toInt(),
      volume: (json["volume"] as num?)?.toInt(),
      issueCount: (json["issue_count"] as num?)?.toInt(),
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "series": series,
      "year_began": yearBegan,
      "year_end": yearEnd,
      "volume": volume,
      "issue_count": issueCount,
      "modified": modified,
    };
  }

  SeriesList toEntity() {
    return SeriesList(
      id: id,
      name: series,
      yearBegan: yearBegan,
      yearEnd: yearEnd,
      volume: volume,
      issueCount: issueCount,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
