import "dart:collection";

import "package:takion/src/domain/entities.dart";

class UserStateCache {
  static const int _maxEntries = 500;

  final _libraryItems = LinkedHashMap<int, LibraryItem>(
    hashCode: (k) => k,
    equals: (a, b) => a == b,
  );

  final _pullListEntries = LinkedHashMap<int, PullListEntry>(
    hashCode: (k) => k,
    equals: (a, b) => a == b,
  );

  final _subscriptions = LinkedHashMap<int, SeriesSubscription>(
    hashCode: (k) => k,
    equals: (a, b) => a == b,
  );

  LibraryItem? getLibraryItem(int issueId) {
    final item = _libraryItems[issueId];
    if (item != null && _libraryItems.length >= _maxEntries) {
      _evictOldest(_libraryItems);
    }
    return item;
  }

  void setLibraryItem(int issueId, LibraryItem item) {
    if (_libraryItems.length >= _maxEntries) {
      _evictOldest(_libraryItems);
    }
    _libraryItems[issueId] = item;
  }

  void removeLibraryItem(int issueId) {
    _libraryItems.remove(issueId);
  }

  void invalidateAllLibrary() {
    _libraryItems.clear();
  }

  PullListEntry? getPullListEntry(int issueId) {
    final entry = _pullListEntries[issueId];
    if (entry != null && _pullListEntries.length >= _maxEntries) {
      _evictOldest(_pullListEntries);
    }
    return entry;
  }

  void setPullListEntry(int issueId, PullListEntry entry) {
    if (_pullListEntries.length >= _maxEntries) {
      _evictOldest(_pullListEntries);
    }
    _pullListEntries[issueId] = entry;
  }

  void removePullListEntry(int issueId) {
    _pullListEntries.remove(issueId);
  }

  void invalidateAllPullList() {
    _pullListEntries.clear();
  }

  SeriesSubscription? getSubscription(int seriesId) {
    final sub = _subscriptions[seriesId];
    if (sub != null && _subscriptions.length >= _maxEntries) {
      _evictOldest(_subscriptions);
    }
    return sub;
  }

  void setSubscription(int seriesId, SeriesSubscription subscription) {
    if (_subscriptions.length >= _maxEntries) {
      _evictOldest(_subscriptions);
    }
    _subscriptions[seriesId] = subscription;
  }

  void removeSubscription(int seriesId) {
    _subscriptions.remove(seriesId);
  }

  void invalidateAllSubscriptions() {
    _subscriptions.clear();
  }

  void invalidateAll() {
    _libraryItems.clear();
    _pullListEntries.clear();
    _subscriptions.clear();
  }

  void _evictOldest(LinkedHashMap map) {
    final oldest = map.keys.first;
    map.remove(oldest);
  }
}
