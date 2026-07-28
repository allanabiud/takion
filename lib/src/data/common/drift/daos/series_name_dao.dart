import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class SeriesNameDao extends DatabaseAccessor<AppDatabase> {
  SeriesNameDao(super.db);

  Future<void> add(String normalizedName, String originalName) async {
    await into(attachedDatabase.seriesNameIndex).insertOnConflictUpdate(
      SeriesNameIndexCompanion.insert(
        normalizedName: normalizedName,
        originalName: originalName,
      ),
    );
  }

  Future<void> addAll(
    Iterable<({String normalized, String original})> names,
  ) async {
    await batch((batch) {
      for (final name in names) {
        batch.insert(
          attachedDatabase.seriesNameIndex,
          SeriesNameIndexCompanion.insert(
            normalizedName: name.normalized,
            originalName: name.original,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<SeriesNameIndexData>> getAll() async {
    return select(attachedDatabase.seriesNameIndex).get();
  }
}
