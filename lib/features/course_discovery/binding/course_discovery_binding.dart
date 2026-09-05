import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/storage_service.dart';
import '../data/repository/course_repository.dart';
import '../logic/course_controller.dart';

class CourseDiscoveryBinding extends Bindings {
  @override
  void dependencies() {
    // 1. HTTP Client
    Get.lazyPut<Dio>(
      () => Dio(
        BaseOptions(
          connectTimeout: ApiEndpoints.connectTimeout,
          receiveTimeout: ApiEndpoints.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ),
      fenix: true,
    );

    // 2. Data / Repository (Model Layer)
    Get.lazyPut<ICourseRepository>(
      () => CourseRepository(
        dio: Get.find<Dio>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    // 3. Controller (Controller Layer)
    Get.lazyPut<CourseController>(
      () => CourseController(
        repository: Get.find<ICourseRepository>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );
  }
}
