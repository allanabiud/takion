import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/domain/collection/entities/collection_item.dart";
import "package:takion/src/domain/collection/entities/collection_stats.dart";
import "package:takion/src/domain/collection/entities/missing_issue.dart";
import "package:takion/src/domain/collection/entities/scrobble_result.dart";

abstract class CollectionRepository {
  Future<RemotePage<CollectionItem>> getCollectionPage({
    Uri? pageUrl,
    DateTime? modifiedGt,
  });

  Future<List<CollectionItem>> getCollection({
    int page = 1,
    String? bookFormat,
    DateTime? dateRead,
    double? grade,
    String? gradingCompany,
    bool? isRead,
    DateTime? modifiedGt,
    int? rating,
  });

  Future<CollectionItem> getCollectionItem(int id);

  Future<CollectionItem> addToCollection({
    required int issueId,
    int quantity = 1,
    String bookFormat = "PRINT",
    double? grade,
    String? gradingCompany,
    DateTime? purchaseDate,
    double? purchasePrice,
    String purchasePriceCurrency = "USD",
    String? purchaseStore,
    String? storageLocation,
    String? notes,
  });

  Future<CollectionItem> updateCollectionItem({
    required int id,
    int? rating,
    int? quantity,
    String? bookFormat,
    double? grade,
    String? gradingCompany,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? purchaseStore,
    String? storageLocation,
    String? notes,
    bool? isRead,
  });

  Future<void> removeFromCollection(int id);

  Future<ScrobbleResult> scrobble({
    required int issueId,
    DateTime? dateRead,
    int? rating,
  });

  Future<CollectionStats> getCollectionStats();

  Future<MissingIssuesPage> getMissingIssues(int seriesId, {int page = 1});

  Future<List<MissingSeries>> getMissingSeries({int page = 1});
}

typedef MetronCollectionRepository = CollectionRepository;
