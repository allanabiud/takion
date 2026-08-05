import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/common/drift/daos/superhero_character_cache_dao.dart';
import 'package:takion/src/data/integrations/superhero/dto/superhero_search_response_dto.dart';
import 'package:takion/src/data/integrations/superhero/superhero_remote_data_source.dart';
import 'package:takion/src/domain/integrations/entities/entities.dart';
import 'package:takion/src/domain/integrations/repositories/repositories.dart';

String normalizeSuperHeroName(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
}

class SuperHeroCharacterRepositoryImpl
    implements SuperHeroCharacterRepository {
  SuperHeroCharacterRepositoryImpl({
    required SuperHeroRemoteDataSource remoteDataSource,
    required SuperheroCharacterCacheDao cacheDao,
    required Future<String?> Function() getToken,
  })  : _remoteDataSource = remoteDataSource,
        _cacheDao = cacheDao,
        _getToken = getToken;

  static const Duration _cacheTtl = Duration(days: 7);

  final SuperHeroRemoteDataSource _remoteDataSource;
  final SuperheroCharacterCacheDao _cacheDao;
  final Future<String?> Function() _getToken;

  String _cleanName(String name) {
    return name.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  }

  List<String> _generateSearchVariants(
    String metronName, {
    String? metronAlias,
  }) {
    final variants = <String>[];

    void addQuery(String q) {
      final trimmed = q.trim();
      if (trimmed.isNotEmpty && !variants.contains(trimmed)) {
        variants.add(trimmed);
      }
    }

    // 1. Cleaned name without parentheses, e.g. "General Zod (Dru-Zod)" -> "General Zod"
    final clean = metronName.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
    if (clean.isNotEmpty) addQuery(clean);

    // 2. Metron alias if provided, e.g. "Batman" for "Terry McGinnis"
    if (metronAlias != null && metronAlias.trim().isNotEmpty) {
      final cleanAlias =
          metronAlias.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
      addQuery(cleanAlias);
    }

    // 3. Parenthetical name inside brackets if present, e.g. "Dru-Zod" or "Peter Parker"
    final parenMatch = RegExp(r'\(([^)]+)\)').firstMatch(metronName);
    if (parenMatch != null) {
      final paren = parenMatch.group(1)?.trim();
      if (paren != null) addQuery(paren);
    }

    // 4. Hyphen variants for cleaned name, e.g. "Spider-Man" -> "Spider Man"
    if (clean.contains('-')) {
      addQuery(clean.replaceAll('-', ' '));
      addQuery(clean.replaceAll('-', ''));
    }

    // 5. Strip "The " prefix, e.g. "The Flash" -> "Flash", "The Batman" -> "Batman"
    if (clean.toLowerCase().startsWith('the ')) {
      addQuery(clean.substring(4));
    }

    // 6. Expand / abbreviate "Doctor" vs "Dr."
    if (clean.toLowerCase().startsWith('dr. ') || clean.toLowerCase().startsWith('dr ')) {
      addQuery(
        clean.replaceAll(RegExp(r'^dr\.?\s+', caseSensitive: false), 'Doctor '),
      );
    } else if (clean.toLowerCase().startsWith('doctor ')) {
      addQuery(
        clean.replaceAll(RegExp(r'^doctor\s+', caseSensitive: false), 'Dr. '),
      );
    }

    // 7. Original metronName
    addQuery(metronName);

    return variants;
  }

  int _scoreCandidate(
    SuperHeroCharacterDto candidate,
    String metronName,
    String cleanName,
    String? parentheticalName,
    String? metronAlias,
  ) {
    int score = 0;
    final candNorm = normalizeSuperHeroName(candidate.name);
    final candFullNorm =
        candidate.fullName != null ? normalizeSuperHeroName(candidate.fullName!) : null;
    final cleanNorm = normalizeSuperHeroName(cleanName);
    final fullNorm = normalizeSuperHeroName(metronName);
    final parenNorm =
        parentheticalName != null ? normalizeSuperHeroName(parentheticalName) : null;
    final aliasNorm =
        metronAlias != null ? normalizeSuperHeroName(metronAlias) : null;

    // Full-Name matching (SuperHero API biography full-name matches Metron name, e.g. "Terry McGinnis")
    if (candFullNorm != null && candFullNorm.isNotEmpty) {
      if (candFullNorm == cleanNorm || candFullNorm == fullNorm) {
        score += 350;
      } else if (parenNorm != null && candFullNorm == parenNorm) {
        score += 300;
      }
    }

    // Candidate superhero name matching
    if (cleanNorm.isNotEmpty && candNorm == cleanNorm) {
      score += 250;
    } else if (fullNorm.isNotEmpty && candNorm == fullNorm) {
      score += 230;
    } else if (aliasNorm != null && aliasNorm.isNotEmpty && candNorm == aliasNorm) {
      score += 250;
    } else if (parenNorm != null && parenNorm.isNotEmpty && candNorm == parenNorm) {
      score += 200;
    } else if (cleanNorm.isNotEmpty &&
        (candNorm.startsWith(cleanNorm) || cleanNorm.startsWith(candNorm))) {
      score += 130;
    } else if (cleanNorm.isNotEmpty &&
        (candNorm.contains(cleanNorm) || cleanNorm.contains(candNorm))) {
      score += 80;
    } else {
      score += 20;
    }

    // SuperHero API biography aliases matching
    for (final candAlias in candidate.aliases) {
      final candAliasNorm = normalizeSuperHeroName(candAlias);
      if (candAliasNorm.isNotEmpty &&
          (candAliasNorm == cleanNorm || candAliasNorm == fullNorm)) {
        score += 200;
        break;
      }
    }

    // Powerstats scoring (up to +600 points) to heavily favor candidates with actual powerstats!
    final validStats = candidate.powerstats?.validStatsCount ?? 0;
    score += validStats * 100;

    return score;
  }

  @override
  Future<SuperHeroCharacter?> getCharacter(
    int metronCharacterId,
    String metronName, {
    String? metronAlias,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _cacheDao.getByMetronCharacterId(
        metronCharacterId,
      );
      if (cached != null &&
          DateTime.now().difference(cached.updatedAt) < _cacheTtl) {
        AppLogger.info(
          'SuperHero cache hit for "$metronName" (ID: $metronCharacterId, StatsJson: ${cached.powerstatsJson})',
        );
        return _fromCache(cached);
      }
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      AppLogger.warning('SuperHero search skipped: missing API token');
      return null;
    }

    final searchQueries = _generateSearchVariants(
      metronName,
      metronAlias: metronAlias,
    );
    final cleanName = _cleanName(metronName);
    final parentheticalName =
        RegExp(r'\(([^)]+)\)').firstMatch(metronName)?.group(1)?.trim();

    AppLogger.info(
      'SuperHero searching API for character "$metronName" (alias: "$metronAlias") with variants: $searchQueries',
    );

    SuperHeroCharacterDto? bestCandidate;
    int bestScore = -1;

    try {
      for (final query in searchQueries) {
        final result = await _remoteDataSource.search(token, query);
        if (result.response != 'success' || result.results.isEmpty) {
          continue;
        }

        for (final candidate in result.results) {
          final score = _scoreCandidate(
            candidate,
            metronName,
            cleanName,
            parentheticalName,
            metronAlias,
          );
          if (score > bestScore) {
            bestScore = score;
            bestCandidate = candidate;
          }
        }

        // If we found a candidate with valid powerstats and high match score, we can stop querying
        final validStats = bestCandidate?.powerstats?.validStatsCount ?? 0;
        if (validStats >= 3 && bestScore >= 350) {
          AppLogger.info(
            'SuperHero candidate "${bestCandidate?.name}" (full-name: "${bestCandidate?.fullName}") matched with $validStats valid stats on variant "$query"',
          );
          break;
        }
      }

      if (bestCandidate == null) {
        AppLogger.warning(
          'SuperHero search yielded no candidates across variants for "$metronName"',
        );
        return null;
      }

      final match = bestCandidate.toEntity();
      AppLogger.info(
        'SuperHero found match for "$metronName": ID ${match.id}, name "${match.name}", validStats: ${match.powerstats?.validStatsCount ?? 0}',
      );

      await _cacheDao.upsert(
        SuperheroCharacterCacheCompanion.insert(
          metronCharacterId: Value(metronCharacterId),
          superheroId: match.id,
          superheroName: match.name,
          imageUrl: Value(match.imageUrl),
          powerstatsJson: Value(
            match.powerstats != null
                ? _powerstatsToJson(match.powerstats!)
                : null,
          ),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      return match;
    } on Exception catch (e) {
      AppLogger.warning(
        'SuperHero search failed for "$metronName"',
        error: e,
      );
      return null;
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      final result = await _remoteDataSource.search(token.trim(), 'batman');
      return result.response == 'success';
    } on Exception catch (e) {
      AppLogger.warning('SuperHero token validation failed', error: e);
      return false;
    }
  }

  SuperHeroCharacter? _fromCache(SuperheroCharacterCacheData cached) {
    return SuperHeroCharacter(
      id: cached.superheroId,
      name: cached.superheroName,
      imageUrl: cached.imageUrl,
      powerstats: _powerstatsFromJson(cached.powerstatsJson),
    );
  }

  String? _powerstatsToJson(SuperHeroPowerStats stats) {
    return '{"intelligence":${stats.intelligence ?? "null"},'
        '"strength":${stats.strength ?? "null"},'
        '"speed":${stats.speed ?? "null"},'
        '"durability":${stats.durability ?? "null"},'
        '"power":${stats.power ?? "null"},'
        '"combat":${stats.combat ?? "null"}}';
  }

  SuperHeroPowerStats? _powerstatsFromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    final map = jsonDecodeSafe(json);
    if (map == null) return null;

    int? parseStat(dynamic value) {
      if (value is int) return value;
      if (value is String && value.trim().isNotEmpty) {
        final lower = value.trim().toLowerCase();
        if (lower == 'null') return null;
        return int.tryParse(lower);
      }
      return null;
    }

    return SuperHeroPowerStats(
      intelligence: parseStat(map['intelligence']),
      strength: parseStat(map['strength']),
      speed: parseStat(map['speed']),
      durability: parseStat(map['durability']),
      power: parseStat(map['power']),
      combat: parseStat(map['combat']),
    );
  }
}

Map<String, dynamic>? jsonDecodeSafe(String json) {
  try {
    return Map<String, dynamic>.from(
      (jsonDecode(json) as Map).cast<String, dynamic>(),
    );
  } catch (_) {
    return null;
  }
}
