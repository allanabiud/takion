class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.issueId,
    required this.seriesId,
    required this.seriesName,
    required this.issueNumber,
    this.seriesVolume,
    this.seriesYearBegan,
    this.coverDate,
    this.storeDate,
    this.imageUrl,
    this.priority = 3,
    this.desiredGrade,
    this.maxPrice,
    this.maxPriceCurrency = "USD",
    this.notes,
    this.addedOn,
    this.modified,
    this.syncStatus = "synced",
  });

  final int id;
  final int issueId;
  final int seriesId;
  final String seriesName;
  final String issueNumber;
  final int? seriesVolume;
  final int? seriesYearBegan;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final String? imageUrl;
  final int priority;
  final double? desiredGrade;
  final double? maxPrice;
  final String maxPriceCurrency;
  final String? notes;
  final DateTime? addedOn;
  final DateTime? modified;
  final String syncStatus;

  WishlistItem copyWith({
    int? id,
    int? issueId,
    int? seriesId,
    String? seriesName,
    String? issueNumber,
    int? seriesVolume,
    int? seriesYearBegan,
    DateTime? coverDate,
    DateTime? storeDate,
    String? imageUrl,
    int? priority,
    double? desiredGrade,
    double? maxPrice,
    String? maxPriceCurrency,
    String? notes,
    DateTime? addedOn,
    DateTime? modified,
    String? syncStatus,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      issueId: issueId ?? this.issueId,
      seriesId: seriesId ?? this.seriesId,
      seriesName: seriesName ?? this.seriesName,
      issueNumber: issueNumber ?? this.issueNumber,
      seriesVolume: seriesVolume ?? this.seriesVolume,
      seriesYearBegan: seriesYearBegan ?? this.seriesYearBegan,
      coverDate: coverDate ?? this.coverDate,
      storeDate: storeDate ?? this.storeDate,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      desiredGrade: desiredGrade ?? this.desiredGrade,
      maxPrice: maxPrice ?? this.maxPrice,
      maxPriceCurrency: maxPriceCurrency ?? this.maxPriceCurrency,
      notes: notes ?? this.notes,
      addedOn: addedOn ?? this.addedOn,
      modified: modified ?? this.modified,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
