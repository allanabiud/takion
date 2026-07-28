import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

Future<void> exportCollectionToCsv(WidgetRef ref) async {
  final items = await ref.watch(allCollectionItemsProvider.future);

  final buffer = StringBuffer();
  buffer.writeln(
    'Series,Issue Number,Title,Quantity,Format,Read,Rating,Purchase Date',
  );

  for (final item in items) {
    final series = item.issue?.series?.name ?? '';
    final number = item.issue?.number ?? '';
    final title = '$series${number.isNotEmpty ? ' #$number' : ''}';
    final quantity = item.quantity.toString();
    final format = item.bookFormat ?? '';
    final read = item.isRead ? 'Yes' : 'No';
    final rating = item.rating != null ? item.rating.toString() : '';
    final purchaseDate = item.purchaseDate != null
        ? DateFormatter.isoDate(item.purchaseDate!)
        : '';

    buffer.writeln(
      '${_csvField(series)},${_csvField(number)},${_csvField(title)},'
      '$quantity,${_csvField(format)},$read,$rating,${_csvField(purchaseDate)}',
    );
  }

  final today = DateFormatter.isoDate(DateTime.now());
  final bytes = utf8.encode(buffer.toString());

  await FilePicker.saveFile(
    fileName: 'takion_collection_$today.csv',
    bytes: bytes,
  );
}

String _csvField(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
