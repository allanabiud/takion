import "dart:convert";

class SyncCursorState {
  const SyncCursorState({
    this.watermark,
    this.nextUrl,
    this.scanId,
    this.scanStartedAt,
    this.extra = const {},
  });

  factory SyncCursorState.fromJson(Map<String, dynamic> json) {
    return SyncCursorState(
      watermark: json["watermark"] != null
          ? DateTime.tryParse(json["watermark"] as String)
          : null,
      nextUrl: json["nextUrl"] != null
          ? Uri.tryParse(json["nextUrl"] as String)
          : null,
      scanId: json["scanId"] as String?,
      scanStartedAt: json["scanStartedAt"] != null
          ? DateTime.tryParse(json["scanStartedAt"] as String)
          : null,
      extra: (json["extra"] as Map<String, dynamic>?) ?? const {},
    );
  }

  factory SyncCursorState.initial() => const SyncCursorState();

  final DateTime? watermark;
  final Uri? nextUrl;
  final String? scanId;
  final DateTime? scanStartedAt;
  final Map<String, dynamic> extra;

  bool get hasActiveScan => scanId != null;

  Map<String, dynamic> toJson() => {
    if (watermark != null) "watermark": watermark!.toUtc().toIso8601String(),
    if (nextUrl != null) "nextUrl": nextUrl.toString(),
    if (scanId != null) "scanId": scanId,
    if (scanStartedAt != null)
      "scanStartedAt": scanStartedAt!.toUtc().toIso8601String(),
    if (extra.isNotEmpty) "extra": extra,
  };

  String toJsonString() => jsonEncode(toJson());

  static SyncCursorState fromJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return SyncCursorState.initial();
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return SyncCursorState.fromJson(decoded);
    } catch (_) {
      return SyncCursorState.initial();
    }
  }

  SyncCursorState copyWith({
    DateTime? watermark,
    Uri? nextUrl,
    bool clearNextUrl = false,
    String? scanId,
    bool clearScanId = false,
    DateTime? scanStartedAt,
    bool clearScanStartedAt = false,
    Map<String, dynamic>? extra,
  }) {
    return SyncCursorState(
      watermark: watermark ?? this.watermark,
      nextUrl: clearNextUrl ? null : (nextUrl ?? this.nextUrl),
      scanId: clearScanId ? null : (scanId ?? this.scanId),
      scanStartedAt: clearScanStartedAt
          ? null
          : (scanStartedAt ?? this.scanStartedAt),
      extra: extra ?? this.extra,
    );
  }
}
