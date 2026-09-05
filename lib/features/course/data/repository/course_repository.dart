import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class CourseRepository {
  static const String _baseUrl = 'http://api.biddabari.com';
  static const String _coursesEndpoint = '/api/v1/app-home-courses';

  Future<List<CourseModel>> fetchHomeCourses() async {
    final uri = Uri.parse('$_baseUrl$_coursesEndpoint');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> coursesJson = body['courses'] as List<dynamic>;
      return coursesJson
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load courses: ${response.statusCode}');
    }
  }
}
