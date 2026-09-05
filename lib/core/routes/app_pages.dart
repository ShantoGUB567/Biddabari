import 'package:get/get.dart';
import '../../features/course_discovery/binding/course_discovery_binding.dart';
import '../../features/course_discovery/presentation/screens/course_details_screen.dart';
import '../../features/course_discovery/presentation/screens/home_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.home;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: CourseDiscoveryBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.courseDetails,
      page: () => const CourseDetailsScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
