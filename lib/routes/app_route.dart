import 'package:get/get.dart';
import '../features/course/binding/course_binding.dart';
import '../features/course/presentation/screens/courese_screen.dart';
import '../features/course/presentation/screens/course_detail_screen.dart';

abstract class AppRoute {
  static const String home = '/';
  static const String courseDetail = '/course-detail';

  static final List<GetPage> pages = [
    GetPage(
      name: home,
      page: () => const CourseScreen(),
      binding: CourseBinding(),
    ),
    GetPage(
      name: courseDetail,
      page: () => const CourseDetailScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
