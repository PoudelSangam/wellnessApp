import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  UserModel? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  AuthProvider(this._storage) {
    _initializeAuth();
  }
  
  // Getters
  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  
  // Initialize Authentication
  Future<void> _initializeAuth() async {
    try {
      _accessToken = await _storageService.getAccessToken();
      _refreshToken = await _storageService.getRefreshToken();
      
      if (_accessToken != null && _refreshToken != null) {
        _isAuthenticated = true;
        await fetchUserProfile();
      }
    } catch (e) {
      Logger.error('Auth initialization error: $e');
      await logout();
    }
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String username, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final response = await _apiService.post(
        ApiConstants.login,
        headers: ApiConstants.getHeaders(),
        body: {
          'username': username,
          'password': password,
        },
      );
      
      _accessToken = response['access'];
      _refreshToken = response['refresh'];
      
      await _storageService.saveTokens(_accessToken!, _refreshToken!);
      await _storageService.saveBool(AppConstants.isLoggedInKey, true);
      
      _isAuthenticated = true;
      
      // Fetch user profile
      await fetchUserProfile();
      
      _setLoading(false);
      Logger.success('Login successful');
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      Logger.error('Login failed: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setLoading(false);
      Logger.error('Login error: $e');
      return false;
    }
  }
  
  // Signup
  Future<bool> signup(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final response = await _apiService.post(
        ApiConstants.signup,
        headers: ApiConstants.getHeaders(),
        body: userData,
      );
      
      // Auto-login after signup (if tokens are returned)
      if (response.containsKey('access') && response.containsKey('refresh')) {
        _accessToken = response['access'];
        _refreshToken = response['refresh'];
        
        await _storageService.saveTokens(_accessToken!, _refreshToken!);
        await _storageService.saveBool(AppConstants.isLoggedInKey, true);
        
        _isAuthenticated = true;
        
        await fetchUserProfile();
      }
      
      _setLoading(false);
      Logger.success('Signup successful');
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      Logger.error('Signup failed: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setLoading(false);
      Logger.error('Signup error: $e');
      return false;
    }
  }
  
  // Fetch User Profile
  Future<void> fetchUserProfile() async {
    try {
      final response = await _apiService.get(
        ApiConstants.userProfile,
        headers: ApiConstants.getHeaders(token: _accessToken),
      );
      
      _user = UserModel.fromJson(response);
      notifyListeners();
      Logger.success('User profile fetched');
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await refreshAccessToken();
        await fetchUserProfile();
      } else {
        Logger.error('Fetch profile failed: ${e.message}');
      }
    } catch (e) {
      Logger.error('Fetch profile error: $e');
    }
  }
  
  // Refresh Access Token
  Future<bool> refreshAccessToken() async {
    try {
      if (_refreshToken == null) {
        await logout();
        return false;
      }
      
      final response = await _apiService.post(
        ApiConstants.tokenRefresh,
        headers: ApiConstants.getHeaders(),
        body: {'refresh': _refreshToken},
      );
      
      _accessToken = response['access'];
      await _storageService.saveSecure(AppConstants.accessTokenKey, _accessToken!);
      
      Logger.success('Token refreshed');
      return true;
    } on ApiException catch (e) {
      Logger.error('Token refresh failed: ${e.message}');
      await logout();
      return false;
    } catch (e) {
      Logger.error('Token refresh error: $e');
      await logout();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _storageService.clearTokens();
      await _storageService.saveBool(AppConstants.isLoggedInKey, false);
      
      _user = null;
      _accessToken = null;
      _refreshToken = null;
      _isAuthenticated = false;
      
      notifyListeners();
      Logger.success('Logged out');
    } catch (e) {
      Logger.error('Logout error: $e');
    }
  }
  
  // Update User
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Set Loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
