import "package:takion/src/domain/collection/entities/missing_issue.dart";

class MissingIssueDto {
  const MissingIssueDto({
    required this.id,
    required this.seriesId,
    required this.seriesName,
    required this.issueNumber,
    this.coverDate,
    this.storeDate,
    this.imageUrl,
  });

  final int id;
  final int seriesId;
  final String seriesName;
  final String issueNumber;
  final String? coverDate;
  final String? storeDate;
  final String? imageUrl;

  factory MissingIssueDto.fromJson(Map<String, dynamic> json) {
    final seriesMap = json["series"] as Map<String, dynamic>? ?? {};

    return MissingIssueDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      seriesId: (seriesMap["id"] as num?)?.toInt() ?? (json["series_id"] as num?)?.toInt() ?? 0,
      seriesName: seriesMap["name"] as String? ?? "Unknown Series",
      issueNumber: json["number"] as String? ?? "",
      coverDate: json["cover_date"] as String?,
      storeDate: json["store_date"] as String?,
      imageUrl: json["image"] as String?,
    );
  }

  MissingIssue toEntity() {
    return MissingIssue(
      id: id,
      seriesId: seriesId,
      seriesName: seriesName,
      issueNumber: issueNumber,
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      imageUrl: imageUrl,
    );
  }
}

class MissingSeriesDto {
  const MissingSeriesDto({
    required this.id,
    required this.name,
    this.volume,
    this.yearBegan,
    this.totalIssues,
    this.missingCount,
    this.imageUrl,
  });

  final int id;
  final String name;
  final int? volume;
  final int? yearBegan;
  final int? totalIssues;
  final int? missingCount;
  final String? imageUrl;

  factory MissingSeriesDto.fromJson(Map<String, dynamic> json) {
    return MissingSeriesDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: json["name"] as String? ?? "Unknown Series",
      volume: (json["volume"] as num?)?.toInt(),
      yearBegan: (json["year_began"] as num?)?.toInt(),
      totalIssues: (json["total_issues"] as num?)?.toInt(),
      missingCount: (json["missing_count"] as num?)?.toInt(),
      imageUrl: json["image"] as String?,
    );
  }

  MissingSeries toEntity() {
    return MissingSeries(
      id: id,
      name: name,
      volume: volume,
      yearBegan: yearBegan,
      totalIssues: totalIssues,
      missingCount: missingCount,
      imageUrl: imageUrl,
    );
  }
}
