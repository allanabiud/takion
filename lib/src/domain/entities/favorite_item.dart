class FavoriteSeries {
  const FavoriteSeries({required this.metronSeriesId, required this.createdAt});

  final int metronSeriesId;
  final DateTime createdAt;
}

class FavoriteIssue {
  const FavoriteIssue({required this.metronIssueId, required this.createdAt});

  final int metronIssueId;
  final DateTime createdAt;
}

class FavoriteReadingList {
  const FavoriteReadingList({
    required this.readingListId,
    required this.createdAt,
  });

  final String readingListId;
  final DateTime createdAt;
}
