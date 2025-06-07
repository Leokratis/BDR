import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  UserData? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserData? get currentUser => _currentUser;

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final token = await ApiService.getAuthToken();
      _isAuthenticated = token != null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    }
    _setLoading(false);
  }

  Future<void> setAuthToken(String token) async {
    _setLoading(true);
    try {
      await ApiService.setAuthToken(token);
      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    }
    _setLoading(false);
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await ApiService.clearAuthToken();
      _isAuthenticated = false;
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadCurrentUser(String userId) async {
    if (!_isAuthenticated) return;

    _setLoading(true);
    try {
      _currentUser = await ApiService.getUser(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('Unauthorized')) {
        _isAuthenticated = false;
        _currentUser = null;
      }
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
