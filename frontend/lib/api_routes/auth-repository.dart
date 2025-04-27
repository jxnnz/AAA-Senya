import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_routes/models/user-model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final String baseUrl = 'http://localhost:8000';
  final secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // Store token in secure storage
      await secureStorage.write(
        key: 'token',
        value: jsonResponse['access_token'],
      );

      final user = User.fromJson(jsonResponse['user']);

      // Also store user role for quicker access
      await secureStorage.write(key: 'user_role', value: user.role);

      // Determine where to redirect based on user role
      final redirectPath = user.role == 'admin' ? '/admin' : '/home';

      return {
        'user': user,
        'token': jsonResponse['access_token'],
        'token_type': jsonResponse['token_type'],
        'redirect': redirectPath,
      };
    } else {
      final error = jsonDecode(response.body)['detail'] ?? 'Failed to login';
      throw Exception(error);
    }
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  Future<String?> getUserRole() async {
    return await secureStorage.read(key: 'user_role');
  }

  // Add this method to your AuthRepository class
  Future<Map<String, dynamic>?> checkAuthStatus() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      // Fetch current user data from the API
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final user = User.fromJson(jsonResponse['user']);

        return {'user': user, 'token': token};
      } else {
        // Token is invalid or expired, clear it
        await logout();
        return null;
      }
    } catch (e) {
      print('Error checking auth status: $e');
      return null;
    }
  }

  // Add this method to your AuthRepository class in auth-repository.dart

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);

      // Store token in secure storage
      await secureStorage.write(
        key: 'token',
        value: jsonResponse['access_token'],
      );

      final user = User.fromJson(jsonResponse['user']);

      // Also store user role for quicker access
      await secureStorage.write(key: 'user_role', value: user.role);

      // Determine where to redirect based on user role
      final redirectPath = user.role == 'admin' ? '/admin' : '/home';

      return {
        'user': user,
        'token': jsonResponse['access_token'],
        'token_type': jsonResponse['token_type'],
        'redirect': redirectPath,
      };
    } else {
      final error = jsonDecode(response.body)['detail'] ?? 'Failed to register';
      throw Exception(error);
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'user_role');
  }
}
