import 'package:takion/src/domain/entities/series_details.dart';

class SeriesDetailsNamedRefDto {
  const SeriesDetailsNamedRefDto({required this.id, required this.name});

  final int id;
  final String name;

  factory SeriesDetailsNamedRefDto.fromJson(Map<String, dynamic> json) {
    return SeriesDetailsNamedRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  SeriesDetailsNamedRef toEntity() => SeriesDetailsNamedRef(id: id, name: name);
}

class SeriesDetailsAssociatedDto {
  const SeriesDetailsAssociatedDto({required this.id, required this.series});

  final int id;
  final String series;

  factory SeriesDetailsAssociatedDto.fromJson(Map<String, dynamic> json) {
    return SeriesDetailsAssociatedDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      series: (json['series'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'series': series,
      };

  SeriesDetailsAssociated toEntity() =>
      SeriesDetailsAssociated(id: id, series: series);
}

class SeriesDetailsDto {
  const SeriesDetailsDto({
    required this.id,
    required this.name,
    this.sortName,
    this.volume,
    this.seriesType,
    this.status,
    this.publisher,
    this.imprint,
    this.yearBegan,
    this.yearEnd,
    this.description,
    this.issueCount,
    this.genres = const [],
    this.associated = const [],
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String? sortName;
  final int? volume;
  final SeriesDetailsNamedRefDto? seriesType;
  final String? status;
  final SeriesDetailsNamedRefDto? publisher;
  final SeriesDetailsNamedRefDto? imprint;
  final int? yearBegan;
  final int? yearEnd;
  final String? description;
  final int? issueCount;
  final List<SeriesDetailsNamedRefDto> genres;
  final List<SeriesDetailsAssociatedDto> associated;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;

  factory SeriesDetailsDto.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'];
    final rawAssociated = json['associated'];

    return SeriesDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      sortName: json['sort_name'] as String?,
      volume: (json['volume'] as num?)?.toInt(),
      seriesType: json['series_type'] is Map<String, dynamic>
          ? SeriesDetailsNamedRefDto.fromJson(
              json['series_type'] as Map<String, dynamic>,
            )
          : null,
      status: json['status'] as String?,
      publisher: json['publisher'] is Map<String, dynamic>
          ? SeriesDetailsNamedRefDto.fromJson(
              json['publisher'] as Map<String, dynamic>,
            )
          : null,
      imprint: json['imprint'] is Map<String, dynamic>
          ? SeriesDetailsNamedRefDto.fromJson(
              json['imprint'] as Map<String, dynamic>,
            )
          : null,
      yearBegan: (json['year_began'] as num?)?.toInt(),
      yearEnd: (json['year_end'] as num?)?.toInt(),
      description: json['desc'] as String?,
      issueCount: (json['issue_count'] as num?)?.toInt(),
      genres: rawGenres is List
          ? rawGenres
              .whereType<Map<String, dynamic>>()
              .map(SeriesDetailsNamedRefDto.fromJson)
              .toList()
          : const [],
      associated: rawAssociated is List
          ? rawAssociated
              .whereType<Map<String, dynamic>>()
              .map(SeriesDetailsAssociatedDto.fromJson)
              .toList()
          : const [],
      cvId: (json['cv_id'] as num?)?.toInt(),
      gcdId: (json['gcd_id'] as num?)?.toInt(),
      resourceUrl: json['resource_url'] as String?,
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sort_name': sortName,
        'volume': volume,
        'series_type': seriesType?.toJson(),
        'status': status,
        'publisher': publisher?.toJson(),
        'imprint': imprint?.toJson(),
        'year_began': yearBegan,
        'year_end': yearEnd,
        'desc': description,
        'issue_count': issueCount,
        'genres': genres.map((entry) => entry.toJson()).toList(),
        'associated': associated.map((entry) => entry.toJson()).toList(),
        'cv_id': cvId,
        'gcd_id': gcdId,
        'resource_url': resourceUrl,
        'modified': modified,
      };

  SeriesDetails toEntity() {
    return SeriesDetails(
      id: id,
      name: name,
      sortName: sortName,
      volume: volume,
      seriesType: seriesType?.toEntity(),
      status: status,
      publisher: publisher?.toEntity(),
      imprint: imprint?.toEntity(),
      yearBegan: yearBegan,
      yearEnd: yearEnd,
      description: description,
      issueCount: issueCount,
      genres: genres.map((entry) => entry.toEntity()).toList(),
      associated: associated.map((entry) => entry.toEntity()).toList(),
      cvId: cvId,
      gcdId: gcdId,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
