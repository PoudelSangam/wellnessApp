import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
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

  bool _isPlaceholderName(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty || normalized == 'user' || normalized == 'ram';
  }

  String get preferredDisplayName {
    final userDisplayName = _user?.displayName?.trim() ?? '';
    if (!_isPlaceholderName(userDisplayName)) {
      return userDisplayName;
    }

    final tokenDisplayName = _extractDisplayNameFromToken(_accessToken);
    if (tokenDisplayName.isNotEmpty) {
      return tokenDisplayName;
    }

    final fallbackUsername = _user?.username.trim() ?? '';
    if (!_isPlaceholderName(fallbackUsername)) {
      return fallbackUsername;
    }

    return 'User';
  }
  
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

      // Immediate fallback so UI can greet with username even before profile API succeeds.
      _user ??= UserModel(
        email: 'unknown@example.com',
        username: username,
      );
      notifyListeners();
      
      // Fetch user profile
      await fetchUserProfile();
      
      _setLoading(false);
      Logger.success('Login successful');
      return true;
    } on DioException catch (e) {
      final apiException = e.error is ApiException ? e.error as ApiException : null;
      _errorMessage = apiException?.message ?? 'Login failed. Please try again.';
      _setLoading(false);
      Logger.error('Login failed: $_errorMessage');
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

        final signupUsername = (userData['username'] ?? '').toString().trim();
        _user ??= UserModel(
          email: (userData['email'] ?? 'unknown@example.com').toString(),
          username: signupUsername.isNotEmpty ? signupUsername : 'User',
        );
        notifyListeners();
        
        await fetchUserProfile();
      }
      
      _setLoading(false);
      Logger.success('Signup successful');
      return true;
    } on DioException catch (e) {
      final apiException = e.error is ApiException ? e.error as ApiException : null;
      _errorMessage = apiException?.message ?? 'Signup failed. Please try again.';
      _setLoading(false);
      Logger.error('Signup failed: $_errorMessage');
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setLoading(false);
      Logger.error('Signup error: $e');
      return false;
    }
  }
  
  // Fetch User Profile
  Future<void> fetchUserProfile({bool retryOnUnauthorized = true}) async {
    try {
      final productionProfileEndpoint = '${ApiConstants.baseUrl}${ApiConstants.profile}';
      Logger.info('AuthProvider.fetchUserProfile endpoint: $productionProfileEndpoint');

      Map<String, dynamic> response;
      try {
        // Use absolute URL to avoid stale localhost base-url state.
        response = await _apiService.get(
          productionProfileEndpoint,
          headers: ApiConstants.getHeaders(token: _accessToken),
        );
      } on DioException catch (e) {
        Logger.warning(
          'Primary profile endpoint failed, retrying with active base URL: ${e.message}',
        );
        response = await _apiService.get(
          ApiConstants.profile,
          headers: ApiConstants.getHeaders(token: _accessToken),
        );
      }

      final normalizedProfile = _normalizeProfileResponse(response);
      _user = UserModel.fromJson(normalizedProfile);
      notifyListeners();
      Logger.success('User profile fetched');
    } on DioException catch (e) {
      final apiException = e.error is ApiException ? e.error as ApiException : null;
      if (apiException?.statusCode == 401 || e.response?.statusCode == 401) {
        if (retryOnUnauthorized) {
          final refreshed = await refreshAccessToken();
          if (refreshed) {
            await fetchUserProfile(retryOnUnauthorized: false);
          }
        }
      } else {
        Logger.error('Fetch profile failed: ${apiException?.message ?? e.toString()}');
      }
    } catch (e) {
      Logger.error('Fetch profile error: $e');
    }
  }

  Map<String, dynamic> _normalizeProfileResponse(Map<String, dynamic> response) {
    dynamic nestedProfile;
    if (response['user'] is Map<String, dynamic>) {
      nestedProfile = response['user'];
    } else if (response['data'] is Map<String, dynamic>) {
      nestedProfile = response['data'];
    } else if (response['profile'] is Map<String, dynamic>) {
      nestedProfile = response['profile'];
    } else if (response['account'] is Map<String, dynamic>) {
      nestedProfile = response['account'];
    } else if (response['results'] is List && (response['results'] as List).isNotEmpty) {
      nestedProfile = (response['results'] as List).first;
    } else {
      nestedProfile = response;
    }

    final profile = nestedProfile is Map<String, dynamic>
        ? Map<String, dynamic>.from(nestedProfile)
        : <String, dynamic>{};

    var firstName =
        (profile['first_name'] ?? profile['firstName'] ?? '').toString().trim();
    var lastName =
        (profile['last_name'] ?? profile['lastName'] ?? '').toString().trim();
    final fullName =
        (profile['full_name'] ?? profile['fullName'] ?? profile['name'] ?? '')
            .toString()
            .trim();

    if (fullName.isNotEmpty && firstName.isEmpty && lastName.isEmpty) {
      final parts = fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }
    }

    final email = (profile['email'] ?? '').toString().trim();
    final username = (profile['username'] ?? profile['user_name'] ?? profile['userName'] ?? '')
        .toString()
        .trim();

    // API may return numeric id; UserModel expects a string id.
    if (profile['id'] != null) {
      profile['id'] = profile['id'].toString();
    }

    final nameFallback = [firstName, lastName]
        .where((name) => name.isNotEmpty)
        .join(' ')
        .trim();
    final emailLocalPart = email.contains('@') ? email.split('@').first.trim() : '';
    final existingUsername = _user?.username.trim() ?? '';
    final safeExistingUsername = _isPlaceholderName(existingUsername) ? '' : existingUsername;

    profile['first_name'] = firstName;
    profile['last_name'] = lastName;
    profile['username'] = username.isNotEmpty
        ? username
        : nameFallback.isNotEmpty
            ? nameFallback
            : emailLocalPart.isNotEmpty
                ? emailLocalPart
          : safeExistingUsername.isNotEmpty
            ? safeExistingUsername
            : 'User';
    profile['email'] = email.isNotEmpty
        ? email
        : (_user?.email.isNotEmpty == true ? _user!.email : 'unknown@example.com');

    return profile;
  }

  String _extractDisplayNameFromToken(String? token) {
    if (token == null || token.trim().isEmpty) {
      return '';
    }

    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return '';
      }

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = jsonDecode(payload);
      if (claims is! Map<String, dynamic>) {
        return '';
      }

      final firstName =
          (claims['first_name'] ?? claims['firstName'] ?? '').toString().trim();
      final lastName =
          (claims['last_name'] ?? claims['lastName'] ?? '').toString().trim();
      final fullName = [firstName, lastName]
          .where((part) => part.isNotEmpty)
          .join(' ')
          .trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }

      final claimName = (claims['name'] ?? claims['full_name'] ?? claims['fullName'] ?? '')
          .toString()
          .trim();
      if (claimName.isNotEmpty) {
        return claimName;
      }

      final preferredUsername = (claims['preferred_username'] ??
              claims['username'] ??
              claims['user_name'] ??
              '')
          .toString()
          .trim();
      if (preferredUsername.isNotEmpty) {
        return preferredUsername;
      }

      final email = (claims['email'] ?? '').toString().trim();
      if (email.contains('@')) {
        final localPart = email.split('@').first.trim();
        if (localPart.isNotEmpty) {
          return localPart;
        }
      }
    } catch (_) {
      // Ignore token parsing issues and continue with other fallbacks.
    }

    return '';
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
    } on DioException catch (e) {
      final apiException = e.error is ApiException ? e.error as ApiException : null;
      Logger.error('Token refresh failed: ${apiException?.message ?? e.toString()}');
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
