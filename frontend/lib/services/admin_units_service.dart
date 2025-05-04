import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AdminUnitService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> fetchUnits() async {
    final res = await _apiService.get('/admin/units/');
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to load units');
    }
  }

  Future<http.Response> submitUnit({
    required String title,
    required String description,
    required int orderIndex,
    int? editingUnitId,
    bool usePatch = false,
  }) async {
    if (title.isEmpty) {
      throw Exception('Title is required');
    }

    final endpoint =
        editingUnitId != null ? '/admin/units/$editingUnitId' : '/admin/units/';

    final body = {
      'title': title,
      'description': description,
      'order_index': orderIndex.toString(),
      'status': 'active',
    };

    if (editingUnitId != null) {
      if (usePatch) {
        return await _apiService.patch(endpoint, body);
      } else {
        return await _apiService.putForm(endpoint, body);
      }
    } else {
      return await _apiService.postForm(endpoint, body);
    }
  }

  Future<http.Response> deleteUnit(int unitId) async {
    return await _apiService.patch('/admin/units/$unitId/archive', {});
  }
}
