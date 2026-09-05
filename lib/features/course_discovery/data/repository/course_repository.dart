import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/storage_service.dart';
import '../models/course_model.dart';
import '../models/courses_response_model.dart';

abstract class ICourseRepository {
  Future<List<CourseModel>> fetchRemoteCourses();
  List<CourseModel>? getCachedCourses();
  DateTime? getLastCacheTime();
}

class CourseRepository implements ICourseRepository {
  final Dio dio;
  final StorageService storageService;

  CourseRepository({
    required this.dio,
    required this.storageService,
  });

  @override
  List<CourseModel>? getCachedCourses() {
    try {
      final cachedJson = storageService.getCachedCoursesJson();
      if (cachedJson != null) {
        final responseModel = CoursesResponseModel.fromJson(cachedJson);
        if (responseModel.courses.isNotEmpty) {
          debugPrint('[CourseRepository] Loaded ${responseModel.courses.length} courses from local cache.');
          return responseModel.courses;
        }
      }
    } catch (e) {
      debugPrint('[CourseRepository] Failed to read cache: $e');
    }
    return null;
  }

  @override
  DateTime? getLastCacheTime() {
    return storageService.getLastCacheTime();
  }

  @override
  Future<List<CourseModel>> fetchRemoteCourses() async {
    try {
      debugPrint('[CourseRepository] Fetching courses from: ${ApiEndpoints.appHomeCourses}');
      final response = await dio.get(
        ApiEndpoints.appHomeCourses,
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = (response.data is Map)
            ? Map<String, dynamic>.from(response.data)
            : {'courses': response.data};

        // Cache the raw JSON
        await storageService.saveCoursesJson(data);

        final responseModel = CoursesResponseModel.fromJson(data);
        debugPrint('[CourseRepository] Successfully fetched ${responseModel.courses.length} courses from network.');
        return responseModel.courses;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Server returned status ${response.statusCode}',
        );
      }
    } on DioException catch (dioErr) {
      debugPrint('[CourseRepository] DioException: ${dioErr.message}');
      rethrow;
    } catch (e) {
      debugPrint('[CourseRepository] Unexpected fetch error: $e');
      throw Exception('Failed to load courses: $e');
    }
  }
}
