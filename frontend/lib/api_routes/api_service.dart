import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth-repository.dart';

class ApiService {
  final String baseUrl = "http://localhost:8000/api";
  String? _token;
  bool _isInitialized = false;
  final AuthRepository _authRepository = AuthRepository();

  Future<bool> ensureAuthenticated() async {
    if (!_isInitialized) {
      await init();
    }

    // If we still don't have a token after initialization
    if (_token == null || _token!.isEmpty) {
      // Try to get token from AuthRepository directly
      try {
        final token = await _authRepository.getToken();
        if (token != null && token.isNotEmpty) {
          await setToken(token);
          debugPrint(
            'Token retrieved from AuthRepository: ${token.substring(0, 10)}...',
          );
          return true;
        }
        debugPrint('No token available');
        return false;
      } catch (e) {
        debugPrint('Error getting token: $e');
        return false;
      }
    }

    debugPrint(
      'Already authenticated with token: ${_token!.substring(0, 10)}...',
    );
    return true;
  }

  // Initialize with token if available
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Try to get token from AuthRepository first
      final token = await _authRepository.getToken();
      if (token != null && token.isNotEmpty) {
        _token = token;
      } else {
        // Fall back to SharedPreferences if necessary
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('auth_token');
      }

      _isInitialized = true;
      debugPrint(
        'ApiService initialized with token: ${_token != null ? '${_token!.substring(0, 10)}...' : 'null'}',
      );
    } catch (e) {
      // Handle the error gracefully
      debugPrint('Error initializing ApiService: $e');
      // Continue without token
      _isInitialized = true;
    }
  }

  // Initialize without using shared preferences
  void initWithoutToken() {
    _token = null;
    _isInitialized = true;
  }

  // Set token after login
  Future<void> setToken(String token) async {
    _token = token;
    _isInitialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      debugPrint('Token saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving token to shared preferences: $e');
      // Continue even if we can't save the token
    }
  }

  // Headers with authentication
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Multipart form headers with authentication
  Map<String, String> get _multipartHeaders {
    return {
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // HTTP GET request
  Future<dynamic> get(String endpoint) async {
    if (!_isInitialized) {
      await init();
    }

    // For admin endpoints, ensure we're authenticated
    if (endpoint.startsWith('/admin/')) {
      final isAuthenticated = await ensureAuthenticated();
      if (!isAuthenticated) {
        throw Exception('Not authenticated for admin endpoint');
      }
    }

    debugPrint('GET request to: $baseUrl$endpoint');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return [];
        }
        return json.decode(response.body);
      } else {
        debugPrint('Error response body: ${response.body}');
        throw Exception(
          'Failed to load data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Exception in GET request: $e');
      throw Exception('Network error: $e');
    }
  }

  // HTTP POST request
  Future<dynamic> post(String endpoint, dynamic data) async {
    if (!_isInitialized) {
      await init();
    }

    debugPrint('POST request to: $baseUrl$endpoint');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        body: json.encode(data),
        headers: _headers,
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        return json.decode(response.body);
      } else {
        debugPrint('Error response body: ${response.body}');
        throw Exception(
          'Failed to post data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Exception in POST request: $e');
      throw Exception('Network error: $e');
    }
  }

  // HTTP POST form data request
  Future<dynamic> postForm(
    String endpoint,
    Map<String, String> formData,
  ) async {
    if (!_isInitialized) {
      await init();
    }

    debugPrint('POST FORM request to: $baseUrl$endpoint');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        body: formData,
        headers: {
          ...(_multipartHeaders),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        return json.decode(response.body);
      } else {
        debugPrint('Error response body: ${response.body}');
        throw Exception(
          'Failed to post form data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Exception in POST FORM request: $e');
      throw Exception('Network error: $e');
    }
  }

  // HTTP PUT request
  Future<dynamic> put(String endpoint, dynamic data) async {
    if (!_isInitialized) {
      await init();
    }

    debugPrint('PUT request to: $baseUrl$endpoint');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        body: json.encode(data),
        headers: _headers,
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        return json.decode(response.body);
      } else {
        debugPrint('Error response body: ${response.body}');
        throw Exception(
          'Failed to update data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Exception in PUT request: $e');
      throw Exception('Network error: $e');
    }
  }

  // HTTP PATCH request
  Future<dynamic> patch(String endpoint, [dynamic data]) async {
    if (!_isInitialized) {
      await init();
    }

    debugPrint('PATCH request to: $baseUrl$endpoint');

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        body: data != null ? json.encode(data) : null,
        headers: _headers,
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return true;
        }
        return json.decode(response.body);
      } else {
        debugPrint('Error response body: ${response.body}');
        throw Exception(
          'Failed to patch data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Exception in PATCH request: $e');
      throw Exception('Network error: $e');
    }
  }

  // HTTP multipart request for file uploads
  Future<dynamic> uploadFile(
    String endpoint,
    Map<String, String> fields,
    String filePath,
    String fileField,
  ) async {
    if (!_isInitialized) {
      await init();
    }

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    request.headers.addAll(_multipartHeaders);
    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return true;
    } else {
      throw Exception(
        'Failed to upload file: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // HTTP DELETE request
  Future<dynamic> delete(String endpoint) async {
    if (!_isInitialized) {
      await init();
    }

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return true;
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to delete: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
