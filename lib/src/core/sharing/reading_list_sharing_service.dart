import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/domain/entities/reading_list.dart';

final readingListSharingServiceProvider = Provider((ref) => ReadingListSharingService());

class ReadingListSharingService {
  Future<void> shareReadingList(ReadingList list) async {
    final json = jsonEncode(list.toJson());
    final tempDir = await getTemporaryDirectory();
    final fileName = '${list.title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')}.takion';
    final file = File('${tempDir.path}/$fileName');
    
    await file.writeAsString(json);
    
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Sharing Reading List: ${list.title}',
        text: 'Check out this reading list: ${list.title}',
      ),
    );
  }

  Future<ReadingList?> importReadingList() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any, // .takion might not be recognized, so any for now
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      try {
        final json = jsonDecode(content) as Map<String, dynamic>;
        final list = ReadingList.fromJson(json);
        
        // Use the original ID if it exists to allow duplicate detection,
        // but reset timestamps for the local collection.
        return list.copyWith(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } catch (e) {
        // Handle parsing error
        return null;
      }
    }
    return null;
  }
}
