import 'package:hive_ce/hive_ce.dart';
import 'package:takion/src/core/storage/hive_service.dart';

class SeriesNameIndex {
  final HiveService _hiveService;
  static const String _boxName = 'series_name_index_box';

  SeriesNameIndex(this._hiveService);

  Box<String>? _cachedBox;

  Future<Box<String>> _getBox() async {
    if (_cachedBox != null && _cachedBox!.isOpen) return _cachedBox!;
    final box = await _hiveService.openBox<String>(_boxName);
    _cachedBox = box;
    return box;
  }

  Future<void> add(String name) async {
    final normalized = _normalize(name);
    if (normalized.isEmpty) return;
    final box = await _getBox();
    if (!box.containsKey(normalized)) {
      await box.put(normalized, name);
    }
  }

  Future<void> addAll(Iterable<String> names) async {
    for (final name in names) {
      await add(name);
    }
  }

  String? _bestMatch(String cleaned, Iterable<String> stored) {
    if (cleaned.isEmpty) return null;

    final queryTokens = _tokenize(cleaned);
    if (queryTokens.isEmpty) return null;

    String? bestMatch;
    var bestDistance = 3;

    for (final storedValue in stored) {
      final normalized = _normalize(storedValue);
      if (normalized.isEmpty) continue;

      // Quick check: do query tokens overlap with stored name tokens?
      final storedTokens = _tokenize(normalized);
      final overlap = queryTokens.where((t) => storedTokens.contains(t)).length;
      final overlapRatio = queryTokens.isNotEmpty
          ? overlap / queryTokens.length
          : 0.0;

      if (overlapRatio < 0.5) continue;

      // Levenshtein on the full strings
      final distance = _levenshtein(cleaned, normalized);
      if (distance <= bestDistance) {
        bestDistance = distance;
        bestMatch = storedValue;
      }
    }

    return bestMatch;
  }

  Future<String?> fuzzyMatch(String query, {int maxEditDistance = 2}) async {
    final cleaned = _cleanQuery(query);
    final box = await _getBox();
    return _bestMatch(cleaned, box.values);
  }

  String _cleanQuery(String query) {
    return query
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _tokenize(String cleaned) {
    return cleaned
        .split(' ')
        .map((t) => t.trim())
        .where((t) => t.length >= 2)
        .toList();
  }

  static String _normalize(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int _levenshtein(String a, String b) {
    if (a.length < b.length) {
      final tmp = a;
      a = b;
      b = tmp;
    }

    var prev = List.generate(b.length + 1, (i) => i);
    var curr = List.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        curr[j + 1] = [
          curr[j] + 1,
          prev[j + 1] + 1,
          prev[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }

    return prev[b.length];
  }
}
