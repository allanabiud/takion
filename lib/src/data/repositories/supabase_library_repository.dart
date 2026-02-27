import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/domain/entities/library_read_log.dart';
import 'package:takion/src/domain/repositories/library_repository.dart';

class SupabaseLibraryRepository implements LibraryRepository {
  SupabaseLibraryRepository(this._client);

  final SupabaseClient _client;

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User must be authenticated to access library data.');
    }
    return userId;
  }

  LibraryOwnershipStatus _ownershipStatusFromDb(String value) {
    switch (value) {
      case 'owned':
        return LibraryOwnershipStatus.owned;
      case 'wishlist':
        return LibraryOwnershipStatus.wishlist;
      case 'ordered':
        return LibraryOwnershipStatus.ordered;
      case 'sold':
        return LibraryOwnershipStatus.sold;
      default:
        throw StateError('Unknown ownership status: $value');
    }
  }

  String _ownershipStatusToDb(LibraryOwnershipStatus status) {
    switch (status) {
      case LibraryOwnershipStatus.owned:
        return 'owned';
      case LibraryOwnershipStatus.wishlist:
        return 'wishlist';
      case LibraryOwnershipStatus.ordered:
        return 'ordered';
      case LibraryOwnershipStatus.sold:
        return 'sold';
    }
  }

  LibraryItemFormat _formatFromDb(String? value) {
    switch (value) {
      case 'digital':
        return LibraryItemFormat.digital;
      case 'both':
        return LibraryItemFormat.both;
      case 'print':
      default:
        return LibraryItemFormat.print;
    }
  }

  String _formatToDb(LibraryItemFormat format) {
    switch (format) {
      case LibraryItemFormat.print:
        return 'print';
      case LibraryItemFormat.digital:
        return 'digital';
      case LibraryItemFormat.both:
        return 'both';
    }
  }

  LibraryItem _mapRow(Map<String, dynamic> row) {
    return LibraryItem(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      metronIssueId: row['metron_issue_id'] as int,
      metronSeriesId: row['metron_series_id'] as int,
      ownershipStatus: _ownershipStatusFromDb(row['ownership_status'] as String),
      isRead: row['is_read'] as bool? ?? false,
      rating: row['rating'] as int?,
        purchaseDate:
          row['purchase_date'] != null
            ? DateTime.parse(row['purchase_date'] as String)
            : null,
        pricePaid: (row['price_paid'] as num?)?.toDouble(),
        quantityOwned: row['quantity_owned'] as int? ?? 1,
        format: _formatFromDb(row['format'] as String?),
        firstReadAt:
          row['first_read_at'] != null
            ? DateTime.parse(row['first_read_at'] as String)
            : null,
      conditionGrade: row['condition_grade'] as String?,
      acquiredOn:
          row['acquired_on'] != null
              ? DateTime.parse(row['acquired_on'] as String)
              : null,
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  Future<int> getItemCount() async {
    final userId = _requireUserId();
    final rows = await _client
        .from('collection_items')
        .select('id')
        .eq('user_id', userId);

    return (rows as List<dynamic>).length;
  }

  @override
  Future<List<LibraryItem>> listItems({
    int limit = 50,
    int offset = 0,
  }) async {
    final userId = _requireUserId();
    final rows = await _client
        .from('collection_items')
        .select(
          'id, user_id, metron_issue_id, metron_series_id, ownership_status, is_read, rating, purchase_date, price_paid, quantity_owned, format, first_read_at, condition_grade, acquired_on, notes, created_at, updated_at',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_mapRow)
        .toList();
  }

  @override
  Future<LibraryItem?> getItemByIssueId(int metronIssueId) async {
    final userId = _requireUserId();
    final row = await _client
        .from('collection_items')
        .select(
          'id, user_id, metron_issue_id, metron_series_id, ownership_status, is_read, rating, purchase_date, price_paid, quantity_owned, format, first_read_at, condition_grade, acquired_on, notes, created_at, updated_at',
        )
        .eq('user_id', userId)
        .eq('metron_issue_id', metronIssueId)
        .maybeSingle();

    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<LibraryItem> upsertItem({
    required int metronIssueId,
    required int metronSeriesId,
    required LibraryOwnershipStatus ownershipStatus,
    bool isRead = false,
    int? rating,
    DateTime? purchaseDate,
    double? pricePaid,
    int quantityOwned = 1,
    LibraryItemFormat format = LibraryItemFormat.print,
    DateTime? firstReadAt,
    String? conditionGrade,
    DateTime? acquiredOn,
    String? notes,
  }) async {
    final userId = _requireUserId();

    final row = await _client
        .from('collection_items')
        .upsert({
          'user_id': userId,
          'metron_issue_id': metronIssueId,
          'metron_series_id': metronSeriesId,
          'ownership_status': _ownershipStatusToDb(ownershipStatus),
          'is_read': isRead,
          'rating': rating,
            'purchase_date':
              purchaseDate?.toUtc().toIso8601String().split('T').first,
            'price_paid': pricePaid,
            'quantity_owned': quantityOwned,
            'format': _formatToDb(format),
            'first_read_at': firstReadAt?.toUtc().toIso8601String(),
          'condition_grade': conditionGrade,
          'acquired_on': acquiredOn?.toUtc().toIso8601String().split('T').first,
          'notes': notes,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id,metron_issue_id')
        .select(
          'id, user_id, metron_issue_id, metron_series_id, ownership_status, is_read, rating, purchase_date, price_paid, quantity_owned, format, first_read_at, condition_grade, acquired_on, notes, created_at, updated_at',
        )
        .single();

    return _mapRow(row);
  }

  @override
  Future<void> deleteItemByIssueId(int metronIssueId) async {
    final userId = _requireUserId();
    await _client
        .from('collection_items')
        .delete()
        .eq('user_id', userId)
        .eq('metron_issue_id', metronIssueId);
  }

  @override
  Future<Set<int>> getOwnedIssueIds(List<int> metronIssueIds) async {
    if (metronIssueIds.isEmpty) return <int>{};

    final userId = _requireUserId();
    final rows = await _client
        .from('collection_items')
        .select('metron_issue_id')
        .eq('user_id', userId)
        .eq('ownership_status', 'owned')
        .inFilter('metron_issue_id', metronIssueIds);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((row) => row['metron_issue_id'] as int)
        .toSet();
  }

  LibraryReadLog _mapReadLog(Map<String, dynamic> row) {
    return LibraryReadLog(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      collectionItemId: row['collection_item_id'] as String,
      readAt: DateTime.parse(row['read_at'] as String),
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  @override
  Future<List<LibraryReadLog>> getReadLogsByIssueId(int metronIssueId) async {
    final item = await getItemByIssueId(metronIssueId);
    if (item == null) return <LibraryReadLog>[];

    final userId = _requireUserId();
    final rows = await _client
        .from('collection_read_logs')
        .select('id, user_id, collection_item_id, read_at, notes, created_at')
        .eq('user_id', userId)
        .eq('collection_item_id', item.id)
        .order('read_at', ascending: false);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_mapReadLog)
        .toList();
  }

  @override
  Future<LibraryReadLog> addReadLog({
    required int metronIssueId,
    required DateTime readAt,
    String? notes,
  }) async {
    final item = await getItemByIssueId(metronIssueId);
    if (item == null) {
      throw StateError('Library item does not exist for issue $metronIssueId');
    }

    final userId = _requireUserId();
    final row = await _client
        .from('collection_read_logs')
        .insert({
          'user_id': userId,
          'collection_item_id': item.id,
          'read_at': readAt.toUtc().toIso8601String(),
          'notes': notes,
        })
        .select('id, user_id, collection_item_id, read_at, notes, created_at')
        .single();

    return _mapReadLog(row);
  }

  @override
  Future<void> deleteReadLogById(String readLogId) async {
    final userId = _requireUserId();
    await _client
        .from('collection_read_logs')
        .delete()
        .eq('user_id', userId)
        .eq('id', readLogId);
  }
}
