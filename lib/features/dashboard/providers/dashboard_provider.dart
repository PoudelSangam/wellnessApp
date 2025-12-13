import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;
  
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _weeklyStats;
  Map<String, dynamic>? _monthlyStats;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  Map<String, dynamic>? get dashboardData => _dashboardData;
  Map<String, dynamic>? get weeklyStats => _weeklyStats;
  Map<String, dynamic>? get monthlyStats => _monthlyStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
  
  // Fetch Dashboard Data
  Future<void> fetchDashboardData() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      // Fetch weekly stats
      final weeklyResponse = await _apiService.get(
        ApiConstants.weeklyStats,
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
      );
      
      _weeklyStats = weeklyResponse;
      
      // Fetch monthly stats
      final monthlyResponse = await _apiService.get(
        ApiConstants.monthlyStats,
        headers: ApiConstants.getHeaders(token: _authProvider?.accessToken),
      );
      
      _monthlyStats = monthlyResponse;
      
      // Combine data
      _dashboardData = {
        'weekly': _weeklyStats,
        'monthly': _monthlyStats,
      };
      
      _setLoading(false);
      Logger.success('Dashboard data fetched');
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _authProvider?.refreshAccessToken();
        await fetchDashboardData();
      } else {
        _handleError(e);
      }
    } catch (e) {
      _handleError(e);
    }
  }
  
  // Get Today's Completion Rate
  double getTodayCompletionRate() {
    if (_weeklyStats == null) return 0.0;
    
    final completedToday = _weeklyStats!['completed_today'] ?? 0;
    final goalDays = _authProvider?.user?.workoutGoalDays ?? 1;
    
    return (completedToday / goalDays).clamp(0.0, 1.0);
  }
  
  // Get Weekly Streak
  int getWeeklyStreak() {
    return _weeklyStats?['streak'] ?? 0;
  }
  
  // Get Total Activities Completed
  int getTotalActivitiesCompleted() {
    return _monthlyStats?['total_completed'] ?? 0;
  }
  
  // Error Handling
  void _handleError(dynamic error) {
    if (error is ApiException) {
      _errorMessage = error.message;
      Logger.error('Dashboard error: ${error.message}');
    } else {
      _errorMessage = 'An unexpected error occurred';
      Logger.error('Dashboard error: $error');
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
