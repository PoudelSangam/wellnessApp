class AppConstants {
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int minUsernameLength = 3;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration refreshTokenBuffer = Duration(minutes: 5);
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Activity Categories
  static const List<String> activityCategories = [
    'Mental',
    'Physical',
    'Breathing',
    'Meditation',
    'Yoga',
    'Stretching',
  ];
  
  // Stress Levels
  static const List<String> stressLevels = [
    'Low',
    'Moderate',
    'High',
    'Very High',
  ];
  
  // Goals
  static const List<String> primaryGoals = [
    'Improve Fitness',
    'Increase Mindfulness',
    'Lose Weight',
    'Reduce Stress',
  ];
}
