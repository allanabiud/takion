import "dart:convert";

import "package:file_picker/file_picker.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";

const _csvHeader = <String>[
  "Series",
  "Volume",
  "Year Began",
  "Issue Number",
  "Quantity",
  "Format",
  "Status",
  "Read",
  "Rating",
  "Price Paid",
  "Purchase Date",
  "Acquired On",
  "First Read",
  "Condition Grade",
  "Cover Date",
  "Store Date",
  "Notes",
];

Future<void> exportCollectionToCsv(WidgetRef ref) async {
  final items = await ref.watch(allCollectionItemsProvider.future);

  final buffer = StringBuffer("\uFEFF");
  buffer.writeln(_csvHeader.map(_csvField).join(","));

  for (final item in items) {
    buffer.writeln(_rowFor(item));
  }

  final today = DateFormatter.isoDate(DateTime.now());
  final bytes = utf8.encode(buffer.toString());

  await FilePicker.saveFile(
    fileName: "takion_collection_$today.csv",
    bytes: bytes,
  );
}

String _rowFor(CollectionItem item) {
  final issue = item.issue;
  final series = issue?.series;
  final coverDate = issue?.coverDate;
  final storeDate = issue?.storeDate;

  final values = <String>[
    series?.name ?? "",
    series?.volume?.toString() ?? "",
    series?.yearBegan?.toString() ?? "",
    issue?.number ?? "",
    item.quantity.toString(),
    item.bookFormat ?? "",
    _ownershipLabel(item.ownershipStatus),
    item.isRead ? "Yes" : "No",
    item.rating?.toString() ?? "",
    _decimal(item.pricePaid),
    _isoDate(item.purchaseDate),
    _isoDate(item.acquiredOn),
    _isoDate(item.firstReadAt),
    _decimal(item.grade),
    _isoDate(coverDate),
    _isoDate(storeDate),
    item.notes ?? "",
  ];

  return values.map(_csvField).join(",");
}

String _ownershipLabel(LibraryOwnershipStatus? status) {
  switch (status) {
    case LibraryOwnershipStatus.owned:
      return "Owned";
    case LibraryOwnershipStatus.wishlist:
      return "Wishlist";
    case LibraryOwnershipStatus.notOwned:
      return "Not Owned";
    case null:
      return "";
  }
}

String _isoDate(DateTime? date) {
  return date != null ? DateFormatter.isoDate(date) : "";
}

String _decimal(double? value) {
  if (value == null) return "";
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r"0$"), "");
}

String _csvField(String value) {
  if (value.contains(",") ||
      value.contains('"') ||
      value.contains("\n") ||
      value.contains("\r")) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
