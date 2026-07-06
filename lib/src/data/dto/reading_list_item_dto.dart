import 'package:takion/src/domain/entities/metron_reading_list_item.dart';

class ReadingListItemDto {
  const ReadingListItemDto({
    required this.id,
    required this.issueId,
    this.seriesId,
    this.seriesName,
    this.seriesVolume,
    this.issueNumber,
    this.coverDate,
    this.storeDate,
    this.order,
    this.issueType,
  });

  final int id;
  final int issueId;
  final int? seriesId;
  final String? seriesName;
  final int? seriesVolume;
  final String? issueNumber;
  final String? coverDate;
  final String? storeDate;
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
      issueNumber: issue?['number'] as String?,
      coverDate: issue?['cover_date'] as String?,
      storeDate: issue?['store_date'] as String?,
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
      },
      'number': issueNumber,
      'cover_date': coverDate,
      'store_date': storeDate,
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
      issueNumber: issueNumber,
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      order: order ?? 0,
      issueType: issueType,
    );
  }
}
