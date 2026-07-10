import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/tag.dart';

const _tagsBoxName = 'tags_box';
const _tagsKey = 'all_tags';
const _issueTagsBoxName = 'issue_tags_box';

final allTagsProvider = FutureProvider<List<Tag>>((ref) async {
  final hive = ref.read(hiveServiceProvider);
  final box = await hive.openBox<List>(_tagsBoxName);
  final raw = box.get(_tagsKey);
  if (raw == null) return [];
  return raw
      .whereType<Map>()
      .map((e) => Tag.fromJson(e.cast<String, dynamic>()))
      .toList();
});

final issueTagsProvider =
    FutureProvider.family<List<Tag>, int>((ref, issueId) async {
  final allTags = await ref.watch(allTagsProvider.future);
  final hive = ref.read(hiveServiceProvider);
  final box = await hive.openBox<List>(_issueTagsBoxName);
  final tagIds = box.get(issueId)?.whereType<String>().toList() ?? [];
  return allTags.where((tag) => tagIds.contains(tag.id)).toList();
});

class TagOperations {
  final Ref ref;

  TagOperations(this.ref);

  Future<List<Tag>> _loadTags() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<List>(_tagsBoxName);
    final raw = box.get(_tagsKey);
    if (raw == null) return [];
    return raw
        .whereType<Map>()
        .map((e) => Tag.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> _saveTags(List<Tag> tags) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<List>(_tagsBoxName);
    await box.put(_tagsKey, tags.map((t) => t.toJson()).toList());
  }

  Future<Tag> createTag(String name, int colorValue) async {
    final tags = await _loadTags();
    final tag = Tag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorValue: colorValue,
    );
    tags.add(tag);
    await _saveTags(tags);
    ref.invalidate(allTagsProvider);
    return tag;
  }

  Future<void> deleteTag(String tagId) async {
    final tags = await _loadTags();
    tags.removeWhere((t) => t.id == tagId);
    await _saveTags(tags);

    final hive = ref.read(hiveServiceProvider);
    final issueBox = await hive.openBox<List>(_issueTagsBoxName);
    for (final key in issueBox.keys) {
      final ids = issueBox.get(key)?.whereType<String>().toList() ?? [];
      if (ids.contains(tagId)) {
        ids.remove(tagId);
        if (ids.isEmpty) {
          await issueBox.delete(key);
        } else {
          await issueBox.put(key, ids);
        }
      }
    }

    ref.invalidate(allTagsProvider);
    ref.invalidate(issueTagsProvider);
  }

  Future<void> renameTag(String tagId, String newName) async {
    final tags = await _loadTags();
    final index = tags.indexWhere((t) => t.id == tagId);
    if (index == -1) return;
    tags[index] = tags[index].copyWith(name: newName);
    await _saveTags(tags);
    ref.invalidate(allTagsProvider);
  }

  Future<void> addTagToIssue(int issueId, String tagId) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<List>(_issueTagsBoxName);
    final ids = box.get(issueId)?.whereType<String>().toList() ?? [];
    if (!ids.contains(tagId)) {
      ids.add(tagId);
      await box.put(issueId, ids);
    }
    ref.invalidate(issueTagsProvider(issueId));
  }

  Future<void> removeTagFromIssue(int issueId, String tagId) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<List>(_issueTagsBoxName);
    final ids = box.get(issueId)?.whereType<String>().toList() ?? [];
    if (ids.contains(tagId)) {
      ids.remove(tagId);
      if (ids.isEmpty) {
        await box.delete(issueId);
      } else {
        await box.put(issueId, ids);
      }
    }
    ref.invalidate(issueTagsProvider(issueId));
  }
}

final tagOperationsProvider = Provider<TagOperations>((ref) => TagOperations(ref));

final allIssueTagsProvider = FutureProvider<Map<int, List<String>>>((ref) async {
  final hive = ref.read(hiveServiceProvider);
  final box = await hive.openBox<List>(_issueTagsBoxName);
  final result = <int, List<String>>{};
  for (final key in box.keys) {
    if (key is int) {
      final ids = box.get(key)?.whereType<String>().toList() ?? [];
      if (ids.isNotEmpty) {
        result[key] = ids;
      }
    }
  }
  return result;
});
