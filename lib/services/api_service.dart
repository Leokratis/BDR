import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_response.dart';

class ApiService {
  static const String baseUrl = 'https://service.blooddonorregistry.gr';
  static const String _tokenKey = 'x_auth_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Store authentication token
  static Future<void> setAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get stored authentication token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Clear authentication token
  static Future<void> clearAuthToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Helper method to create headers
  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getAuthToken();
      if (token != null) {
        headers['X-Auth-Token'] = token;
      }
    }

    return headers;
  }

  // Helper method to handle API responses
  static T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return fromJson(jsonData);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    } else if (response.statusCode == 304) {
      throw Exception('Not modified');
    } else {
      final errorMessage = response.body.isNotEmpty 
          ? json.decode(response.body)['message'] ?? 'Unknown error'
          : 'HTTP ${response.statusCode}';
      throw Exception('API Error: $errorMessage');
    }
  }

  // GET /captcha - Get captcha data (no auth required)
  static Future<CaptchaData> getCaptcha() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/captcha'),
        headers: await _getHeaders(requireAuth: false),
      );

      return _handleResponse(response, (json) => CaptchaData.fromJson(json));
    } catch (e) {
      throw Exception('Failed to get captcha: $e');
    }
  }

  // GET /v2/user/{id} - Get user info
  static Future<UserData> getUser(String userId, {String? language, String? ifModifiedSince}) async {
    try {
      final headers = await _getHeaders();
      if (language != null) {
        headers['Accept-Language'] = language;
      }
      if (ifModifiedSince != null) {
        headers['If-Modified-Since'] = ifModifiedSince;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v2/user/$userId'),
        headers: headers,
      );

      return _handleResponse(response, (json) => UserData.fromJson(json));
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // GET /v2/donations - Get donations
  static Future<List<Donation>> getDonations({String? language, String? ifModifiedSince}) async {
    try {
      final headers = await _getHeaders();
      if (language != null) {
        headers['Accept-Language'] = language;
      }
      if (ifModifiedSince != null) {
        headers['If-Modified-Since'] = ifModifiedSince;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v2/donations'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return [];
        }
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Donation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 304) {
        throw Exception('Not modified');
      } else {
        final errorMessage = response.body.isNotEmpty 
            ? json.decode(response.body)['message'] ?? 'Unknown error'
            : 'HTTP ${response.statusCode}';
        throw Exception('API Error: $errorMessage');
      }
    } catch (e) {
      throw Exception('Failed to get donations: $e');
    }
  }

  // GET /v2/coverages - Get coverages
  static Future<List<Coverage>> getCoverages({String? language, String? ifModifiedSince}) async {
    try {
      final headers = await _getHeaders();
      if (language != null) {
        headers['Accept-Language'] = language;
      }
      if (ifModifiedSince != null) {
        headers['If-Modified-Since'] = ifModifiedSince;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v2/coverages'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return [];
        }
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Coverage.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 304) {
        throw Exception('Not modified');
      } else {
        final errorMessage = response.body.isNotEmpty 
            ? json.decode(response.body)['message'] ?? 'Unknown error'
            : 'HTTP ${response.statusCode}';
        throw Exception('API Error: $errorMessage');
      }
    } catch (e) {
      throw Exception('Failed to get coverages: $e');
    }
  }

  // POST /contact - Send issue/contact
  static Future<void> sendIssue(ContactIssue issue) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contact'),
        headers: await _getHeaders(requireAuth: false),
        body: json.encode(issue.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else if (response.statusCode == 400) {
        final errorMessage = response.body.isNotEmpty 
            ? json.decode(response.body)['message'] ?? 'Bad request'
            : 'Bad request';
        throw Exception('Bad request: $errorMessage');
      } else {
        final errorMessage = response.body.isNotEmpty 
            ? json.decode(response.body)['message'] ?? 'Unknown error'
            : 'HTTP ${response.statusCode}';
        throw Exception('API Error: $errorMessage');
      }
    } catch (e) {
      throw Exception('Failed to send issue: $e');
    }
  }
}
