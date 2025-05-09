import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  Uri _buildUri(String endpoint) => Uri.parse('$baseUrl$endpoint');

  // Public token/user access
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> getFormHeaders() async {
    final token = await getToken();
    return {'Authorization': 'Bearer $token'};
  }

  Future<http.Response> get(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(_buildUri(endpoint), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET $endpoint failed: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        _buildUri(endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST $endpoint failed: $e');
      rethrow;
    }
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.patch(
        _buildUri(endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('PATCH $endpoint failed: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        _buildUri(endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT $endpoint failed: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(_buildUri(endpoint), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE $endpoint failed: $e');
      rethrow;
    }
  }

  Future<http.Response> postForm(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final headers = await getFormHeaders();
    return http.post(_buildUri(endpoint), headers: headers, body: data);
  }

  Future<http.Response> putForm(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final headers = await getFormHeaders();
    return http.put(_buildUri(endpoint), headers: headers, body: data);
  }

  http.Response _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return res;
    throw Exception('Request failed: ${res.statusCode} ${res.body}');
  }

  // Fetch available heart packages
  Future<List<dynamic>> getHeartPackages() async {
    final response = await get('/shop/heart-packages');
    return jsonDecode(response.body);
  }

  // Purchase heart package
  Future<Map<String, dynamic>> purchaseHearts(int userId, int packageId) async {
    final response = await post('/shop/purchase-hearts', {
      'user_id': userId,
      'package_id': packageId,
    });
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final response = await get('/profile/$userId');
    final data = jsonDecode(response.body);
    return {
      'rubies': data['profile']['rubies'],
      'hearts': data['profile']['hearts'],
    };
  }

  Future<List<dynamic>> fetchGeneratedQuiz(int lessonId) async {
    final token = await getToken(); // ✅ your bearer token
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/generate/$lessonId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch quiz: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserStatus() async {
    final userId = await getUserId();
    final response = await get('/status/$userId');
    return jsonDecode(response.body);
  }
}
