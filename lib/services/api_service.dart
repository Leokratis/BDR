import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_response.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class ApiService {
  // Updated base URL based on the official API documentation
  static const String baseUrl = 'https://service.blooddonorregistry.gr/v2';
  static const String _tokenKey = 'x_auth_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // --- START MOCK DATA ---
  static const String _mockToken = 'Leokratis';

  static bool _isMockMode = false;

  static Future<void> _checkMockMode() async {
    final token = await _storage.read(key: _tokenKey); // Read directly to avoid loop with getAuthToken logging
    _isMockMode = token == _mockToken;
    debugPrint("ApiService: _checkMockMode. Token from storage: '$token'. Mock mode is now: $_isMockMode");
  }

  static bool get isMockMode => _isMockMode; // Public getter for read-only access

  // Test basic network connectivity
  static Future<bool> testNetworkConnectivity() async {
    try {
      debugPrint("ApiService: Testing network connectivity...");
      final result = await InternetAddress.lookup('google.com');
      bool isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      debugPrint("ApiService: Network connectivity test result: $isConnected");
      return isConnected;
    } catch (e) {
      debugPrint("ApiService: Network connectivity test failed: $e");
      return false;
    }
  }
  // Test API endpoint accessibility
  static Future<bool> testApiEndpoint() async {
    try {
      debugPrint("ApiService: Testing API endpoint accessibility...");
      final response = await http.head(Uri.parse(baseUrl)).timeout(const Duration(seconds: 10));
      bool isAccessible = response.statusCode >= 200 && response.statusCode < 400;
      debugPrint("ApiService: API endpoint test result: $isAccessible (status: ${response.statusCode})");
      return isAccessible;
    } catch (e) {
      debugPrint("ApiService: API endpoint test failed: $e");
      return false;
    }
  }

  static UserData get _mockUserData => UserData(
        id: 'mock-user-123',
        name: 'Leokratis Mock',
        email: 'leokratis.mock@example.com',
        phone: '1234567890',
        bloodType: 'O+',
        lastDonation: DateTime(2025, 1, 15),
        totalDonations: 10,
      );

  static List<Donation> get _mockDonations => [
        Donation(
          id: 'mock-donation-1',
          date: DateTime(2025, 1, 15),
          location: 'Mock Hospital A',
          bloodType: 'O+',
          status: 'Completed',
          hemoglobin: 14.5,
          notes: 'Regular donation.',
        ),
        Donation(
          id: 'mock-donation-2',
          date: DateTime(2024, 9, 10),
          location: 'Mock Blood Center B',
          bloodType: 'O+',
          status: 'Completed',
          hemoglobin: 15.0,
        ),
      ];

  static List<Coverage> get _mockCoverages => [
        Coverage(
          id: 'mock-coverage-1',
          name: 'Emergency Blood Drive - Mock City',
          type: 'Urgent',
          location: 'Mock City Hall',
          startDate: DateTime(2025, 6, 10),
          endDate: DateTime(2025, 6, 12),
          status: 'Active',
        ),
        Coverage(
          id: 'mock-coverage-2',
          name: 'Regular Coverage - Mock County',
          type: 'Scheduled',
          location: 'Mock County Hospital',
          status: 'Ongoing',
        ),
      ];
  
  static CaptchaData get _mockCaptchaData => CaptchaData(
        id: 'mock-captcha-123',
        image: 'iVBORw0KGgoAAAANSUhEUgAAAGQAAAAoCAYAAAAIeF9DAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACYSURBVHhe7c4xEQAgDAAxhL/nDOEXg8HYp80L7mY3S5IkSZIkyVpLkv4gSZIkSZIsS5LkP0iSJEmSJMuSJP9BkiRJkiTLkiT5D5IkSZIkS5Yk+Q+SJEmSJEmWJPlPkpL+IWkPSZIkyVpLkv4gSZIkSZIsS5LkP0iSJEmSJMuSJP9BkiRJkiTLkiT5D5IkSZIkS5Yk+Q+SJEmSJEmWJPkPknV/AEYYAb0k2u5yAAAAAElFTkSuQmCC', // A simple 100x40 transparent png as placeholder
      );

  // --- END MOCK DATA ---

  // Store authentication token
  static Future<void> setAuthToken(String token) async {
    debugPrint("ApiService: setAuthToken called with token: '$token'");
    await _storage.write(key: _tokenKey, value: token);
    await _checkMockMode();
  }

  // Get stored authentication token
  static Future<String?> getAuthToken() async {
    final token = await _storage.read(key: _tokenKey);
    // Avoid calling _checkMockMode here to prevent potential loops if called during _checkMockMode itself.
    debugPrint("ApiService: getAuthToken called. Token retrieved from storage: '$token'");
    return token;
  }

  // Clear authentication token
  static Future<void> clearAuthToken() async {
    debugPrint("ApiService: clearAuthToken called.");
    await _storage.delete(key: _tokenKey);
    await _checkMockMode();
  }
  // Helper method to create headers
  static Future<Map<String, String>> _getHeaders({bool requireAuth = true, String? language}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': language ?? 'en', // Default to English if no language specified
    };
    // debugPrint("ApiService: _getHeaders called. requireAuth: $requireAuth"); // Can be noisy

    if (requireAuth) {
      final token = await getAuthToken(); // This now has its own log
      if (token != null && token.isNotEmpty) {
        headers['X-Auth-Token'] = token;
        debugPrint("ApiService: X-Auth-Token: '$token' added to headers.");
      } else {
        debugPrint("ApiService: Auth required for _getHeaders but no token found.");
      }
    }
    return headers;
  }
  // Helper method to handle API responses
  static T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    String responseBodySnippet = response.body.length > 200 ? response.body.substring(0, 200) : response.body;
    debugPrint("ApiService: _handleResponse. Status: ${response.statusCode}, Body (snippet): $responseBodySnippet...");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }
      
      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<')) {
        debugPrint("ApiService: Received HTML response instead of JSON. Status: ${response.statusCode}");
        throw Exception('Server returned HTML instead of JSON. This might indicate a server configuration issue.');
      }
      
      try {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return fromJson(jsonData);
      } catch (e) {
        debugPrint("ApiService: Failed to parse JSON response: $e");
        throw Exception('Invalid JSON response from server');
      }
    } else if (response.statusCode == 401) {
      debugPrint("ApiService: Unauthorized (401) response in _handleResponse.");
      throw Exception('Unauthorized - Please login again');
    } else if (response.statusCode == 404) {
      debugPrint("ApiService: Not Found (404) response in _handleResponse.");
      throw Exception('API endpoint not found - Server configuration issue');
    } else if (response.statusCode == 304) {
      debugPrint("ApiService: Not Modified (304) response in _handleResponse.");
      throw Exception('Not modified');
    } else {
      // Handle HTML error responses
      if (response.body.trim().startsWith('<')) {
        debugPrint("ApiService: Received HTML error response (Status: ${response.statusCode})");
        throw Exception('Server returned HTML error page (${response.statusCode}). Check API configuration.');
      }
      
      try {
        final errorMessage = response.body.isNotEmpty 
            ? json.decode(response.body)['message'] ?? 'Unknown error'
            : 'HTTP ${response.statusCode}';
        debugPrint("ApiService: API Error in _handleResponse. Status: ${response.statusCode}, Decoded Message: $errorMessage");
        throw Exception('API Error: $errorMessage');
      } catch (e) {
        debugPrint("ApiService: Failed to parse error response: $e");
        throw Exception('HTTP ${response.statusCode}: ${response.body.isNotEmpty ? "Server error" : "No response"}');
      }
    }
  }
  // GET /captcha - Get captcha data (no auth required)
  static Future<CaptchaData> getCaptcha() async {
    await _checkMockMode(); // Check mock mode for captcha too
    debugPrint("ApiService: getCaptcha called. Current mock mode: $_isMockMode");
    if (_isMockMode) {
      debugPrint('ApiService: In mock mode, returning MOCK CaptchaData.');
      return Future.delayed(const Duration(milliseconds: 300), () => _mockCaptchaData);
    }    try {      final response = await http.get(
        Uri.parse('https://service.blooddonorregistry.gr/v2/captcha'),
        headers: await _getHeaders(requireAuth: false, language: 'en'),
      );

      return _handleResponse(response, (json) => CaptchaData.fromJson(json));
    } catch (e) {
      throw Exception('Failed to get captcha: $e');
    }
  }

  // GET /v2/user/{id} - Get user info
  static Future<UserData> getUser(String userId, {String? language, String? ifModifiedSince}) async {
    await _checkMockMode();
    debugPrint("ApiService: getUser called with userId: '$userId'. Current mock mode: $_isMockMode");

    if (_isMockMode) {
      // Corrected string interpolation for debugPrint
      debugPrint("ApiService: In mock mode, returning MOCK UserData for userId: '$userId' (actual ID ignored for mock).");
      return Future.delayed(const Duration(milliseconds: 300), () => _mockUserData);
    }    if (userId.isEmpty) {
      debugPrint("ApiService: getUser called with EMPTY userId and NOT in mock mode. Throwing error.");
      throw Exception("User ID cannot be empty when fetching user data.");
    }

    // Test network connectivity first
    debugPrint("ApiService: getUser - Testing network connectivity...");
    bool isConnected = await testNetworkConnectivity();
    if (!isConnected) {
      throw Exception('No internet connection available');
    }

    // Test API endpoint accessibility
    debugPrint("ApiService: getUser - Testing API endpoint...");
    bool isApiAccessible = await testApiEndpoint();
    if (!isApiAccessible) {
      throw Exception('API endpoint is not accessible');    }

    try {
      final headers = await _getHeaders(language: language ?? 'en');
      if (ifModifiedSince != null) {
        headers['If-Modified-Since'] = ifModifiedSince;
      }      final uri = Uri.parse('$baseUrl/user/$userId');
      debugPrint("ApiService: getUser - About to make HTTP GET request to: $uri");
      debugPrint("ApiService: getUser - Headers: $headers");
      
      debugPrint("ApiService: getUser - Making HTTP request...");
      final response = await http.get(uri, headers: headers);
      debugPrint("ApiService: getUser - HTTP request completed. Status: ${response.statusCode}");

      return _handleResponse(response, (json) => UserData.fromJson(json));
    } catch (e) {
      debugPrint("ApiService: getUser - Exception caught: $e");
      throw Exception('Failed to get user data: $e');
    }
  }

  // GET /donations - Get donations for the authenticated user
  static Future<List<Donation>> getDonations(String userId, {String? language, String? ifModifiedSince}) async {
    await _checkMockMode();
    debugPrint("ApiService: getDonations called with userId: '$userId'. Current mock mode: $_isMockMode");
    if (_isMockMode) {
      debugPrint('ApiService: In mock mode, returning MOCK Donations.');
      return Future.delayed(const Duration(milliseconds: 300), () => _mockDonations);
    }

    // New API no longer requires the userId in the path. Keep parameter for backward compatibility.
    if (userId.isEmpty) {
      debugPrint("ApiService: getDonations called without userId - continuing as it's optional in the new API");
    }
    // Test network connectivity first
    debugPrint("ApiService: getDonations - Testing network connectivity...");
    bool isConnected = await testNetworkConnectivity();
    if (!isConnected) {
      throw Exception('No internet connection available');
    }

    try {      final headers = await _getHeaders(language: language ?? 'en');
      if (ifModifiedSince != null) {
        headers['If-Modified-Since'] = ifModifiedSince;
      }      final uri = Uri.parse('$baseUrl/donations');
      debugPrint("ApiService: getDonations - About to make HTTP GET request to: $uri");
      debugPrint("ApiService: getDonations - Headers: $headers");
      
      debugPrint("ApiService: getDonations - Making HTTP request...");
      final response = await http.get(uri, headers: headers);
      debugPrint("ApiService: getDonations - HTTP request completed. Status: ${response.statusCode}");      debugPrint("ApiService: getDonations - HTTP request completed. Status: ${response.statusCode}");
      String responseBodySnippet = response.body.length > 200 ? response.body.substring(0, 200) : response.body;
      debugPrint("ApiService: getDonations - Response body (snippet): $responseBodySnippet...");      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("ApiService: getDonations - Successful response, processing...");
        if (response.body.isEmpty) {
          debugPrint("ApiService: getDonations - Empty response body, returning empty list");
          return [];
        }
        
        // Check if response is HTML instead of JSON
        if (response.body.trim().startsWith('<')) {
          debugPrint("ApiService: getDonations - Received HTML response instead of JSON");
          throw Exception('Server returned HTML instead of JSON. This might indicate a server configuration issue.');
        }
        
        try {
          final List<dynamic> jsonList = json.decode(response.body);
          debugPrint("ApiService: getDonations - Decoded ${jsonList.length} donations");
          return jsonList.map((json) => Donation.fromJson(json)).toList();
        } catch (e) {
          debugPrint("ApiService: getDonations - Failed to parse JSON: $e");
          throw Exception('Invalid JSON response from server');
        }
      } else if (response.statusCode == 401) {
        debugPrint("ApiService: getDonations - Unauthorized (401) response");
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        debugPrint("ApiService: getDonations - Not Found (404) response");
        throw Exception('API endpoint not found - Server configuration issue');
      } else if (response.statusCode == 304) {
        debugPrint("ApiService: getDonations - Not Modified (304) response");
        throw Exception('Not modified');
      } else {
        // Handle HTML error responses
        if (response.body.trim().startsWith('<')) {
          debugPrint("ApiService: getDonations - Received HTML error response (Status: ${response.statusCode})");
          throw Exception('Server returned HTML error page (${response.statusCode}). Check API configuration.');
        }
        
        try {
          final errorMessage = response.body.isNotEmpty 
              ? json.decode(response.body)['message'] ?? 'Unknown error'
              : 'HTTP ${response.statusCode}';
          debugPrint("ApiService: getDonations - Error response. Status: ${response.statusCode}, Message: $errorMessage");
          throw Exception('API Error: $errorMessage');
        } catch (e) {
          debugPrint("ApiService: getDonations - Failed to parse error response: $e");
          throw Exception('HTTP ${response.statusCode}: ${response.body.isNotEmpty ? "Server error" : "No response"}');
        }
      }
    } catch (e) {
      debugPrint("ApiService: getDonations - Exception caught: $e");
      throw Exception('Failed to get donations: $e');
    }
  }

  // GET /coverages - Get coverages for the authenticated user
  static Future<List<Coverage>> getCoverages(String userId, {String? language, String? ifModifiedSince}) async {
    await _checkMockMode();
    debugPrint("ApiService: getCoverages called with userId: '$userId'. Current mock mode: $_isMockMode");
    if (_isMockMode) {
      debugPrint('ApiService: In mock mode, returning MOCK Coverages.');
      return Future.delayed(const Duration(milliseconds: 300), () => _mockCoverages);
    }

    // New API does not require the userId in the path
    if (userId.isEmpty) {
      debugPrint("ApiService: getCoverages called without userId - continuing as it's optional in the new API");
    }

    try {
      final headers = await _getHeaders(language: language ?? 'en');
      if (ifModifiedSince != null) {
        headers['If-Modified-Since'] = ifModifiedSince;
      }      final uri = Uri.parse('$baseUrl/coverages');
      debugPrint("ApiService: getCoverages - About to make HTTP GET request to: $uri");
      debugPrint("ApiService: getCoverages - Headers: $headers");
      
      final response = await http.get(uri, headers: headers);if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return [];
        }
        
        // Check if response is HTML instead of JSON
        if (response.body.trim().startsWith('<')) {
          debugPrint("ApiService: getCoverages - Received HTML response instead of JSON");
          throw Exception('Server returned HTML instead of JSON. This might indicate a server configuration issue.');
        }
        
        try {
          final List<dynamic> jsonList = json.decode(response.body);
          return jsonList.map((json) => Coverage.fromJson(json)).toList();
        } catch (e) {
          debugPrint("ApiService: getCoverages - Failed to parse JSON: $e");
          throw Exception('Invalid JSON response from server');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found - Server configuration issue');
      } else if (response.statusCode == 304) {
        throw Exception('Not modified');
      } else {
        // Handle HTML error responses
        if (response.body.trim().startsWith('<')) {
          debugPrint("ApiService: getCoverages - Received HTML error response (Status: ${response.statusCode})");
          throw Exception('Server returned HTML error page (${response.statusCode}). Check API configuration.');
        }
        
        try {
          final errorMessage = response.body.isNotEmpty 
              ? json.decode(response.body)['message'] ?? 'Unknown error'
              : 'HTTP ${response.statusCode}';
          throw Exception('API Error: $errorMessage');
        } catch (e) {
          debugPrint("ApiService: getCoverages - Failed to parse error response: $e");
          throw Exception('HTTP ${response.statusCode}: ${response.body.isNotEmpty ? "Server error" : "No response"}');
        }
      }
    } catch (e) {
      throw Exception('Failed to get coverages: $e');
    }
  }

  // POST /contact - Send issue/contact
  static Future<void> sendIssue(ContactIssue issue) async {
    // await _checkMockMode(); // Not typically needed for sendIssue if it can be pre-login or uses captcha
    debugPrint("ApiService: sendIssue called. Current mock mode (may not be checked for this call): $_isMockMode. Issue: ${issue.toJson()}");
    if (_isMockMode && await getAuthToken() == _mockToken) { // Make mock sendIssue conditional on mock token if desired
      debugPrint('ApiService: MOCK sendIssue called with mock token. Data: ${issue.toJson()}');
      // Simulate a successful API call for contact form in mock mode
      return Future.delayed(const Duration(milliseconds: 300)); 
    }    try {      final response = await http.post(
        Uri.parse('https://service.blooddonorregistry.gr/v2/contact'),
        headers: await _getHeaders(requireAuth: false, language: 'en'),
        body: json.encode(issue.toJson()),
      );if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else if (response.statusCode == 400) {
        // Handle HTML error responses
        if (response.body.trim().startsWith('<')) {
          debugPrint("ApiService: sendIssue - Received HTML error response (400)");
          throw Exception('Bad request - Server returned HTML error page');
        }
        
        try {
          final errorMessage = response.body.isNotEmpty 
              ? json.decode(response.body)['message'] ?? 'Bad request'
              : 'Bad request';
          throw Exception('Bad request: $errorMessage');
        } catch (e) {
          throw Exception('Bad request: Unable to parse error response');
        }
      } else {
        // Handle HTML error responses
        if (response.body.trim().startsWith('<')) {
          debugPrint("ApiService: sendIssue - Received HTML error response (${response.statusCode})");
          throw Exception('Server returned HTML error page (${response.statusCode}). Check API configuration.');
        }
        
        try {
          final errorMessage = response.body.isNotEmpty 
              ? json.decode(response.body)['message'] ?? 'Unknown error'
              : 'HTTP ${response.statusCode}';
          throw Exception('API Error: $errorMessage');
        } catch (e) {
          throw Exception('HTTP ${response.statusCode}: ${response.body.isNotEmpty ? "Server error" : "No response"}');
        }
      }
    } catch (e) {
      throw Exception('Failed to send issue: $e');
    }  }
}
