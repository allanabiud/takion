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
    this.publisherName,
    this.seriesType,
    this.cvId,
    this.gcdId,
  });

  final int id;
  final String series;
  final int? yearBegan;
  final int? yearEnd;
  final int? volume;
  final int? issueCount;
  final String? modified;
  final String? publisherName;
  final String? seriesType;
  final int? cvId;
  final int? gcdId;

  factory SeriesListDto.fromJson(Map<String, dynamic> json) {
    final publisherObj = json["publisher"];
    final publisherName = publisherObj is Map<String, dynamic>
        ? publisherObj["name"] as String?
        : publisherObj is String
        ? publisherObj
        : null;

    final seriesTypeObj = json["series_type"];
    final seriesTypeName = seriesTypeObj is Map<String, dynamic>
        ? seriesTypeObj["name"] as String?
        : seriesTypeObj is String
        ? seriesTypeObj
        : null;

    return SeriesListDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      series: (json["series"] as String?)?.trim().isNotEmpty == true
          ? (json["series"] as String)
          : (json["name"] as String?)?.trim().isNotEmpty == true
          ? (json["name"] as String)
          : "Unknown Series",
      yearBegan: (json["year_began"] as num?)?.toInt(),
      yearEnd: (json["year_end"] as num?)?.toInt(),
      volume: (json["volume"] as num?)?.toInt(),
      issueCount: (json["issue_count"] as num?)?.toInt(),
      modified: json["modified"] as String?,
      publisherName: publisherName,
      seriesType: seriesTypeName,
      cvId: (json["cv_id"] as num?)?.toInt(),
      gcdId: (json["gcd_id"] as num?)?.toInt(),
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
      if (publisherName != null) "publisher": {"name": publisherName},
      if (seriesType != null) "series_type": {"name": seriesType},
      if (cvId != null) "cv_id": cvId,
      if (gcdId != null) "gcd_id": gcdId,
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
      seriesType: seriesType,
      publisherName: publisherName,
      cvId: cvId,
      gcdId: gcdId,
    );
  }
}
