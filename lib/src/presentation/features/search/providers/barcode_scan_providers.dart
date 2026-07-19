import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/entities.dart';

const _scanHistoryKey = 'scan_history';

class ScanHistoryEntry {
  final String upc;
  final DateTime scannedAt;
  final int? issueId;
  final String? issueName;

  const ScanHistoryEntry({
    required this.upc,
    required this.scannedAt,
    this.issueId,
    this.issueName,
  });

  Map<String, dynamic> toJson() => {
    'upc': upc,
    'scannedAt': scannedAt.toIso8601String(),
    if (issueId != null) 'issueId': issueId,
    if (issueName != null) 'issueName': issueName,
  };

  factory ScanHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ScanHistoryEntry(
        upc: json['upc'] as String,
        scannedAt: DateTime.parse(json['scannedAt'] as String),
        issueId: json['issueId'] as int?,
        issueName: json['issueName'] as String?,
      );
}

class ScanHistoryNotifier extends Notifier<List<ScanHistoryEntry>> {
  @override
  List<ScanHistoryEntry> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<dynamic>(_settingsBoxName);
    final raw = box.get(_scanHistoryKey);
    if (raw is List) {
      state = raw
          .cast<Map<String, dynamic>>()
          .map((e) => ScanHistoryEntry.fromJson(e))
          .toList();
    }
  }

  Future<void> _persist() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<dynamic>(_settingsBoxName);
    await box.put(
      _scanHistoryKey,
      state.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> addEntry(ScanHistoryEntry entry) async {
    state = [
      entry,
      ...state.where((e) => e.upc != entry.upc),
    ];
    await _persist();
  }

  Future<void> removeEntryAt(int index) async {
    if (index < 0 || index >= state.length) return;
    state = [...state.take(index), ...state.skip(index + 1)];
    await _persist();
  }

  Future<void> clearAll() async {
    state = [];
    await _persist();
  }
}

class ScannedIssueState {
  final int issueId;
  final IssueList issue;

  const ScannedIssueState({required this.issueId, required this.issue});
}

class ScannedIssuesNotifier extends Notifier<List<ScannedIssueState>> {
  @override
  List<ScannedIssueState> build() => [];

  void addIssue(IssueList issue) {
    if (issue.id == null) return;
    final exists = state.any((s) => s.issueId == issue.id);
    if (exists) return;
    state = [...state, ScannedIssueState(issueId: issue.id!, issue: issue)];
  }

  void removeIssue(int issueId) {
    state = state.where((s) => s.issueId != issueId).toList();
  }

  void clearAll() {
    state = [];
  }

  List<int> get issueIds => state.map((s) => s.issueId).toList();
}

final scanHistoryProvider =
    NotifierProvider<ScanHistoryNotifier, List<ScanHistoryEntry>>(
  ScanHistoryNotifier.new,
);

final scannedIssueIdsProvider =
    NotifierProvider<ScannedIssuesNotifier, List<ScannedIssueState>>(
  ScannedIssuesNotifier.new,
);

const _settingsBoxName = 'settings_box';
