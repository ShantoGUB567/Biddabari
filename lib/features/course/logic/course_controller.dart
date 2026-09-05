import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/course_model.dart';
import '../data/repository/course_repository.dart';

enum CourseStatus { loading, success, empty, error }

class CourseController extends GetxController {
  final CourseRepository _repository = CourseRepository();
  final _box = GetStorage();

  static const String _cacheKey = 'cached_home_courses';

  // ── Reactive state ────────────────────────────────────────────────────────
  final courses = <CourseModel>[].obs;
  final status = CourseStatus.loading.obs;
  final errorMessage = ''.obs;
  final isOffline = false.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _listenConnectivity();
    fetchCourses();
  }

  // ── Connectivity ──────────────────────────────────────────────────────────
  void _listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      isOffline.value = offline;
      if (!offline && status.value == CourseStatus.error) {
        // Auto-retry once we come back online
        fetchCourses();
      }
    });
  }

  // ── Data fetching ─────────────────────────────────────────────────────────
  Future<void> fetchCourses() async {
    // Show cached data immediately if available
    final cached = _loadCache();
    if (cached.isNotEmpty && status.value != CourseStatus.success) {
      courses.assignAll(cached);
      status.value = CourseStatus.success;
    } else if (cached.isEmpty) {
      status.value = CourseStatus.loading;
    }

    try {
      final fresh = await _repository.fetchHomeCourses();
      if (fresh.isEmpty) {
        if (courses.isEmpty) status.value = CourseStatus.empty;
      } else {
        courses.assignAll(fresh);
        status.value = CourseStatus.success;
        _saveCache(fresh);
      }
    } catch (e) {
      if (courses.isEmpty) {
        errorMessage.value = e.toString();
        status.value = CourseStatus.error;
      }
      // If we already have cached data, silently keep it shown
    }
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────
  List<CourseModel> _loadCache() {
    final raw = _box.read<List?>(_cacheKey);
    if (raw == null) return [];
    try {
      return raw
          .map((e) => CourseModel.fromJson(
              json.decode(json.encode(e)) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _saveCache(List<CourseModel> data) {
    _box.write(_cacheKey, data.map((e) => e.toJson()).toList());
  }
}
