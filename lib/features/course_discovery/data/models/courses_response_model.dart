import 'course_model.dart';

class CoursesResponseModel {
  final List<CourseModel> courses;

  CoursesResponseModel({required this.courses});

  factory CoursesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawCourses = json['courses'];
    List<CourseModel> coursesList = [];

    if (rawCourses is List) {
      coursesList = rawCourses
          .whereType<Map<String, dynamic>>()
          .map((item) => CourseModel.fromJson(item))
          .toList();
    }

    return CoursesResponseModel(courses: coursesList);
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }
}
