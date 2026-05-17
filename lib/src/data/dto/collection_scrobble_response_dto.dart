import 'package:takion/src/domain/entities/collection_scrobble_result.dart';

class CollectionScrobbleIssueRefDto {
  const CollectionScrobbleIssueRefDto({
    required this.id,
    this.seriesName,
    this.number,
  });

  final int id;
  final String? seriesName;
  final String? number;

  factory CollectionScrobbleIssueRefDto.fromJson(Map<String, dynamic> json) {
    return CollectionScrobbleIssueRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      seriesName: json['series_name'] as String?,
      number: json['number'] as String?,
    );
  }

  CollectionScrobbleIssueRef toEntity() {
    return CollectionScrobbleIssueRef(
      id: id,
      seriesName: seriesName,
      number: number,
    );
  }
}

class CollectionScrobbleResponseDto {
  const CollectionScrobbleResponseDto({
    required this.id,
    required this.issue,
    required this.isRead,
    this.dateRead,
    this.readDates = const [],
    required this.readCount,
    this.rating,
    required this.created,
    this.modified,
  });

  final int id;
  final CollectionScrobbleIssueRefDto issue;
  final bool isRead;
  final String? dateRead;
  final List<String> readDates;
  final int readCount;
  final int? rating;
  final bool created;
  final String? modified;

  factory CollectionScrobbleResponseDto.fromJson(Map<String, dynamic> json) {
    final rawReadDates = json['read_dates'];

    final parsedReadDates = <String>[];
    if (rawReadDates is List) {
      for (final entry in rawReadDates) {
        if (entry is String) {
          parsedReadDates.add(entry);
          continue;
        }

        if (entry is Map<String, dynamic>) {
          final readDate = entry['read_date'];
          if (readDate is String) {
            parsedReadDates.add(readDate);
          }
        }
      }
    }

    final issueJson = json['issue'];
    final issueDto = issueJson is Map<String, dynamic>
        ? CollectionScrobbleIssueRefDto.fromJson(issueJson)
        : const CollectionScrobbleIssueRefDto(id: 0);

    return CollectionScrobbleResponseDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      issue: issueDto,
      isRead: json['is_read'] as bool? ?? false,
      dateRead: json['date_read'] as String?,
      readDates: parsedReadDates,
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt(),
      created: json['created'] as bool? ?? false,
      modified: json['modified'] as String?,
    );
  }

  CollectionScrobbleResult toEntity() {
    return CollectionScrobbleResult(
      id: id,
      issue: issue.toEntity(),
      isRead: isRead,
      dateRead: dateRead != null ? DateTime.tryParse(dateRead!) : null,
      readDates: readDates
          .map(DateTime.tryParse)
          .whereType<DateTime>()
          .toList(),
      readCount: readCount,
      rating: rating,
      created: created,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
