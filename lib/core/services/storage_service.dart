import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Course caching
  Future<void> saveCoursesJson(Map<String, dynamic> data) async {
    await _box.write(AppConstants.coursesCacheKey, data);
    await _box.write(AppConstants.lastCacheTimeKey, DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getCachedCoursesJson() {
    final data = _box.read(AppConstants.coursesCacheKey);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  DateTime? getLastCacheTime() {
    final timeStr = _box.read<String>(AppConstants.lastCacheTimeKey);
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  Future<void> clearCache() async {
    await _box.remove(AppConstants.coursesCacheKey);
    await _box.remove(AppConstants.lastCacheTimeKey);
  }
}
