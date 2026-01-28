import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/logger.dart';
import '../models/stats_model.dart';
import '../models/comprehensive_stats_model.dart';

class StatsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<StatsModel> _dailyStats = [];
  List<StatsModel> _weeklyStats = [];
  List<StatsModel> _monthlyStats = [];
  ComprehensiveStatsModel? _comprehensiveStats;
  bool _isLoading = false;
  String? _error;

  List<StatsModel> get dailyStats => _dailyStats;
  List<StatsModel> get weeklyStats => _weeklyStats;
  List<StatsModel> get monthlyStats => _monthlyStats;
  ComprehensiveStatsModel? get comprehensiveStats => _comprehensiveStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear cached statistics
  void clearStats() {
    _comprehensiveStats = null;
    _dailyStats = [];
    _weeklyStats = [];
    _monthlyStats = [];
    _error = null;
    notifyListeners();
    Logger.info('Cleared cached statistics');
  }

  // Fetch comprehensive statistics
  Future<void> fetchComprehensiveStats({
    String period = '7days',
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    // Clear old data before fetching new data
    if (forceRefresh || _comprehensiveStats != null) {
      _comprehensiveStats = null;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };

      if (period == 'custom' && startDate != null && endDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiService.get(
        '/api/statistics/',
        queryParams: queryParams,
      );
      
      _comprehensiveStats = ComprehensiveStatsModel.fromJson(response);
      Logger.info('Fetched comprehensive stats for period: $period');
    } catch (e) {
      _error = e.toString();
      Logger.error('Error fetching comprehensive stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data for now - replace with API call when backend is ready
      // final response = await _apiService.get('/api/stats/daily/');
      _dailyStats = _generateMockDailyStats();
      
      Logger.info('Fetched ${_dailyStats.length} daily stats');
    } catch (e) {
      _error = e.toString();
      Logger.error('Error fetching daily stats: $e');
      _dailyStats = _generateMockDailyStats();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch weekly stats
  Future<void> fetchWeeklyStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weeklyStats = _generateMockWeeklyStats();
      Logger.info('Fetched ${_weeklyStats.length} weekly stats');
    } catch (e) {
      _error = e.toString();
      Logger.error('Error fetching weekly stats: $e');
      _weeklyStats = _generateMockWeeklyStats();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch monthly stats
  Future<void> fetchMonthlyStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _monthlyStats = _generateMockMonthlyStats();
      Logger.info('Fetched ${_monthlyStats.length} monthly stats');
    } catch (e) {
      _error = e.toString();
      Logger.error('Error fetching monthly stats: $e');
      _monthlyStats = _generateMockMonthlyStats();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate mood statistics
  MoodStats getMoodStats(List<StatsModel> stats) {
    if (stats.isEmpty) {
      return MoodStats(
        moodDistribution: {},
        averageMood: 0,
        dominantMood: 'Unknown',
      );
    }

    final moodCounts = <String, int>{
      'Very Happy': 0,
      'Happy': 0,
      'Neutral': 0,
      'Sad': 0,
      'Very Sad': 0,
    };

    double totalMood = 0;
    for (var stat in stats) {
      totalMood += stat.moodScore;
      if (stat.moodScore >= 9) moodCounts['Very Happy'] = (moodCounts['Very Happy'] ?? 0) + 1;
      else if (stat.moodScore >= 7) moodCounts['Happy'] = (moodCounts['Happy'] ?? 0) + 1;
      else if (stat.moodScore >= 5) moodCounts['Neutral'] = (moodCounts['Neutral'] ?? 0) + 1;
      else if (stat.moodScore >= 3) moodCounts['Sad'] = (moodCounts['Sad'] ?? 0) + 1;
      else moodCounts['Very Sad'] = (moodCounts['Very Sad'] ?? 0) + 1;
    }

    final averageMood = totalMood / stats.length;
    final dominantMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return MoodStats(
      moodDistribution: moodCounts,
      averageMood: averageMood,
      dominantMood: dominantMood,
    );
  }

  // Calculate work statistics
  WorkStats getWorkStats(List<StatsModel> stats) {
    if (stats.isEmpty) {
      return WorkStats(
        totalActivities: 0,
        totalMinutes: 0,
        currentStreak: 0,
        longestStreak: 0,
        completionRate: 0,
      );
    }

    int totalActivities = 0;
    int totalMinutes = 0;
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    for (int i = 0; i < stats.length; i++) {
      totalActivities += stats[i].activitiesCompleted;
      totalMinutes += stats[i].minutesExercised;

      if (stats[i].activitiesCompleted > 0) {
        tempStreak++;
        if (i == stats.length - 1 || stats.length - 1 - i < 7) {
          currentStreak = tempStreak;
        }
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
    }

    final completionRate = (totalActivities / (stats.length * 3)) * 100; // Assuming 3 activities per day goal

    return WorkStats(
      totalActivities: totalActivities,
      totalMinutes: totalMinutes,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completionRate: completionRate.clamp(0, 100),
    );
  }

  // Generate mock daily stats (last 7 days)
  List<StatsModel> _generateMockDailyStats() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return StatsModel(
        date: date,
        activitiesCompleted: 2 + (index % 4),
        minutesExercised: 30 + (index * 10),
        stressLevel: 3 + (index % 5),
        moodScore: 6 + (index % 4),
        sleepHours: 6 + (index % 3),
      );
    });
  }

  // Generate mock weekly stats (last 4 weeks)
  List<StatsModel> _generateMockWeeklyStats() {
    final now = DateTime.now();
    return List.generate(4, (index) {
      final date = now.subtract(Duration(days: (3 - index) * 7));
      return StatsModel(
        date: date,
        activitiesCompleted: 12 + (index * 3),
        minutesExercised: 180 + (index * 50),
        stressLevel: 4 + (index % 4),
        moodScore: 7 + (index % 3),
        sleepHours: 7,
      );
    });
  }

  // Generate mock monthly stats (last 6 months)
  List<StatsModel> _generateMockMonthlyStats() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final date = DateTime(now.year, now.month - (5 - index), 1);
      return StatsModel(
        date: date,
        activitiesCompleted: 45 + (index * 8),
        minutesExercised: 600 + (index * 100),
        stressLevel: 5 + (index % 3),
        moodScore: 7 + (index % 2),
        sleepHours: 7,
      );
    });
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
