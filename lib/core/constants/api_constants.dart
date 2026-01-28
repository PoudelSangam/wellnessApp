class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://app.sangam1313.com.np';
  
  // Auth Endpoints
  static const String login = '/api/login/';
  static const String signup = '/api/signup/';
  static const String tokenRefresh = '/api/token/refresh/';
  
  // User Endpoints
  static const String userProfile = '/api/user/profile/';
  static const String updateProfile = '/api/user/update/';
  static const String deleteAccount = '/api/user/delete/';
  
  // Workout Endpoints
  static const String workoutRecommend = '/api/workout/recommend/';
  static const String dailyActivityRecommend = '/api/workout/activity/recommended/';
  static const String activityList = '/api/activities/';
  static const String activityDetail = '/api/activities/';
  static const String completeActivity = '/api/activities/complete/';
  static const String completeWorkoutActivity = '/api/workout/activity/'; // {id}/complete/
  
  // Progress Endpoints
  static const String progressHistory = '/api/progress/history/';
  static const String weeklyStats = '/api/progress/weekly/';
  static const String monthlyStats = '/api/progress/monthly/';
  
  // Statistics Endpoints
  static const String comprehensiveStats = '/api/statistics/';
  
  // Timeout
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
