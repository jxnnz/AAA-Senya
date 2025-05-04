import 'dart:convert';
import 'dart:typed_data'; // For Uint8List
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'api_service.dart';

class AdminSignsService {
  final ApiService _api = ApiService();

  // ----------- FETCH -----------
  Future<List<Map<String, dynamic>>> fetchLessons() async {
    final res = await _api.get('/admin/lessons/');
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    } else {
      throw Exception('Failed to fetch lessons');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSigns(int lessonId) async {
    final res = await _api.get('/admin/signs/lesson/$lessonId');
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    } else {
      throw Exception('Failed to fetch signs');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllSigns() async {
    final response = await _api.get('/admin/signs/');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load all signs');
    }
  }

  // ----------- CREATE (WEB-SAFE) -----------
  Future<http.Response> uploadSignWithBytes({
    required String text,
    required int lessonId,
    required String difficulty,
    required Uint8List fileBytes,
    required String filename,
  }) async {
    final token = await ApiService().getToken();
    final uri = Uri.parse('http://localhost:8000/api/admin/signs/');

    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['lesson_id'] = lessonId.toString()
          ..fields['text'] = text
          ..fields['difficulty_level'] = difficulty
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: filename,
              contentType: MediaType('video', 'mp4'),
            ),
          );

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  // ----------- UPDATE (FIELDS ONLY) -----------
  Future<http.Response> updateSignFieldsOnly({
    required int signId,
    required String text,
    required String difficulty,
  }) async {
    final token = await ApiService().getToken();
    final uri = Uri.parse('http://localhost:8000/api/admin/signs/$signId');

    return http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'text': text, 'difficulty_level': difficulty},
    );
  }

  // ----------- ARCHIVE -----------
  Future<http.Response> archiveSign(int id) {
    return _api.patch('/admin/signs/$id/archive', {});
  }
}
