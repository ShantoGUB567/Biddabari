import 'package:get/get.dart';
import '../data/repository/course_repository.dart';
import '../logic/course_controller.dart';

class CourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseRepository>(() => CourseRepository());
    Get.lazyPut<CourseController>(() => CourseController());
  }
}
