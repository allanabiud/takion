import "package:takion/src/data/common/drift/database.dart" as db;

class SeriesNameIndex {
  SeriesNameIndex(this._database);

  final db.AppDatabase _database;

  Future<void> add(String name) async {
    final normalized = _normalize(name);
    if (normalized.isEmpty) return;
    await _database.seriesNameDao.add(normalized, name);
  }

  Future<void> addAll(Iterable<String> names) async {
    final entries = names
        .map((n) {
          final normalized = _normalize(n);
          if (normalized.isEmpty) return null;
          return (normalized: normalized, original: n);
        })
        .nonNulls
        .toList();
    if (entries.isEmpty) return;
    await _database.seriesNameDao.addAll(entries);
  }

  Future<String?> fuzzyMatch(String query, {int maxEditDistance = 2}) async {
    final cleaned = _cleanQuery(query);
    if (cleaned.isEmpty) return null;
    final results = await _database.seriesNameDao.getAll();
    return _bestMatch(
      cleaned,
      results.map((d) => d.originalName),
      maxEditDistance,
    );
  }

  String? _bestMatch(
    String query,
    Iterable<String> candidates,
    int maxEditDistance,
  ) {
    final queryTokens = _tokenize(query);
    String? bestMatch;
    int bestScore = -1;

    for (final candidate in candidates) {
      final candidateTokens = _tokenize(candidate);
      int score = 0;
      for (final qt in queryTokens) {
        int bestTokenScore = 0;
        for (final ct in candidateTokens) {
          final dist = _levenshtein(qt, ct);
          if (dist <= maxEditDistance) {
            final tokenScore = (qt.length - dist) * 10;
            if (tokenScore > bestTokenScore) {
              bestTokenScore = tokenScore;
            }
          }
        }
        if (bestTokenScore == 0) {
          score = 0;
          break;
        }
        score += bestTokenScore;
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = candidate;
      }
    }

    return bestScore > 0 ? bestMatch : null;
  }

  String _cleanQuery(String query) {
    return query.trim().toLowerCase().replaceAll(RegExp(r"[^\w\s]"), "");
  }

  List<String> _tokenize(String name) {
    return _cleanQuery(
      name,
    ).split(RegExp(r"\s+")).where((t) => t.length >= 2).toList();
  }

  String _normalize(String name) {
    return _cleanQuery(name).replaceAll(RegExp(r"\s+"), "");
  }

  int _levenshtein(String a, String b) {
    if (a.length < b.length) {
      final tmp = a;
      a = b;
      b = tmp;
    }
    if (b.isEmpty) return a.length;

    final prev = List<int>.generate(b.length + 1, (i) => i);
    final curr = List<int>.filled(b.length + 1, 0);

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
      for (var j = 0; j <= b.length; j++) {
        prev[j] = curr[j];
      }
    }
    return curr[b.length];
  }
}
