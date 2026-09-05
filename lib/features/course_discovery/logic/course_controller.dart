import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/connectivity_service.dart';
import '../data/models/course_model.dart';
import '../data/repository/course_repository.dart';

/// MVC Controller for Course Discovery feature
class CourseController extends GetxController {
  final ICourseRepository repository;
  final ConnectivityService connectivityService;

  CourseController({
    required this.repository,
    required this.connectivityService,
  });

  // --- Reactive MVC State (Observables) ---
  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final RxList<CourseModel> filteredCourses = <CourseModel>[].obs;
  final Rx<RxStatus> status = RxStatus.loading().obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSilentRefreshing = false.obs;
  final RxBool isShowingCachedData = false.obs;
  final Rx<DateTime?> lastCachedTime = Rx<DateTime?>(null);
  final RxString errorMessage = ''.obs;

  StreamSubscription<void>? _reconnectSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToConnectivityRestoration();
    loadCoursesOfflineFirst();
  }

  /// Listens to network reconnection events and triggers automatic re-fetch
  void _listenToConnectivityRestoration() {
    _reconnectSubscription = connectivityService.onReconnected.listen((_) {
      debugPrint('[CourseController] Auto-retrying fetch following network reconnection...');
      fetchCourses(isSilent: courses.isNotEmpty);
    });
  }

  /// Loads cached courses immediately if available, then fetches live data silently
  Future<void> loadCoursesOfflineFirst() async {
    final cached = repository.getCachedCourses();
    lastCachedTime.value = repository.getLastCacheTime();

    if (cached != null && cached.isNotEmpty) {
      courses.assignAll(cached);
      _applySearchFilter();
      isShowingCachedData.value = true;
      status.value = RxStatus.success();

      // Silently refresh from network in background
      await fetchCourses(isSilent: true);
    } else {
      // No cache available, show loading skeleton
      status.value = RxStatus.loading();
      await fetchCourses(isSilent: false);
    }
  }

  /// Fetches courses from the live API
  Future<void> fetchCourses({bool isSilent = false}) async {
    if (isSilent) {
      isSilentRefreshing.value = true;
    } else if (courses.isEmpty) {
      status.value = RxStatus.loading();
    }

    try {
      final fetchedCourses = await repository.fetchRemoteCourses();
      courses.assignAll(fetchedCourses);
      _applySearchFilter();
      isShowingCachedData.value = false;
      lastCachedTime.value = DateTime.now();

      if (courses.isEmpty) {
        status.value = RxStatus.empty();
      } else {
        status.value = RxStatus.success();
      }
    } on DioException catch (dioErr) {
      _handleFetchError(dioErr.message ?? 'Network connection error', isSilent);
    } catch (e) {
      _handleFetchError('Failed to fetch courses. Please check your network and try again.', isSilent);
    } finally {
      isSilentRefreshing.value = false;
    }
  }

  void _handleFetchError(String message, bool isSilent) {
    errorMessage.value = message;
    if (courses.isNotEmpty) {
      // Keep displaying cached courses with offline/cached banner
      isShowingCachedData.value = true;
      status.value = RxStatus.success();
    } else {
      status.value = RxStatus.error(message);
    }
  }

  // --- MVC Action Handlers (Invoked by the Views) ---

  /// Pull-to-refresh action
  Future<void> handleRefresh() async {
    await fetchCourses(isSilent: false);
  }

  /// Search action
  void handleSearch(String query) {
    searchQuery.value = query;
    _applySearchFilter();
    if (filteredCourses.isEmpty) {
      status.value = RxStatus.empty();
    } else {
      status.value = RxStatus.success();
    }
  }

  /// Clear search action
  void handleClearSearch() {
    searchQuery.value = '';
    _applySearchFilter();
    status.value = courses.isEmpty ? RxStatus.empty() : RxStatus.success();
  }

  /// Retry button action on error state
  void handleRetry() {
    fetchCourses(isSilent: false);
  }

  /// Navigation action: Opens Course Details screen
  void handleCourseTap(CourseModel course) {
    Get.toNamed(
      AppRoutes.courseDetails,
      arguments: course.id,
    );
  }

  /// Enrollment CTA action
  void handleEnrollCourse(CourseModel course) {
    Get.snackbar(
      'Enrollment Initiated',
      'Proceeding to checkout for ${course.title}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0D6E4F),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Share course action
  void handleShareCourse(CourseModel course) {
    Get.snackbar(
      'Share Course',
      'Sharing link for ${course.title}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _applySearchFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredCourses.assignAll(courses);
    } else {
      filteredCourses.assignAll(
        courses.where((course) {
          final titleMatch = course.title.toLowerCase().contains(query);
          final subTitleMatch = course.subTitle?.toLowerCase().contains(query) ?? false;
          final bannerTitleMatch = course.bannerTitle?.toLowerCase().contains(query) ?? false;
          return titleMatch || subTitleMatch || bannerTitleMatch;
        }),
      );
    }
  }

  /// Find a course by ID for Details view
  CourseModel? getCourseById(int id) {
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    _reconnectSubscription?.cancel();
    super.onClose();
  }
}

/// Alias for backwards compatibility
typedef CourseDiscoveryController = CourseController;
