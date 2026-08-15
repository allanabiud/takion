import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/data/common/drift/database.dart";

export "package:takion/src/data/common/drift/database.dart" show AppDatabase;

final driftDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
