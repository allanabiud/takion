import "package:takion/src/domain/collection/entities/scrobble_result.dart";

class ScrobbleRequestDto {
  const ScrobbleRequestDto({
    required this.issueId,
    this.dateRead,
    this.rating,
  });

  final int issueId;
  final String? dateRead;
  final int? rating;

  Map<String, dynamic> toJson() => {
    "issue_id": issueId,
    if (dateRead != null) "date_read": dateRead,
    if (rating != null) "rating": rating,
  };
}

class ScrobbleResponseDto {
  const ScrobbleResponseDto({
    required this.id,
    required this.isRead,
    this.dateRead,
    this.modified,
  });

  final int id;
  final bool isRead;
  final String? dateRead;
  final String? modified;

  factory ScrobbleResponseDto.fromJson(Map<String, dynamic> json) {
    return ScrobbleResponseDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      isRead: json["is_read"] as bool? ?? true,
      dateRead: json["date_read"] as String?,
      modified: json["modified"] as String?,
    );
  }

  ScrobbleResult toEntity() {
    return ScrobbleResult(
      id: id,
      isRead: isRead,
      dateRead: dateRead != null ? DateTime.tryParse(dateRead!) : null,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
