import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/common/drift/daos/metron_entity_dao.dart';

void main() {
  test('two concurrent unawaited stub batches', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final dao = MetronEntityDao(db);

    void fireIssue(int id, String number) {
      unawaited(
        dao.upsertIssueStubsBatch([
          MetronIssuesCompanion(
            id: Value(id),
            number: Value(number),
            seriesId: const Value(900),
            imageUrl: const Value(null),
            isFullyHydrated: const Value(false),
          ),
        ]),
      );
    }

    void fireSeries() {
      unawaited(
        dao.upsertSeriesStubsBatch([
          MetronSeriesCompanion(
            id: const Value(900),
            name: const Value('Test Series'),
            yearBegan: const Value(2026),
            volume: const Value(1),
            isFullyHydrated: const Value(false),
          ),
        ]),
      );
    }

    fireIssue(1, '1');
    fireSeries();
    fireIssue(2, '2');
    fireSeries();

    await db.customStatement('SELECT 1');
    await db.close();
  });
}
