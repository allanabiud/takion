class RemotePage<T> {
  const RemotePage({
    required this.items,
    required this.count,
    required this.next,
    required this.previous,
    required this.fetchedAt,
  });

  final List<T> items;
  final int count;

  /// Opaque server URL to the next page, or null if this is the last page.
  final Uri? next;

  /// Opaque server URL to the previous page, or null if this is the first page.
  final Uri? previous;

  final DateTime fetchedAt;

  bool get hasNext => next != null;
}
