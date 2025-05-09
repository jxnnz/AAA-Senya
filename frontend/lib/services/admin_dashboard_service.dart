// services/admin_dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AdminDashboardService {
  final String baseUrl = 'http://localhost:8000/api/admin/dashboard';

  Future<Map<String, dynamic>> fetchSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = await ApiService().getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/summary'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard summary');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLessonsPerUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/lessons-per-unit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load lessons per unit');
    }
  }

  Future<Map<String, dynamic>> fetchUserPerformance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user-performance'),
      headers: await ApiService().getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch user performance");
    }
  }
}
