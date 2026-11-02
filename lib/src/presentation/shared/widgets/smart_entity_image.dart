import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/common/string_extensions.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

final creatorImageStreamProvider = StreamProvider.autoDispose
    .family<String?, int>((ref, id) {
      final dao = ref.watch(metronEntityDaoProvider);
      return dao.watchCreator(id).map((c) => c?.imageUrl);
    });

final characterImageStreamProvider = StreamProvider.autoDispose
    .family<String?, int>((ref, id) {
      final dao = ref.watch(metronEntityDaoProvider);
      return dao.watchCharacter(id).map((c) => c?.imageUrl);
    });

final teamImageStreamProvider = StreamProvider.autoDispose.family<String?, int>(
  (ref, id) {
    final dao = ref.watch(metronEntityDaoProvider);
    return dao.watchTeam(id).map((t) => t?.imageUrl);
  },
);

final arcImageStreamProvider = StreamProvider.autoDispose.family<String?, int>((
  ref,
  id,
) {
  final dao = ref.watch(metronEntityDaoProvider);
  return dao.watchArc(id).map((a) => a?.imageUrl);
});

final universeImageStreamProvider = StreamProvider.autoDispose
    .family<String?, int>((ref, id) {
      final dao = ref.watch(metronEntityDaoProvider);
      return dao.watchUniverse(id).map((u) => u?.imageUrl);
    });

final publisherImageStreamProvider = StreamProvider.autoDispose
    .family<String?, int>((ref, id) {
      final dao = ref.watch(metronEntityDaoProvider);
      return dao.watchPublisher(id).map((p) => p?.imageUrl);
    });

final imprintImageStreamProvider = StreamProvider.autoDispose
    .family<String?, int>((ref, id) {
      final dao = ref.watch(metronEntityDaoProvider);
      return dao.watchImprint(id).map((i) => i?.imageUrl);
    });

final seriesImageStreamProvider = StreamProvider.autoDispose
    .family<String?, int>((ref, id) {
      final dao = ref.watch(metronEntityDaoProvider);
      return dao.watchSeriesCoverUrl(id);
    });

String? watchEntityImageUrl(WidgetRef ref, String? entityType, int? entityId) {
  if (entityId == null || entityId <= 0 || entityType == null) return null;
  final normalizedType = entityType.toLowerCase().trim();
  return switch (normalizedType) {
    "creator" => ref.watch(creatorImageStreamProvider(entityId)).asData?.value,
    "character" =>
      ref.watch(characterImageStreamProvider(entityId)).asData?.value,
    "team" => ref.watch(teamImageStreamProvider(entityId)).asData?.value,
    "arc" => ref.watch(arcImageStreamProvider(entityId)).asData?.value,
    "universe" =>
      ref.watch(universeImageStreamProvider(entityId)).asData?.value,
    "publisher" =>
      ref.watch(publisherImageStreamProvider(entityId)).asData?.value,
    "imprint" => ref.watch(imprintImageStreamProvider(entityId)).asData?.value,
    "series" => ref.watch(seriesImageStreamProvider(entityId)).asData?.value,
    _ => null,
  };
}

class SmartEntityImage extends ConsumerWidget {
  const SmartEntityImage({
    super.key,
    this.entityType,
    this.entityId,
    required this.name,
    this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 40,
    this.isCircle = true,
    this.alignment = Alignment.topCenter,
    this.fontSize = 24,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String? entityType;
  final int? entityId;
  final String name;
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;
  final Alignment alignment;
  final double fontSize;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final effectiveCacheWidth =
        cacheWidth ?? (width.isFinite ? (width * 4).round() : null);
    final effectiveCacheHeight = cacheHeight;

    var effectiveImageUrl = imageUrl;
    if ((effectiveImageUrl == null || effectiveImageUrl.trim().isEmpty) &&
        entityId != null &&
        entityId! > 0) {
      effectiveImageUrl = watchEntityImageUrl(ref, entityType, entityId);
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: EntityCover(
        imageUrl: effectiveImageUrl,
        placeholderLabel: initials(name),
        width: width,
        height: height,
        borderRadius: 0,
        aspectRatio: width / height,
        iconSize: fontSize,
        alignment: alignment,
        circular: isCircle,
        cacheWidth: effectiveCacheWidth,
        cacheHeight: effectiveCacheHeight,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
      ),
    );
  }
}
