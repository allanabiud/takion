import 'package:hive_ce/hive.dart';
import 'package:takion/src/core/storage/hive_service.dart';

class CacheHeaderStore {
  static const _boxName = 'cache_headers_box';

  Box<String>? _box;

  Future<void> init(HiveService hive) async {
    _box = await hive.openBox<String>(_boxName);
  }

  Box<String> get _b => _box!;

  String? _etagKey(String url) => '$url:etag';
  String? _lmKey(String url) => '$url:lm';

  Future<void> store(String url, {String? etag, String? lastModified}) async {
    if (etag != null) await _b.put(_etagKey(url), etag);
    if (lastModified != null) await _b.put(_lmKey(url), lastModified);
  }

  String? getEtag(String url) => _b.get(_etagKey(url));

  String? getLastModified(String url) => _b.get(_lmKey(url));

  Future<void> remove(String url) async {
    await _b.delete(_etagKey(url));
    await _b.delete(_lmKey(url));
  }

  Future<void> clear() async => _b.clear();
}
