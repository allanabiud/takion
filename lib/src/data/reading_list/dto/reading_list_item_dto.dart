import 'package:takion/src/domain/entities.dart';

class ReadingListItemDto {
  const ReadingListItemDto({
    required this.id,
    required this.issueId,
    this.seriesId,
    this.seriesName,
    this.seriesVolume,
    this.yearBegan,
    this.issueNumber,
    this.coverDate,
    this.storeDate,
    this.cvId,
    this.gcdId,
    this.order,
    this.issueType,
  });

  final int id;
  final int issueId;
  final int? seriesId;
  final String? seriesName;
  final int? seriesVolume;
  final int? yearBegan;
  final String? issueNumber;
  final String? coverDate;
  final String? storeDate;
  final int? cvId;
  final int? gcdId;
  final int? order;
  final String? issueType;

  factory ReadingListItemDto.fromJson(Map<String, dynamic> json) {
    final issue = json['issue'] as Map<String, dynamic>?;
    final series = issue?['series'] as Map<String, dynamic>?;

    return ReadingListItemDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      issueId: (issue?['id'] as num?)?.toInt() ?? 0,
      seriesId: (series?['id'] as num?)?.toInt(),
      seriesName: series?['name'] as String?,
      seriesVolume: (series?['volume'] as num?)?.toInt(),
      yearBegan: (series?['year_began'] as num?)?.toInt(),
      issueNumber: issue?['number'] as String?,
      coverDate: issue?['cover_date'] as String?,
      storeDate: issue?['store_date'] as String?,
      cvId: (issue?['cv_id'] as num?)?.toInt(),
      gcdId: (issue?['gcd_id'] as num?)?.toInt(),
      order: (json['order'] as num?)?.toInt(),
      issueType: json['issue_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'issue': {
      'id': issueId,
      'series': {
        'id': seriesId,
        'name': seriesName,
        'volume': seriesVolume,
        'year_began': yearBegan,
      },
      'number': issueNumber,
      'cover_date': coverDate,
      'store_date': storeDate,
      'cv_id': cvId,
      'gcd_id': gcdId,
    },
    'order': order,
    'issue_type': issueType,
  };

  MetronReadingListItem toEntity() {
    return MetronReadingListItem(
      id: id,
      issueId: issueId,
      seriesId: seriesId,
      seriesName: seriesName,
      seriesVolume: seriesVolume,
      yearBegan: yearBegan,
      issueNumber: issueNumber,
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      order: order ?? 0,
      issueType: issueType,
    );
  }
}
