import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/activity_model.dart';

class ActivityProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;
  
  List<ActivityModel> _activities = [];
  List<ActivityModel> _recommendedActivities = [];
  List<CompletedActivity> _completedActivities = [];
  ActivityModel? _selectedActivity;
  
  // Workout recommendation data
  Map<String, dynamic>? _workoutRecommendation;
  Map<String, dynamic>? _physicalProgram;
  Map<String, dynamic>? _mentalProgram;
  List<String>? _reminders;
  String? _recommendationMessage;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<ActivityModel> get activities => _activities;
  List<ActivityModel> get recommendedActivities => _recommendedActivities;
  List<CompletedActivity> get completedActivities => _completedActivities;
  ActivityModel? get selectedActivity => _selectedActivity;
  Map<String, dynamic>? get workoutRecommendation => _workoutRecommendation;
  Map<String, dynamic>? get physicalProgram => _physicalProgram;
  Map<String, dynamic>? get mentalProgram => _mentalProgram;
  List<String>? get reminders => _reminders;
  String? get recommendationMessage => _recommendationMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
  
  // Fetch All Activities
  Future<void> fetchActivities({String? category}) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final queryParams = category != null ? {'category': category} : null;
      
      final response = await _apiService.get(
        ApiConstants.activityList,
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
        queryParams: queryParams,
      );
      
      _activities = (response['activities'] as List)
          .map((json) => ActivityModel.fromJson(json))
          .toList();
      
      _setLoading(false);
      Logger.success('Activities fetched');
    } on ApiException catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(e);
    }
  }
  
  // Fetch Recommended Activities
  Future<void> fetchRecommendations() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final response = await _apiService.get(
        ApiConstants.workoutRecommend,
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
      );
      
      _workoutRecommendation = response;
      
      // Extract fallback program if exists
      if (response.containsKey('fallback_program')) {
        final fallback = response['fallback_program'];
        _physicalProgram = fallback['physical_program'];
        _mentalProgram = fallback['mental_program'];
        _reminders = (fallback['reminders'] as List?)?.cast<String>();
      }
      
      // Extract message
      _recommendationMessage = response['message'];
      
      // Handle recommendations list if exists
      if (response.containsKey('recommendations')) {
        _recommendedActivities = (response['recommendations'] as List)
            .map((json) => ActivityModel.fromJson(json))
            .toList();
      } else {
        _recommendedActivities = [];
      }
      
      _setLoading(false);
      Logger.success('Recommendations fetched');
      notifyListeners();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _authProvider?.refreshAccessToken();
        await fetchRecommendations();
      } else {
        _handleError(e);
      }
    } catch (e) {
      _handleError(e);
    }
  }
  
  // Fetch Activity Detail
  Future<void> fetchActivityDetail(String activityId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final response = await _apiService.get(
        '${ApiConstants.activityDetail}$activityId/',
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
      );
      
      _selectedActivity = ActivityModel.fromJson(response);
      
      _setLoading(false);
      Logger.success('Activity detail fetched');
    } on ApiException catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(e);
    }
  }
  
  // Complete Activity
  Future<bool> completeActivity(String activityId, {String? notes}) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _apiService.post(
        ApiConstants.completeActivity,
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
        body: {
          'activity_id': activityId,
          'notes': notes,
        },
      );
      
      await fetchCompletedActivities();
      
      _setLoading(false);
      Logger.success('Activity completed');
      return true;
    } on ApiException catch (e) {
      _handleError(e);
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }
  
  // Fetch Completed Activities
  Future<void> fetchCompletedActivities() async {
    try {
      final response = await _apiService.get(
        ApiConstants.progressHistory,
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
      );
      
      _completedActivities = (response['history'] as List)
          .map((json) => CompletedActivity.fromJson(json))
          .toList();
      
      notifyListeners();
      Logger.success('Completed activities fetched');
    } on ApiException catch (e) {
      Logger.error('Fetch completed activities failed: ${e.message}');
    } catch (e) {
      Logger.error('Fetch completed activities error: $e');
    }
  }
  
  // Filter Activities by Category
  List<ActivityModel> getActivitiesByCategory(String category) {
    return _activities.where((activity) => activity.category == category).toList();
  }
  
  // Clear Selected Activity
  void clearSelectedActivity() {
    _selectedActivity = null;
    notifyListeners();
  }
  
  // Error Handling
  void _handleError(dynamic error) {
    if (error is ApiException) {
      _errorMessage = error.message;
      Logger.error('Activity error: ${error.message}');
    } else {
      _errorMessage = 'An unexpected error occurred';
      Logger.error('Activity error: $error');
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
