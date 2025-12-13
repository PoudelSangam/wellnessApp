import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
  
  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final response = await _apiService.put(
        ApiConstants.updateProfile,
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
        body: userData,
      );
      
      // Update user in auth provider
      final updatedUser = UserModel.fromJson(response);
      _authProvider?.updateUser(updatedUser);
      
      _setLoading(false);
      Logger.success('Profile updated');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _authProvider?.refreshAccessToken();
        return await updateProfile(userData);
      } else {
        _handleError(e);
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    }
  }
  
  // Delete Account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _apiService.delete(
        ApiConstants.deleteAccount,
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
      );
      
      await _authProvider?.logout();
      
      _setLoading(false);
      Logger.success('Account deleted');
      return true;
    } on ApiException catch (e) {
      _handleError(e);
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }
  
  // Error Handling
  void _handleError(dynamic error) {
    if (error is ApiException) {
      _errorMessage = error.message;
      Logger.error('Profile error: ${error.message}');
    } else {
      _errorMessage = 'An unexpected error occurred';
      Logger.error('Profile error: $error');
    }
    _setLoading(false);
  }
  
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
