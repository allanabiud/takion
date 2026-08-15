import "dart:convert";
import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path_provider/path_provider.dart";
import "package:share_plus/share_plus.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/core/logging/app_logger.dart";

final readingListSharingServiceProvider = Provider(
  (ref) => ReadingListSharingService(),
);

class ReadingListSharingService {
  Future<void> shareReadingList(LocalReadingList list) async {
    final json = jsonEncode(list.toJson());
    final tempDir = await getTemporaryDirectory();
    final fileName =
        '${list.title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')}.takion';
    final file = File("${tempDir.path}/$fileName");

    await file.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: "Sharing Reading List: ${list.title}",
        text: "Check out this reading list: ${list.title}",
      ),
    );
  }

  Future<LocalReadingList?> importReadingList() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any, // .takion may not be a recognized extension.
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      try {
        final decoded = jsonDecode(content);
        if (decoded is! Map) return null;
        final json = Map<String, dynamic>.from(decoded);
        final list = LocalReadingList.fromJson(json);

        // Keep the original ID for duplicate detection but reset timestamps.
        return list.copyWith(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } catch (e) {
        AppLogger.warning("Failed to parse imported reading list", error: e);
        return null;
      }
    }
    return null;
  }
}
