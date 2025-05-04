import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AdminLessonService {
  final ApiService _apiService = ApiService();

  // GET all lessons by unit
  Future<List<dynamic>> getLessonsByUnit(int unitId) async {
    final res = await _apiService.get('/admin/lessons/unit/$unitId');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch lessons: ${res.body}");
    }
  }

  // CREATE a lesson
  Future<http.Response> createLesson({
    required int unitId,
    required int orderIndex,
    required String title,
    String? description,
  }) async {
    final body = {
      'unit_id': unitId.toString(),
      'order_index': orderIndex.toString(),
      'title': title,
      'description': description ?? '',
    };

    return await _apiService.postForm('/admin/lessons/', body);
  }

  // UPDATE a lesson
  Future<http.Response> updateLesson({
    required int lessonId,
    required int unitId,
    required int orderIndex,
    required String title,
    String? description,
  }) async {
    final body = {
      'unit_id': unitId.toString(),
      'order_index': orderIndex.toString(),
      'title': title,
      'description': description ?? '',
    };

    return await _apiService.putForm('/admin/lessons/$lessonId', body);
  }

  // ARCHIVE a lesson
  Future<http.Response> archiveLesson(int id) async {
    return await _apiService.patch('/admin/lessons/$id/archive', {});
  }

  // (Optional) GET all units for dropdown
  Future<List<dynamic>> getUnits() async {
    final res = await _apiService.get('/admin/units/');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch units");
    }
  }
}
