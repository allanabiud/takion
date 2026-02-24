class SeriesDetailsNamedRef {
  const SeriesDetailsNamedRef({required this.id, required this.name});

  final int id;
  final String name;
}

class SeriesDetailsAssociated {
  const SeriesDetailsAssociated({required this.id, required this.series});

  final int id;
  final String series;
}

class SeriesDetails {
  const SeriesDetails({
    required this.id,
    required this.name,
    this.sortName,
    this.volume,
    this.seriesType,
    this.status,
    this.publisher,
    this.imprint,
    this.yearBegan,
    this.yearEnd,
    this.description,
    this.issueCount,
    this.genres = const [],
    this.associated = const [],
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String? sortName;
  final int? volume;
  final SeriesDetailsNamedRef? seriesType;
  final String? status;
  final SeriesDetailsNamedRef? publisher;
  final SeriesDetailsNamedRef? imprint;
  final int? yearBegan;
  final int? yearEnd;
  final String? description;
  final int? issueCount;
  final List<SeriesDetailsNamedRef> genres;
  final List<SeriesDetailsAssociated> associated;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final DateTime? modified;
}
