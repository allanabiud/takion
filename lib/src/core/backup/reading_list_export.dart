import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/reading_list.dart';

class ReadingListExportService {
  final HiveService _hiveService;

  ReadingListExportService(this._hiveService);

  static const _boxName = 'reading_lists_box';

  Future<void> exportReadingList({
    required String readingListId,
    required String fileName,
  }) async {
    final box = await _hiveService.openBox<ReadingList>(_boxName);
    final list = box.get(readingListId);
    if (list == null) throw Exception('Reading list not found');

    final payload = {
      'v': 1,
      'type': 'reading_list',
      'data': list.toJson(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
    final bytes = utf8.encode(jsonString);
    final ext = fileName.endsWith('.tk') ? fileName : '$fileName.tk';

    await FilePicker.saveFile(
      fileName: ext,
      bytes: Uint8List.fromList(bytes),
    );
  }

  Future<ReadingList?> importReadingList() async {
    final result = await FilePicker.pickFiles(
      allowedExtensions: ['tk'],
    );
    if (result == null || result.files.isEmpty) return null;

    final filePath = result.files.single.path;
    if (filePath == null) return null;

    final file = File(filePath);
    final jsonString = await file.readAsString();
    final payload = jsonDecode(jsonString) as Map<String, dynamic>;

    if (payload['type'] != 'reading_list') {
      throw FormatException('Not a valid reading list file');
    }

    final data = payload['data'] as Map<String, dynamic>;
    final list = ReadingList.fromJson(data);

    final newList = list.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final box = await _hiveService.openBox<ReadingList>(_boxName);
    await box.put(newList.id, newList);
    await _hiveService.recordTimestamp(_boxName, newList.id);

    return newList;
  }
}
