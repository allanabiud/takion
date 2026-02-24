import 'package:takion/src/domain/entities/missing_series.dart';

class MissingSeriesNamedRefDto {
  const MissingSeriesNamedRefDto({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory MissingSeriesNamedRefDto.fromJson(Map<String, dynamic> json) {
    return MissingSeriesNamedRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  MissingSeriesNamedRef toEntity() => MissingSeriesNamedRef(id: id, name: name);
}

class MissingSeriesDto {
  const MissingSeriesDto({
    required this.id,
    required this.name,
    this.sortName,
    this.yearBegan,
    this.yearEnd,
    this.publisher,
    this.seriesType,
    required this.totalIssues,
    required this.ownedIssues,
    required this.missingCount,
    required this.completionPercentage,
  });

  final int id;
  final String name;
  final String? sortName;
  final int? yearBegan;
  final int? yearEnd;
  final MissingSeriesNamedRefDto? publisher;
  final MissingSeriesNamedRefDto? seriesType;
  final int totalIssues;
  final int ownedIssues;
  final int missingCount;
  final int completionPercentage;

  factory MissingSeriesDto.fromJson(Map<String, dynamic> json) {
    return MissingSeriesDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      sortName: json['sort_name'] as String?,
      yearBegan: (json['year_began'] as num?)?.toInt(),
      yearEnd: (json['year_end'] as num?)?.toInt(),
      publisher: json['publisher'] is Map
          ? MissingSeriesNamedRefDto.fromJson(
              (json['publisher'] as Map).cast<String, dynamic>(),
            )
          : null,
      seriesType: json['series_type'] is Map
          ? MissingSeriesNamedRefDto.fromJson(
              (json['series_type'] as Map).cast<String, dynamic>(),
            )
          : null,
      totalIssues: (json['total_issues'] as num?)?.toInt() ?? 0,
      ownedIssues: (json['owned_issues'] as num?)?.toInt() ?? 0,
      missingCount: (json['missing_count'] as num?)?.toInt() ?? 0,
      completionPercentage: (json['completion_percentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sort_name': sortName,
      'year_began': yearBegan,
      'year_end': yearEnd,
      'publisher': publisher?.toJson(),
      'series_type': seriesType?.toJson(),
      'total_issues': totalIssues,
      'owned_issues': ownedIssues,
      'missing_count': missingCount,
      'completion_percentage': completionPercentage,
    };
  }

  MissingSeries toEntity() {
    return MissingSeries(
      id: id,
      name: name,
      sortName: sortName,
      yearBegan: yearBegan,
      yearEnd: yearEnd,
      publisher: publisher?.toEntity(),
      seriesType: seriesType?.toEntity(),
      totalIssues: totalIssues,
      ownedIssues: ownedIssues,
      missingCount: missingCount,
      completionPercentage: completionPercentage,
    );
  }
}

class MissingSeriesResponseDto {
  const MissingSeriesResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<MissingSeriesDto> results;

  factory MissingSeriesResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
        .whereType<Map>()
        .map((entry) => entry.cast<String, dynamic>())
        .map(MissingSeriesDto.fromJson)
            .toList()
        : <MissingSeriesDto>[];

    return MissingSeriesResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((entry) => entry.toJson()).toList(),
    };
  }
}
