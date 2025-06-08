import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true; 
  String? _error;
  UserData? _currentUser;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserData? get currentUser => _currentUser;
  String? get token => _token;

  set currentUser(UserData? userData) {
    _currentUser = userData;
    notifyListeners();
  }
  Future<void> checkAuthStatus() async {
    debugPrint("AuthProvider: checkAuthStatus called");
    _error = null; 
    try {
      final tokenValue = await ApiService.getAuthToken();
      if (tokenValue != null && tokenValue.isNotEmpty) {
        _isAuthenticated = true;
        _token = tokenValue;
        debugPrint("AuthProvider: Token found from storage: $tokenValue.");
        
        // Extract userId from token structure: userId|userType|token
        String? userId;
        try {
          final tokenParts = tokenValue.split('|');
          if (tokenParts.length >= 3) {
            userId = tokenParts[0]; // First part should be the user ID
            debugPrint("AuthProvider: Extracted userId from stored token: '$userId'");
            // Load user data with the extracted userId
            await loadCurrentUser(userId);
          } else {
            debugPrint("AuthProvider: Token doesn't match expected format (userId|userType|token)");
          }
        } catch (e) {
          debugPrint("AuthProvider: Error extracting userId from stored token: $e");
        }
      } else {
        _isAuthenticated = false;
        _token = null;
        debugPrint("AuthProvider: No token found in storage.");
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("AuthProvider: Error in checkAuthStatus: $_error");
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> setAuthToken(String token, {String? userId}) async {
    debugPrint("AuthProvider: setAuthToken called with token: '$token', userId: '$userId'");
    _setLoading(true);
    _error = null;
    try {
      await ApiService.setAuthToken(token);
      _isAuthenticated = true;
      _token = token; 
      debugPrint("AuthProvider: Token set in ApiService. isAuthenticated: $_isAuthenticated.");
      // Determine the userId to use for loading the current user.
      // Priority: 1. Explicitly passed userId, 2. Current user's ID (if any), 3. Empty string (which might be problematic if not mock).
      String effectiveUserId = userId ?? _currentUser?.id ?? '';
      debugPrint("AuthProvider: Effective userId for loadCurrentUser: '$effectiveUserId'");
      await loadCurrentUser(effectiveUserId);
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false; 
      _token = null;
      debugPrint("AuthProvider: Error in setAuthToken: $_error");
    }
    _setLoading(false);
  }

  Future<void> logout() async {
    debugPrint("AuthProvider: logout called");
    _setLoading(true);
    _error = null;
    try {
      await ApiService.clearAuthToken(); 
      _isAuthenticated = false;
      _currentUser = null;
      _token = null;
      debugPrint("AuthProvider: Logout successful. Token cleared.");
    } catch (e) {
      _error = e.toString();
      debugPrint("AuthProvider: Error in logout: $_error");
    }
    _setLoading(false);
  }

  Future<void> loadCurrentUser(String userId) async {
    debugPrint("AuthProvider: loadCurrentUser called with userId: '$userId'");
    if (!_isAuthenticated) {
      debugPrint("AuthProvider: Not authenticated, skipping loadCurrentUser.");
      _setLoading(false); 
      return;
    }
    if (token == null || token!.isEmpty) {
       debugPrint("AuthProvider: Token is null or empty, cannot load user.");
      _setLoading(false);
      return;
    }
    
    // ApiService.getUser will handle mock logic and empty userId for mock user.
    // For non-mock scenarios, ApiService.getUser now throws an error if userId is empty.
    _setLoading(true);
    _error = null;
    try {
      debugPrint("AuthProvider: Attempting to get user with ID: '$userId'.");
      _currentUser = await ApiService.getUser(userId);
      debugPrint("AuthProvider: User data loaded: Name: ${_currentUser?.name}, ID: ${_currentUser?.id}");
    } catch (e) {
      _error = e.toString();
      debugPrint("AuthProvider: Error in loadCurrentUser: $_error");
      if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        debugPrint("AuthProvider: Unauthorized error during loadCurrentUser, clearing session.");
        await ApiService.clearAuthToken();
        _isAuthenticated = false;
        _currentUser = null;
        _token = null;
      }
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
