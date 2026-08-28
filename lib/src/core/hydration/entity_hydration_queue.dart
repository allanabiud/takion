import "dart:async";
import "dart:collection";

import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/entity_image_cache.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/core/network/request_priority.dart"
    show backgroundZoneKey;
import "package:takion/src/presentation/providers/connectivity_provider.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

/// Entity types supported by the catalog hydration queue.
enum HydrationEntityType {
  series,
  issue,
  publisher,
  character,
  creator,
  team,
  arc,
  imprint,
  universe,
}

/// Hydration lifecycle state for a given entity key.
enum HydrationStatus {
  queued,
  inFlight,
  succeeded,
  failed,
  notFound,
}

/// Unique key representing an entity hydration task.
class HydrationKey {
  const HydrationKey(this.type, this.id);

  final HydrationEntityType type;
  final int id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HydrationKey &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => "${type.name}:$id";
}

/// Aggregate metrics for the hydration queue.
class HydrationQueueStats {
  const HydrationQueueStats({
    this.queuedCount = 0,
    this.inFlightCount = 0,
    this.succeededCount = 0,
    this.failedCount = 0,
  });

  final int queuedCount;
  final int inFlightCount;
  final int succeededCount;
  final int failedCount;

  @override
  String toString() =>
      "HydrationQueueStats(queued: $queuedCount, inFlight: $inFlightCount, succeeded: $succeededCount, failed: $failedCount)";
}

/// Deduplicating background hydration queue that resolves missing entity metadata
/// with controlled concurrency, rate-limit awareness, exponential backoff, and caching.
class EntityHydrationQueue {
  EntityHydrationQueue(
    this._ref, {
    this.maxConcurrency = 2,
    this.minBurstRemaining = 3,
    this.maxRetryAttempts = 3,
    this.baseRetryDelay = const Duration(seconds: 15),
  });

  final Ref _ref;
  final int maxConcurrency;
  final int minBurstRemaining;
  final int maxRetryAttempts;
  final Duration baseRetryDelay;

  final Queue<HydrationKey> _queue = Queue<HydrationKey>();
  final Set<HydrationKey> _queuedSet = <HydrationKey>{};
  final Set<HydrationKey> _inFlight = <HydrationKey>{};
  final Map<HydrationKey, int> _retryAttempts = <HydrationKey, int>{};
  final Map<HydrationKey, HydrationStatus> _statuses =
      <HydrationKey, HydrationStatus>{};

  Timer? _drainTimer;
  bool _isDraining = false;
  int _succeededCount = 0;
  int _failedCount = 0;

  HydrationStatus getStatus(HydrationEntityType type, int id) {
    return _statuses[HydrationKey(type, id)] ?? HydrationStatus.notFound;
  }

  HydrationQueueStats get stats => HydrationQueueStats(
    queuedCount: _queue.length,
    inFlightCount: _inFlight.length,
    succeededCount: _succeededCount,
    failedCount: _failedCount,
  );

  /// Enqueue an entity for background hydration.
  bool enqueue(HydrationEntityType type, int id) {
    if (id <= 0) return false;
    final key = HydrationKey(type, id);

    // Skip if already in flight, queued, or marked permanent not-found.
    if (_inFlight.contains(key) ||
        _queuedSet.contains(key) ||
        _statuses[key] == HydrationStatus.notFound ||
        _statuses[key] == HydrationStatus.succeeded) {
      return false;
    }

    _queue.add(key);
    _queuedSet.add(key);
    _statuses[key] = HydrationStatus.queued;
    _scheduleDrain();
    return true;
  }

  /// Enqueue multiple entity IDs of the same type.
  int enqueueMany(HydrationEntityType type, Iterable<int> ids) {
    var added = 0;
    for (final id in ids) {
      if (enqueue(type, id)) {
        added++;
      }
    }
    return added;
  }

  void _scheduleDrain([Duration delay = Duration.zero]) {
    if (_isDraining) return;
    _drainTimer?.cancel();
    if (delay == Duration.zero) {
      Future.microtask(_drain);
    } else {
      _drainTimer = Timer(delay, _drain);
    }
  }

  Future<void> _drain() async {
    if (_isDraining || _queue.isEmpty) return;
    _isDraining = true;

    try {
      while (_queue.isNotEmpty && _inFlight.length < maxConcurrency) {
        if (!_canProcess()) {
          _scheduleDrain(baseRetryDelay);
          break;
        }

        final key = _queue.removeFirst();
        _queuedSet.remove(key);
        _inFlight.add(key);
        _statuses[key] = HydrationStatus.inFlight;

        unawaited(_processKey(key));
      }
    } finally {
      _isDraining = false;
    }
  }

  bool _canProcess() {
    try {
      final connectivity = _ref.read(connectivityStatusProvider).value;
      if (connectivity == AppConnectivityStatus.offline) {
        return false;
      }
    } catch (_) {}

    try {
      final interceptor = _ref.read(rateLimitInterceptorProvider);
      final burst = interceptor.state.burstRemaining;
      final sustained = interceptor.state.sustainedRemaining;
      if (burst < minBurstRemaining || sustained <= 0) {
        return false;
      }
    } catch (_) {}

    return true;
  }

