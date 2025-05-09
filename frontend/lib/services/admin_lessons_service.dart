import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

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
    int rubiesReward = 0,
    String? imageUrl,
  }) async {
    final body = {
      'unit_id': unitId.toString(),
      'order_index': orderIndex.toString(),
      'title': title,
      'description': description ?? '',
      'rubies_reward': rubiesReward.toString(),
      'image_url': imageUrl ?? '',
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
    int rubiesReward = 0,
    String? imageUrl,
  }) async {
    final body = {
      'unit_id': unitId.toString(),
      'order_index': orderIndex.toString(),
      'title': title,
      'description': description ?? '',
      'rubies_reward': rubiesReward.toString(),
      'image_url': imageUrl ?? '',
    };

    return await _apiService.putForm('/admin/lessons/$lessonId', body);
  }

  // ARCHIVE a lesson
  Future<http.Response> archiveLesson(int id) async {
    return await _apiService.patch('/admin/lessons/$id/archive', {});
  }

  // GET all units
  Future<List<dynamic>> getUnits() async {
    final res = await _apiService.get('/admin/units/');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch units");
    }
  }

  Future<String> uploadLessonImage(int lessonId, XFile imageFile) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/admin/lessons/$lessonId/upload-image',
    );
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(await _apiService.getFormHeaders());

    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'), // change type if needed
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['image_url'];
    } else {
      throw Exception('Image upload failed: ${response.body}');
    }
  }
}
