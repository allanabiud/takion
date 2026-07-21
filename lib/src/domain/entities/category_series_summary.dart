import 'package:takion/src/domain/entities/entities.dart';

class CategorySeriesSummary {
  const CategorySeriesSummary({
    required this.seriesId,
    required this.seriesName,
    this.volume,
    this.yearBegan,
    this.coverImage,
    required this.categoryCount,
    required this.items,
  });

  final int seriesId;
  final String seriesName;
  final int? volume;
  final int? yearBegan;
  final String? coverImage;
  final int categoryCount;
  final List<CollectionItem> items;
}