  Future<void> _processKey(HydrationKey key) async {
    try {
      await runZoned(
        () => _executeHydration(key),
        zoneValues: {backgroundZoneKey: true},
      );

      _statuses[key] = HydrationStatus.succeeded;
      _retryAttempts.remove(key);
      _succeededCount++;
    } catch (e) {
      final is404 =
          e is DioException &&
          (e.response?.statusCode == 404 ||
              e.type == DioExceptionType.badResponse &&
                  e.response?.statusCode == 404);

      if (is404) {
        _statuses[key] = HydrationStatus.notFound;
        _retryAttempts.remove(key);
        _failedCount++;
        AppLogger.info("EntityHydrationQueue: ${key.toString()} not found (404)");
      } else {
        final attempts = (_retryAttempts[key] ?? 0) + 1;
        _retryAttempts[key] = attempts;

        if (attempts >= maxRetryAttempts) {
          _statuses[key] = HydrationStatus.failed;
          _failedCount++;
          AppLogger.warning(
            "EntityHydrationQueue: Max attempts reached for ${key.toString()}",
            error: e,
          );
        } else {
          _statuses[key] = HydrationStatus.queued;
          final delay = baseRetryDelay * attempts;
          AppLogger.info(
            "EntityHydrationQueue: Retrying ${key.toString()} (attempt $attempts) in ${delay.inSeconds}s",
          );
          Timer(delay, () {
            if (!_queuedSet.contains(key) && !_inFlight.contains(key)) {
              _queue.add(key);
              _queuedSet.add(key);
              _scheduleDrain();
            }
          });
        }
      }
    } finally {
      _inFlight.remove(key);
      _scheduleDrain();
    }
  }

  Future<void> _executeHydration(HydrationKey key) async {
    final repo = _ref.read(metronRepositoryProvider);
    final metadataCache = _ref.read(metronMetadataCacheProvider);
    final imageCache = _ref.read(entityImageCacheProvider);

    switch (key.type) {
      case HydrationEntityType.series:
        final details = await repo.getSeriesDetails(key.id);
        metadataCache.indexSeries(key.id, details.name);
        if (details.image != null) {
          await imageCache.set("series", key.id, details.image!);
        }
        if (details.publisher?.id != null && details.publisher?.name != null) {
          metadataCache.indexPublisher(
            details.publisher!.id,
            details.publisher!.name,
          );
        }
        break;

      case HydrationEntityType.issue:
        final details = await repo.getIssueDetails(key.id);
        if (details.image != null) {
          await imageCache.set("issue", key.id, details.image!);
        }
        if (details.series?.id != null && details.series?.name != null) {
          metadataCache.indexSeries(
            details.series!.id,
            details.series!.name,
          );
        }
        break;

      case HydrationEntityType.publisher:
        final details = await repo.getPublisherDetails(key.id);
        metadataCache.indexPublisher(key.id, details.name);
        if (details.image != null) {
          await imageCache.set("publisher", key.id, details.image!);
        }
        break;

      case HydrationEntityType.character:
        final details = await repo.getCharacterDetails(key.id);
        metadataCache.indexCharacter(key.id, details.name);
        if (details.image != null) {
          await imageCache.set("character", key.id, details.image!);
        }
        break;

      case HydrationEntityType.creator:
        final details = await repo.getCreatorDetails(key.id);
        metadataCache.indexCreator(key.id, details.name);
        if (details.image != null) {
          await imageCache.set("creator", key.id, details.image!);
        }
        break;

      case HydrationEntityType.team:
        final details = await repo.getTeamDetails(key.id);
        if (details.image != null) {
          await imageCache.set("team", key.id, details.image!);
        }
        break;

      case HydrationEntityType.arc:
        final details = await repo.getArcDetails(key.id);
        if (details.image != null) {
          await imageCache.set("arc", key.id, details.image!);
        }
        break;

      case HydrationEntityType.imprint:
        final details = await repo.getImprintDetails(key.id);
        metadataCache.indexImprint(key.id, details.name);
        if (details.image != null) {
          await imageCache.set("imprint", key.id, details.image!);
        }
        break;

      case HydrationEntityType.universe:
        final details = await repo.getUniverseDetails(key.id);
        if (details.image != null) {
          await imageCache.set("universe", key.id, details.image!);
        }
        break;
    }
  }

  void clear() {
    _drainTimer?.cancel();
    _queue.clear();
    _queuedSet.clear();
    _inFlight.clear();
    _retryAttempts.clear();
    _statuses.clear();
  }

  void dispose() {
    clear();
  }
}

/// Global provider for [EntityHydrationQueue].
final entityHydrationQueueProvider = Provider<EntityHydrationQueue>((ref) {
  final queue = EntityHydrationQueue(ref);
  ref.onDispose(queue.dispose);
  return queue;
});
